dep 'rails installed', :ruby_version, :rails_version do
met? {
  rvm_run_with_ruby(ruby_version, "gem list rails") {|shell| shell.stdout.include?("rails (#{rails_version})") }
}
meet {
  rvm_run_with_ruby ruby_version, "gem install rails -v=#{rails_version} --no-rdoc --no-ri"
}
end
