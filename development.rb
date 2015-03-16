dep 'prepare-deploy', :app_name, :git_username, :server_ip, :app_path, :app_type, :ruby_version, :use_faye, :web_server do
  app_name.ask("What is the name of application that will be located at /opt")
  git_username.default!("") #ask('What is your Gitlab username (login) on GitEnterprise')
  server_ip.ask('Where to deploy - I need IP')
  app_type.default('rails').choose(%w[rails locomotive])
  app_path.default!("")
  ruby_version.default("2.1.0")
  use_faye.default('no').choose(%w[yes no])
  web_server.default('unicorn').choose(%w[unicorn puma])
  requires 'foreman'.with(app_path, use_faye, web_server)
  met? {
    Babushka::Renderable.new(app_path / "config/deploy.rb").from?(dependency.load_path.parent / "development/deploy.rb.erb") && 
    Babushka::Renderable.new(app_path / "config/deploy/production.rb").from?(dependency.load_path.parent / "development/deploy/production.rb.erb") &&
    (web_server == "unicorn" ? 
       Babushka::Renderable.new(app_path / "config/unicorn.rb").from?(dependency.load_path.parent / "development/unicorn.rb.erb") : 
       Babushka::Renderable.new(app_path / "config/puma.rb").from?(dependency.load_path.parent / "development/puma.rb.erb")
    )
  }
  meet {
    render_erb "development/deploy.rb.erb", :to => (app_path / "config/deploy.rb").to_s
    render_erb "development/deploy/production.rb.erb", :to => (app_path / "config/deploy/production.rb").to_s
    if web_server == "unicorn"
      render_erb "development/unicorn.rb.erb", :to => (app_path / "config/unicorn.rb").to_s
    else
      render_erb "development/puma.rb.erb", :to => (app_path / "config/puma.rb").to_s
    end
  }
end
