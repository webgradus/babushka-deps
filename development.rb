dep 'prepare-deploy', :app_name, :git_username, :server_ip, :app_path, :app_type, :ruby_version, :faye do
  app_name.ask("What is the name of application that will be located at /opt")
  git_username.ask('What is your Git username (login) on GitEnterprise')
  server_ip.ask('Where to deploy - I need IP')
  app_type.default('rails').choose(%w[rails locomotive])
  app_path.default!("")
  ruby_version.default("2.0.0").choose(%w[2.0.0 1.9.3])
  requires 'autobackup'.with(app_name, app_path, ruby_version)
  requires 'foreman'.with(app_path, faye)
  met? {
    Babushka::Renderable.new(app_path / "config/deploy.rb").from?(dependency.load_path.parent / "development/deploy.rb.erb") && Babushka::Renderable.new(app_path / "config/unicorn.rb").from?(dependency.load_path.parent / "development/unicorn.rb.erb")
  }
  meet {
    render_erb "development/deploy.rb.erb", :to => (app_path / "config/deploy.rb").to_s
    render_erb "development/unicorn.rb.erb", :to => (app_path / "config/unicorn.rb").to_s
  }
end
