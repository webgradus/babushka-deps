dep 'autobackup', :app_name, :app_path do
  app_name.ask("What is the name of application that will be located at /opt")
  app_path.default!("")
  met? {
    Babushka::Renderable.new(app_path / "config/backup/config.rb").from?(dependency.load_path.parent / "autobackup/config.rb.erb") && Babushka::Renderable.new(app_path / "config/backup/models/webgradus-backup.rb").from?(dependency.load_path.parent / "autobackup/webgradus-backup.rb.erb")
  }
  meet {
    render_erb "autobackup/config.rb.erb", :to => (app_path / "config/backup/config.rb").to_s
    render_erb "autobackup/webgradus-backup.rb.erb", :to => (app_path / "config/backup/models/webgradus-backup.rb").to_s
  }
end
