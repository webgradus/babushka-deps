dep 'autobackup', :app_name, :app_path, :database, :ruby_version_for_backup_script do
  requires 'backup-server'
  app_name.ask("What is the name of application?")
  app_path.default!("")
  database.default("mysql").choose(%w[mysql postgresql mongodb])
  ruby_version_for_backup_script.default("2.0.0").choose(%w[2.0.0 1.9.3])

  met? {
    Babushka::Renderable.new("~/Backup/models/" + app_name + "_database.rb").from?(dependency.load_path.parent / "autobackup/model_database_template.rb.erb")&&Babushka::Renderable.new("~/Backup/models/" + app_name + "_archives.rb").from?(dependency.load_path.parent / "autobackup/model_archive_template.rb.erb")
  }
  meet {
    render_erb "autobackup/model_database_template.rb.erb", :to => ("~/Backup/models/" + app_name + "_database.rb").to_s
    rvm_run_with_ruby ruby_version_for_backup_script, "backup perform -t #{app_name}_database"
    render_erb "autobackup/model_archive_template.rb.erb", :to => ("~/Backup/models/" + app_name + "_archives.rb").to_s
    rvm_run_with_ruby ruby_version_for_backup_script, "backup perform -t #{app_name}_archives"
  }
  requires "schedule".with(app_name, ruby_version_for_backup_script)

end

dep "schedule", :app_name, :ruby_version_for_backup_script do

  met? {
    shell? %{ grep #{app_name} ~/Backup/config/schedule.rb}
  }
  meet {
    shell %{ echo 'every 1.week do' >> ~/Backup/config/schedule.rb }
    shell %{ echo '  command "rvm use #{ruby_version_for_backup_script} do backup perform -t #{app_name}_database"' >> ~/Backup/config/schedule.rb }
    shell %{ echo 'end' >> ~/Backup/config/schedule.rb }

    shell %{ echo 'every 1.month do' >> ~/Backup/config/schedule.rb }
    shell %{ echo '  command "rvm use #{ruby_version_for_backup_script} do backup perform -t #{app_name}_archives"' >> ~/Backup/config/schedule.rb }
    shell %{ echo 'end' >> ~/Backup/config/schedule.rb }

    cd '~/Backup/' do
      rvm_run_with_ruby ruby_version_for_backup_script, "whenever"
      rvm_run_with_ruby ruby_version_for_backup_script, "whenever --update-crontab"
    end
  }
end
