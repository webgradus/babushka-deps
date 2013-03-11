dep 'prepare-deploy', :app_name, :git_username, :server_ip do
  app_name.ask("What is the name of application that will be located at /opt")
  git_username.ask('What is your Git username (login) on GitEnterprise')
  server_ip.ask('Where to deploy - I need IP')
  met? {
    Babushka::Renderable.new("config/deploy.rb").from?(dependency.load_path.parent / "development/deploy.rb.erb") && Babushka::Renderable.new("config/unicorn.rb").from?(dependency.load_path.parent / "development/unicorn.rb.erb")
  }
  meet {
    render_erb "development/deploy.rb.erb", :to => "config/deploy.rb"
    render_erb "development/unicorn.rb.erb", :to => "config/unicorn.rb"
  }
end
