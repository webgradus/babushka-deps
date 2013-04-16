dep 'prepare-deploy', :app_name, :git_username, :server_ip, :app_path do
  app_name.ask("What is the name of application that will be located at /opt")
  git_username.ask('What is your Git username (login) on GitEnterprise')
  server_ip.ask('Where to deploy - I need IP')
  app_path.default("")
  met? {
    Babushka::Renderable.new("config/deploy.rb").from?(dependency.load_path.parent / "development/deploy.rb.erb") && Babushka::Renderable.new("config/unicorn.rb").from?(dependency.load_path.parent / "development/unicorn.rb.erb")
  }
  meet {
    render_erb "development/deploy.rb.erb", :to => (app_path / "config/deploy.rb").to_s
    render_erb "development/unicorn.rb.erb", :to => (app_path / "config/unicorn.rb").to_s
  }
end
