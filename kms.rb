dep 'kms running', :app_name, :ruby_version do
  app_name.ask("App or site name that will be located at /opt")
  ruby_version.ask("Which ruby version do you want to use?").choose(current_rubies)
  requires 'rvm',
           'kms installed'.with(app_name, ruby_version, nil),
           'foreman.start'.with("/opt/#{app_name}", 'no', 'puma')
end

dep 'kms installed', :app_name, :ruby_version, :postgres_password do
  # check if we have rails and if we have access to KMS repo
  requires 'rails installed'.with(ruby_version, "4.2.5"), 'repo accessible'.with("git@gitlab.com:webgradus/kms.git")
  postgres_password.ask("Please type PostgreSQL password for user 'postgres'")

  met? { "/opt/#{app_name}".p.exists? }

  meet {
    cd "/opt" do
      rvm_run_with_ruby ruby_version, "rails _4.2.5_ new #{app_name} --skip-test-unit --skip-javascript --skip-bundle --database=postgresql"
      shell "echo '#{ruby_version}' > .ruby-version", cd: app_name
      cd "#{app_name}", create: true do
        shell %{echo 'gem "kms", git: "git@gitlab.com:webgradus/kms.git"' >> Gemfile}
        shell %{echo 'gem "puma"' >> Gemfile}
        shell %{echo 'gem "sprockets", "2.12.4"' >> Gemfile}
        shell %{mkdir tmp/pids; mkdir tmp/sockets}
        log "bundle install..."
        rvm_shell %{bundle install}
        log "setup database.yml..."
        render_erb "kms/database.yml.erb", to: "config/database.yml"
        log "setup secrets.yml..."
        raw_shell %{echo "ENV['SECRET_KEY_BASE']='$(bundle exec rake secret)'" >> config/environments/production.rb}
        log "running kms generator..."
        rvm_shell %{RAILS_ENV=production bundle exec rails g kms:install}
        log "install migrations..."
        rvm_shell %{RAILS_ENV=production bundle exec rake kms:install:migrations}
        log "creating database..."
        rvm_shell %{RAILS_ENV=production bundle exec rake db:create}
        log "applying migrations..."
        rvm_shell %{RAILS_ENV=production bundle exec rake db:migrate}
        log "precompiling assets..."
        rvm_shell %{RAILS_ENV=production bundle exec rake assets:precompile}
      end
    end
  }

end
