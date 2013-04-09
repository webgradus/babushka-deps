dep 'locomotive' do
  requires 'wagon'  
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
    shell "rvm use 1.9.3 do wagon init #{site_name} && cd #{site_path.to_s}"
    shell "echo 'rvm_trust_rvmrcs_flag=1; rvm use 1.9.3' > .rvmrc"
    shell "rvm use 1.9.3 do bundle install"
  }
end
