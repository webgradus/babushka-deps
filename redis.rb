dep 'redis.src', :version do  
  version.default!('2.6.7')  
  source "http://redis.googlecode.com/files/redis-#{version}.tar.gz"    
  prefix '/opt/redis'
  provides prefix / 'src/redis-server'

  configure {  }
  build { log_shell "build", "make" }
  install {  }

  met? {
    if !File.executable?(prefix / 'src/redis-server')
      log "redis isn't installed"
    else
      installed_version = shell(prefix / 'src/redis-server -v') {|shell| shell.stderr }.val_for(/Redis server version/).sub('(00000000:0)', '')
      (installed_version == version).tap {|result|
        log "redis-#{installed_version} is installed"
      }
    end
  }
end
