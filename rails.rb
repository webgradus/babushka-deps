dep 'rails installed', :ruby_version do
met? { rvm_run("use #{ruby_version} do gem list rails").stdout.include?("rails (") }
meet {
  rvm_run "use #{ruby_version} do gem install rails --no-rdoc --no-ri"
}   
end
