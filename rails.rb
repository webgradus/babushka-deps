dep 'rails installed', :ruby_version do
met? {
  rvm_run_with_ruby(ruby_version, "gem list rails") {|shell| shell.stdout.include?("rails (") }
}
meet {
  rvm_run_with_ruby ruby_version, "gem install rails --no-rdoc --no-ri"
}
end
