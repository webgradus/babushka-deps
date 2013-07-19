dep 'backup-server' do
    log "backup gem install..."
    shell "gem install backup"
    shell "backup generate:config"
    shell "mkdir models", :cd => "/root/Backup/"

    log "whenever gem install..."
    shell "gem install whenever"
    shell "mkdir config", :cd => "/root/Backup/"
    shell "wheneverize .", :cd => "/root/Backup/"

    log "copy config file..."
    met? {
        Babushka::Renderable.new("/root/Backup/config.rb").from?(dependency.load_path.parent / "backup-server/config.rb.erb")
    }
    meet {
        render_erb "backup-server/config.rb.erb", :to => ("/root/Backup/config.rb").to_s
    }
    
end
