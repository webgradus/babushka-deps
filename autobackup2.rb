dep 'autobackup2', :app_name, :app_path, :database do
  app_name.ask("What is the name of application?")
  app_path.default!("")
  database.default("mysql").choose(%w[mysql postgresql mongodb])
  
  met? {
    Babushka::Renderable.new("root/Backup/models/" + app_name + ".rb").from?(dependency.load_path.parent / "autobackup/model_template.rb.erb")  }
  meet {
    render_erb "autobackup/model_tamplate.rb.erb", :to => ("/root/Backup/models/" + app_name + ".rb").to_s
  }

  met? {
      shell? %{ grep #{app_name} /root/Backup/config/schedule.rb}
  }
  meet {
      shell %{ echo 'every 1.week do' >> /root/Backup/config/schedule.rb }
      shell %{ echo 'command "backup perform -t #{app_name}"' >> /root/Backup/config/schedule.rb }
      shell %{ echo 'end' >> /root/Backup/config/schedule.rb }
      shell %{ wheneverize }
  }
 
end
