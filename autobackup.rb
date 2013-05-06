dep 'autobackup', :app_name, :app_path, :ruby_version do
  app_name.ask("What is the name of application that will be located at /opt")
  app_path.default!("")
  ruby_version.default("2.0.0").choose(%w[2.0.0 1.9.3])
  met? {
    Babushka::Renderable.new(app_path / "config/backup/config.rb").from?(dependency.load_path.parent / "autobackup/config.rb.erb") && Babushka::Renderable.new(app_path / "config/backup/models/webgradus-backup.rb").from?(dependency.load_path.parent / "autobackup/webgradus-backup.rb.erb")
  }
  meet {
    render_erb "autobackup/config.rb.erb", :to => (app_path / "config/backup/config.rb").to_s
    render_erb "autobackup/webgradus-backup.rb.erb", :to => (app_path / "config/backup/models/webgradus-backup.rb").to_s
    
  }
  
   if (app_path / "config/schedule.rb").exists?
    shell %{echo 'job_type :backup, "cd :path && rvm use #{ruby_version} do bundle exec backup perform -t general -c config/backup/config.rb"' >> config/schedule.rb}
    shell %{ echo 'every 3.days do' >> config/schedule.rb}
    shell %{ echo 'backup ""' >> config/schedule.rb}
    shell %{ echo 'end' >> config/schedule.rb}
   else
    met? {
	Babushka::Renderable.new(app_path / "config/schedule.rb").from?(dependency.load_path.parent / "autobackup/schedule.rb.erb")
    }
    meet {
	render_erb "autobackup/schedule.rb.erb", :to => (app_path / "config/schedule.rb").to_s
    }
   end
end
