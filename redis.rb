dep 'redis.src', :version, :path do  
  version.default!('2.6.7')  
  source "http://redis.googlecode.com/files/redis-#{version}.tar.gz"
  path.default!("/opt/redis-#{version}")
  
  met? { (path / "src/redis-server").exists? && File.executable?(path / "src/redis-server")}
  meet {
    cd "/opt" do
      shell "wget #{source}"
      shell "tar xzf redis-#{version}.tar.gz"
      shell "cd redis-#{version}"
      shell "make"
    end
  }
  
end
