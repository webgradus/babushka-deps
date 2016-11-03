dep 'kms running', :app_name, :ruby_version do
  app_name.ask("App or site name that will be located at /opt")
  ruby_version.ask("Which ruby version do you want to use?").choose(current_rubies)
  requires 'rvm',
           'kms installed'.with(app_name, ruby_version, nil),
           'unicorn configured'.with(ruby_version, app_name, 'kms'),
           'foreman.start'.with("/opt/#{app_name}", 'no', 'unicorn'),
           'server'.with(app_name, rand(3000..5000), 'kms')
end

dep 'kms installed', :app_name, :ruby_version, :postgres_password do
  # check if we have rails and if we have access to KMS repo
  requires 'rails installed'.with(ruby_version, "5.0.0.1"), 'repo accessible'.with("git@gitlab.com:webgradus/kms.git")
  postgres_password.ask("Please type PostgreSQL password for user 'postgres'")

  met? { "/opt/#{app_name}".p.exists? }

  meet {
    cd "/opt" do
      rvm_run_with_ruby ruby_version, "rails _5.0.0.1_ new #{app_name} --skip-test-unit --skip-bundle --database=postgresql"
      shell "echo '#{ruby_version}' > .ruby-version", cd: app_name
      cd "#{app_name}", create: true do
        shell %{echo 'gem "kms"' >> Gemfile}
        shell %{echo 'gem "kms_models"' >> Gemfile}
        shell %{echo 'gem "unicorn"' >> Gemfile}        
        shell %{mkdir tmp/pids; mkdir tmp/sockets}
        log "bundle install..."
        rvm_shell %{bundle install}
        log "setup database.yml..."
        render_erb "kms/database.yml.erb", to: "config/database.yml"
        log "setup secrets.yml..."
        raw_shell %{echo "ENV['SECRET_KEY_BASE']='$(rvm-shell -c 'bundle exec rake secret')'" >> config/environments/production.rb}
        log "setup locale..."
        raw_shell %{echo "I18n.default_locale = :ru" >> config/application.rb}
        log "creating database..."
        rvm_shell %{RAILS_ENV=production bundle exec rails db:create}
        log "running kms generator..."
        rvm_shell %{RAILS_ENV=production bundle exec rails g kms:install}
        log "running kms_models generator..."
        rvm_shell %{RAILS_ENV=production bundle exec rails g kms_models:install}        
        log "install migrations..."
        rvm_shell %{RAILS_ENV=production bundle exec rails kms:install:migrations}
        log "install kms_models migrations..."
        rvm_shell %{RAILS_ENV=production bundle exec rails kms_models:install:migrations}
        log "applying migrations..."
        rvm_shell %{RAILS_ENV=production bundle exec rails db:migrate}
        log "precompiling assets..."
        rvm_shell %{RAILS_ENV=production bundle exec rails assets:precompile}
      end
    end
  }

end
