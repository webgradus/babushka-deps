dep 'rails.installed', :ruby_version do
met? { raw_shell("rvm use #{ruby_version} do gem list rails").stdout.include?("rails") }
meet {
  shell "rvm use #{ruby_version} do gem install rails --no-rdoc --no-ri"
}   
end
