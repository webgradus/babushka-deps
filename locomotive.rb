dep 'locomotive' do
  require 'wagon'  
end

dep 'wagon' do
  met? { shell? "rvm use 1.9.3 do wagon version" }
  meet {
    shell "rvm use 1.9.3 do gem install locomotivecms_wagon"
  }
end

dep 'wagon site' do
  require 'wagon'
  site_name.ask("Please provide site's folder name:")
  met? { site_name.p.exists? }
  meet {
    shell "rvm use 1.9.3 do wagon init #{site_name}"
    shell "cd #{site_name}"
    shell "echo 'rvm use 1.9.3' > .rvmrc"
    shell "rvm use 1.9.3 do bundle install"
  }
end
