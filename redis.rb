dep 'redis', :version, :path do
  requires 'tcl.bin'
  requires 'redis installed'.with(version, path)
  requires 'redis-init-script'
end

dep 'redis installed', :version, :path do  
  version.default!('3.2.8')  
  source = "http://download.redis.io/releases/redis-#{version}.tar.gz"
  path.default!("/opt/redis-#{version}")
  
  met? { (path / "src/redis-server").exists? && File.executable?(path / "src/redis-server")}
  meet {      
      shell "wget #{source}", :cd => "/opt"
      shell "tar xzf redis-#{version}.tar.gz", :cd => "/opt"      
      shell "make", :cd => path
      shell "make test", :cd => path
      shell "make install", :cd => path
      shell "rm redis-#{version}.tar.gz", :cd => "/opt"
      shell "./install_server.sh", :cd => (path / "utils")
      #shell "cp src/redis-server src/redis-cli /usr/bin", :cd => path
      #shell "mkdir /etc/redis"
      #shell "cp redis.conf /etc/redis/", :cd => path
      #shell "groupadd redis"
      #shell "useradd -l -g redis redis"
      #shell "touch /var/log/redis.log"
      #shell "chown redis:redis /var/log/redis.log"
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
  #requires 'redis-init-script copied'
  requires 'rcconf.bin'
  
  met? { shell("rcconf --list").val_for('redis_6379') == 'on' }
  meet {
    sudo "update-rc.d redis_6379 defaults"
  }
end
