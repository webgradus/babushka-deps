dep 'rails installed', :ruby_version, :rails_version do
met? {
  rvm_run_with_ruby(ruby_version, "gem list rails") {|shell| shell.stdout.include?(rails_version) }
}
meet {
  rvm_run_with_ruby ruby_version, "gem install rails -v=#{rails_version} --no-rdoc --no-ri"
}
end

dep 'puma configured', :app_path do
    met? {
        Babushka::Renderable.new(app_path / "config/puma.rb").from?(dependency.load_path.parent / "development/puma.rb.erb")
    }

    meet {
        render_erb "development/puma.rb.erb", :to => (app_path / "config/puma.rb").to_s
    }
end
