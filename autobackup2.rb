dep 'autobackup2', :app_name, :app_path, :database do
  requires "schedule2"
  app_path.default!("")
  database.default("mysql").choose(%w[mysql postgresql mongodb])
  
  met? {
    Babushka::Renderable.new("/root/Backup/models/" + app_name + ".rb").from?(dependency.load_path.parent / "autobackup/model_template.rb.erb")
  }
  meet {
    render_erb "autobackup/model_template.rb.erb", :to => ("/root/Backup/models/" + app_name + ".rb").to_s
  }
end

dep "schedule2", :app_name do
  app_name.ask("What is the name of application?")
  met? {
    shell? %{ grep #{app_name} /root/Backup/config/schedule.rb}
  }
  meet {
    shell %{ echo 'every 1.week do' >> /root/Backup/config/schedule.rb }
    shell %{ echo '  command "backup perform -t #{app_name}"' >> /root/Backup/config/schedule.rb }
    shell %{ echo 'end' >> /root/Backup/config/schedule.rb }
    shell %{ cd /root/Backup }
    shell %{ whenever }
    shell %{ whenever --update-crontab }
  } 
end
