dep 'unicorn-init-script copied', :app_name, :app_type do  
  met? {    
    Babushka::Renderable.new("/etc/init.d/#{app_name}").from?(dependency.load_path.parent / "init/init.sh.erb")
  }
  meet {    
    render_erb "init/init.sh.erb", :to => "/etc/init.d/#{app_name}", :perms => '755', :sudo => true    
  }
  
end

dep 'unicorn-init-script', :app_name, :app_type do
  app_name.ask("What is the name of application located at /opt")
  app_type.default('rails').choose(%w[rails locomotive])
  requires 'unicorn-init-script copied'.with(app_name, app_type)
  requires 'rcconf.managed'
  if app_type == 'rails'
    shell "cd /opt/#{app_name}/current; rvm rvmrc trust ."
  else
    shell "cd /opt/#{app_name}; rvm rvmrc trust ."
  end
  met? { shell("rcconf --list").val_for(app_name) == 'on' }
  meet {
    sudo "update-rc.d #{app_name} defaults"
  }
  requires 'autobackup'.with(app_name)
end

dep 'start', :app_name, :app_type do
  app_type.default!('rails')
  requires 'unicorn-init-script'.with(app_name, app_type)
  met? {
    app_type == 'rails' ? "/opt/#{app_name}/current/tmp/pids/unicorn.pid".p.exists? : "/opt/#{app_name}/tmp/pids/unicorn.pid".p.exists?
  }
  meet {
    shell "/etc/init.d/#{app_name} start"
  }
end
