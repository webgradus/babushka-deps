dep 'kms running' do
  app_name.ask("App or site name that will be located at /opt")
  ruby_version.ask("Which ruby version do you want to use?").choose(current_rubies)
  requires 'rvm',
           'kms installed'.with(app_name, ruby_version),
           'foreman.start'.with("/opt/#{app_name}", 'no', 'puma')
end

dep 'kms installed', :app_name, :ruby_version do
  requires 'rails installed'.with(ruby_version, "4.2.5")
  met? { "/opt/#{app_name}".p.exists? }

  meet {
    cd "/opt" do
      rvm_run_with_ruby ruby_version, "rails _4.2.5_ new #{app_name} --skip-test-unit --skip-javascript --skip-bundle --database=postgresql"
      cd "#{app_name}", create: true do
        shell "echo '#{ruby_version}' > .ruby-version"
        shell %{echo 'gem "kms", git: "git@gitlab.com:webgradus/kms.git"' >> Gemfile}
        shell %{echo 'gem "puma"' >> Gemfile}
        shell %{echo 'gem "sprockets", "2.12.4"' >> Gemfile}
        shell %{mkdir tmp/pids; mkdir tmp/sockets}
        log "bundle install..."
        rvm_run_with_ruby ruby_version, "bundle install"
        log "setup database.yml..."
        postgres_password.ask("Please type PostgreSQL password for user 'postgres'")
        render_erb "kms/database.yml.erb", to: "config/database.yml"
        log "running kms generator..."
        rvm_run_with_ruby ruby_version, "RAILS_ENV=production bundle exec rails g kms:install"
        log "install migrations..."
        rvm_run_with_ruby ruby_version, "RAILS_ENV=production bundle exec rake kms:install:migrations"
        log "applying migrations..."
        rvm_run_with_ruby ruby_version, "RAILS_ENV=production bundle exec rake db:migrate"
        log "precompiling assets..."
        rvm_run_with_ruby ruby_version, "RAILS_ENV=production bundle exec rake assets:precompile"
      end
    end
  }

end
