dep 'unicorn-init-script copied', :app_name, :app_type do
  met? {
    Babushka::Renderable.new("/etc/init.d/#{app_name}").from?(dependency.load_path.parent / "init/init.sh.erb")
  }
  meet {
    render_erb "init/init.sh.erb", :to => "/etc/init.d/#{app_name}", :perms => '755', :sudo => true
  }

end

dep 'unicorn-init-script', :app_name, :app_type, :database, :ruby_version do
  app_name.ask("What is the name of application located at /opt")
  app_type.default('rails').choose(%w[rails locomotive])
  ruby_version.default('2.0.0').choose(%w[1.9.3 2.0.0 2.1.0])
  database.default!('mysql')
  requires 'unicorn-init-script copied'.with(app_name, app_type)
  requires 'rcconf.bin'
  if app_type == 'rails'
    shell "cd /opt/#{app_name}/current; rvm rvmrc trust ."
  else
    shell "cd /opt/#{app_name}; rvm rvmrc trust ."
  end
  met? { shell("rcconf --list").val_for(app_name) == 'on' }
  meet {
    sudo "update-rc.d #{app_name} defaults"
  }
  requires 'autobackup'.with(app_name, "/opt/#{app_name}", database, ruby_version)
end

dep 'start', :app_name, :app_type, :database do
  app_type.default!('rails')
  database.default!('mysql')
  requires 'unicorn-init-script'.with(app_name, app_type, database, '2.0.0') # ruby version for backup gem
  met? {
    app_type == 'rails' ? "/opt/#{app_name}/current/tmp/pids/unicorn.pid".p.exists? : "/opt/#{app_name}/tmp/pids/unicorn.pid".p.exists?
  }
  meet {
    shell "/etc/init.d/#{app_name} start"
  }
end
