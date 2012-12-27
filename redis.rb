dep 'redis.src', :version do  
  version.default!('2.6.7')  
  source "http://redis.googlecode.com/files/redis-#{version}.tar.gz"        
  
  met? { "/opt/redis-#{version}/src/redis-server".exists? && File.executable?("/opt/redis-#{version}/src/redis-server")}
  meet {
    cd "/opt" do
      shell "wget #{source}"
      shell "tar xzf redis-#{version}.tar.gz"
      shell "cd redis-#{version}.tar.gz"
      shell "make"
    end
  }
  
end
