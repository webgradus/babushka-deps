dep 'redis installed', :version, :path do  
  version.default!('2.6.7')  
  source = "http://redis.googlecode.com/files/redis-#{version}.tar.gz"
  path.default!("/opt/redis-#{version}")
  
  met? { (path / "src/redis-server").exists? && File.executable?(path / "src/redis-server")}
  meet {      
      shell "wget #{source}", :cd => "/opt"
      shell "tar xzf redis-#{version}.tar.gz", :cd => "/opt"      
      shell "make", :cd => path    
  }
  
end
