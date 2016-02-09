dep 'rails installed', :ruby_version, :rails_version do
met? {
  rvm_run_with_ruby(ruby_version, "gem list rails") {|shell| shell.stdout.include?(rails_version) }
}
meet {
  rvm_run_with_ruby ruby_version, "gem install rails -v=#{rails_version} --no-rdoc --no-ri"
}
end

dep 'puma configured', :app_name, :app_type do
    met? {
        Babushka::Renderable.new("/opt" / app_name / "config/puma.rb").from?(dependency.load_path.parent / "development/puma.rb.erb")
    }

    meet {
        render_erb "development/puma.rb.erb", :to => ("/opt" / app_name / "config/puma.rb").to_s
    }
end

dep 'unicorn configured', :ruby_version, :app_name, :app_type do
    met? {
        Babushka::Renderable.new("/opt" / app_name / "config/unicorn.rb").from?(dependency.load_path.parent / "development/unicorn.rb.erb")
    }

    meet {
        render_erb "development/unicorn.rb.erb", :to => ("/opt" / app_name / "config/unicorn.rb").to_s
    }
end
