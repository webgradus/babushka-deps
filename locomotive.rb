# use this deop ONLY on server cause it uses rvm_run
dep 'locomotive.local', :host, :app_name do
  requires 'rvm', 'rails installed'.with("2.0.0", "3.2.17")
  met? { "/opt/#{app_name}".p.exists? }

  meet {
    cd "/opt" do
      rvm_run_with_ruby "2.0.0", "rails _3.2.17_ new #{app_name} --skip-active-record --skip-test-unit --skip-javascript --skip-bundle"
      cd "#{app_name}", :create => true do
        shell "echo 'rvm_trust_rvmrcs_flag=1; rvm use 2.0.0' > .rvmrc"
        shell %{echo 'gem "locomotive_cms", github: "locomotivecms/engine", branch: "master", :require => "locomotive/engine"' >> Gemfile}
        shell %{echo 'gem "unicorn"' >> Gemfile}
        shell %{echo 'gem "compass-rails", "~> 1.1.3", :group => "assets"' >> Gemfile}
        shell %{echo 'gem "therubyracer", ">= 0.9.9"' >> Gemfile}
        shell "mkdir deploy", :cd => "/config/"
        log "bundle install..."
        rvm_run_with_ruby "2.0.0", "bundle install"
        log "running locomotive generator..."
        rvm_run_with_ruby "2.0.0", "bundle exec rails g locomotive:install"
        render_erb "locomotive/locomotive.rb.erb", :to => "/opt/#{app_name}/config/initializers/locomotive.rb", :sudo => true
        render_erb "locomotive/mongoid.yml.erb", :to => "/opt/#{app_name}/config/mongoid.yml", :sudo => true
        render_erb "locomotive/carrierwave.rb.erb", :to => "/opt/#{app_name}/config/initializers/carrierwave.rb", :sudo => true
        log "precompiling assets..."
        rvm_run_with_ruby "2.0.0", "bundle exec rake assets:precompile"
      end
    end
  }
end

dep 'locomotive', :host, :app_name, :port do
  host.ask("Where to deploy LocomotiveCMS (IP or domain)")
  app_name.ask("App or site name that will be located at /opt")
  port.ask("HTTP Port for configuring NGINX server")
  met? {
    shell %{ssh root@#{host} 'sh -'}, :input => "cd /opt/#{app_name}", :log => true
  }

  meet {
    as('root') {
      log "remote Locomotive installation..."
      remote_babushka "webgradus:locomotive.local", :host => host, :app_name => app_name
      log "generating unicorn.rb..."
      remote_babushka "webgradus:prepare-deploy", :app_name => app_name, :git_username => "gradus", :server_ip => host, :app_path => "/opt/#{app_name}", :app_type => "locomotive"
      log "starting Unicorn..."
      remote_babushka "webgradus:start", :app_name => app_name, :app_type => "locomotive", :database => "mongodb"
      log "generating Nginx server - restarting Nginx..."
      remote_babushka "webgradus:unicorn-server", :app_name => app_name, :port => port, :app_type => "locomotive"
    }
  }
end

dep 'wagon' do
  met? { shell? "rvm use 2.0.0 do wagon version" }
  meet {
    shell "rvm use 2.0.0 do gem install locomotivecms_wagon"
  }
end

dep 'wagon site', :site_name do
  requires 'wagon'
  site_name.ask("Please provide site's folder name:")
  site_path = (shell "pwd") / site_name
  met? { site_path.exists? }
  meet {
    shell "rvm use 2.0.0 do wagon init #{site_name}"
    log "created a site..."
    cd "#{site_path.to_s}" do
      shell "echo 'rvm_trust_rvmrcs_flag=1; rvm use 2.0.0' > .rvmrc"
      log "making 'bundle install' in #{site_path.to_s}..."
      shell "rvm use 2.0.0 do bundle install"
    end
  }
end
