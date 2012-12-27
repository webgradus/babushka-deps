dep 'redis', :version, :path do
  requires 'redis installed'.with(version, path)
  requires 'redis-init-script'
end

dep 'redis installed', :version, :path do  
  version.default!('2.6.7')  
  source = "http://redis.googlecode.com/files/redis-#{version}.tar.gz"
  path.default!("/opt/redis-#{version}")
  
  met? { (path / "src/redis-server").exists? && File.executable?(path / "src/redis-server")}
  meet {      
      shell "wget #{source}", :cd => "/opt"
      shell "tar xzf redis-#{version}.tar.gz", :cd => "/opt"      
      shell "make", :cd => path    
      shell "rm redis-#{version}.tar.gz", :cd => "/opt"
  }
  
end

dep 'redis-init-script copied' do  
  met? {    
    Babushka::Renderable.new("/etc/init.d/redis").from?(dependency.load_path.parent / "init/init_redis.sh.erb")
  }
  meet {    
    render_erb "init/init_redis.sh.erb", :to => "/etc/init.d/redis", :perms => '755', :sudo => true    
  }
  
end

dep 'redis-init-script' do  
  requires 'redis-init-script copied'
  requires 'rcconf.managed'
  
  met? { shell("rcconf --list").val_for('redis') == 'on' }
  meet {
    sudo "update-rc.d redis defaults"
  }
end
