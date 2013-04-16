dep 'locomotive.local', :host do
  met? { "/opt/locomotive".p.exists? }
    
  meet {
    cd "/opt" do
      shell "rvm use 1.9.3 do rails new locomotive --skip-active-record --skip-test-unit --skip-javascript --skip-bundle"
      cd "/opt/locomotive" do
        shell "echo 'rvm_trust_rvmrcs_flag=1; rvm use 1.9.3' > .rvmrc"
        shell %{echo 'gem "locomotive_cms", "~> 2.0.3", :require => "locomotive/engine"' >> Gemfile}
        shell %{echo 'gem "unicorn"' >> Gemfile}
        shell %{echo 'gem "compass-rails", "~> 1.0.2", :group => "assets"' >> Gemfile}
        shell %{echo 'gem "therubyracer", ">= 0.8.2"' >> Gemfile}
        shell "rvm use 1.9.3 do bundle install"
      end
    end
  }
end

dep 'locomotive', :host do
  host.ask("Where to deploy LocomotiveCMS")
  met? {
    shell %{ssh root@#{host} 'sh -'}, :input => 'cd /opt/locomotive', :log => true    
  }
  
  meet {
    as('root') {      
      remote_babushka "webgradus:locomotive.local", :host => host
    }  
  }
end

dep 'wagon' do
  met? { shell? "rvm use 1.9.3 do wagon version" }
  meet {
    shell "rvm use 1.9.3 do gem install locomotivecms_wagon"
  }
end

dep 'wagon site', :site_name do
  requires 'wagon'
  site_name.ask("Please provide site's folder name:")
  site_path = (shell "pwd") / site_name
  met? { site_path.exists? }
  meet {
    shell "rvm use 1.9.3 do wagon init #{site_name}"
    log "created a site..."
    cd "#{site_path.to_s}" do
      shell "echo 'rvm_trust_rvmrcs_flag=1; rvm use 1.9.3' > .rvmrc"
      log "making 'bundle install' in #{site_path.to_s}..."
      shell "rvm use 1.9.3 do bundle install"      
    end
  }
end
