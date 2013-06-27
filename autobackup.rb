dep 'autobackup', :app_name, :app_path, :ruby_version do
  requires 'schedule'
  app_name.ask("What is the name of application?")
  app_path.default!("")

  if !(app_path / "config/backup").exists?
    shell %{ mkdir "config/backup"}
    shell %{ mkdir "config/backup/models"}
  end

  met? {
    Babushka::Renderable.new(app_path / "config/backup/config.rb").from?(dependency.load_path.parent / "autobackup/config.rb.erb") && Babushka::Renderable.new(app_path / "config/backup/models/webgradus_backup.rb").from?(dependency.load_path.parent / "autobackup/webgradus_backup.rb.erb") && Babushka::Renderable.new(app_path / "config/backup.yml").from?(dependency.load_path.parent / "autobackup/backup.yml.erb")
  }
  meet {
    render_erb "autobackup/config.rb.erb", :to => (app_path / "config/backup/config.rb").to_s
    render_erb "autobackup/webgradus_backup.rb.erb", :to => (app_path / "config/backup/models/webgradus_backup.rb").to_s
    render_erb "autobackup/backup.yml.erb", :to => (app_path / "config/backup.yml").to_s
    shell "echo 'config/backup.yml' >> .gitignore"
    shell "echo 'group :backup do' >> Gemfile"
    shell %{echo ' gem "backup"' >> Gemfile}
    shell %{echo ' gem "whenever"' >> Gemfile}
    shell "echo 'end' >> Gemfile"
  }

end

dep 'schedule', :app_path, :ruby_version do
  app_path.default!("")
  ruby_version.default("2.0.0").choose(%w[2.0.0 1.9.3])
  shell %{ echo 'job_type :backup, "cd :path && rvm use #{ruby_version} do bundle exec backup perform -t webgradus_backup -c config/backup/config.rb :output"' >> config/schedule.rb}
  shell %{ echo 'every 1.week do' >> config/schedule.rb}
  shell %{ echo 'backup ""' >> config/schedule.rb}
  shell %{ echo 'end' >> config/schedule.rb}
end
