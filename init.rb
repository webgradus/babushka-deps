dep 'unicorn-init-script copied', :app_name do  
  met? {    
    Babushka::Renderable.new("/etc/init.d/#{app_name}").from?(dependency.load_path.parent / "init/init.sh.erb")
  }
  meet {    
    render_erb "init/init.sh.erb", :to => "/etc/init.d/#{app_name}", :perms => '755', :sudo => true    
  }
  
end

dep 'unicorn-init-script', :app_name do
  app_name.ask("What is the name of application located at /opt")
  requires 'unicorn-init-script copied'.with(app_name)
  requires 'rcconf.managed'
  shell "cd /opt/#{app_name}/current; rvm rvmrc trust ."
  met? { shell("rcconf --list").val_for(app_name) == 'on' }
  meet {
    sudo "update-rc.d #{app_name} defaults"
  }
end