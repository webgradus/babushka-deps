dep 'backup-server' do
    met? {
        Babushka::Renderable.new("~/Backup/config.rb").from?(dependency.load_path.parent / "backup-server/config.rb.erb")
    }
    meet {
        log "backup gem install..."
        shell "gem install backup"
        shell "backup generate:config"
        shell "mkdir models", :cd => "~/Backup/"

        log "whenever gem install..."
        shell "gem install whenever"
        shell "mkdir config", :cd => "~/Backup/"
        shell "wheneverize .", :cd => "~/Backup/"

        log "copy config file..."
        render_erb "backup-server/config.rb.erb", :to => ("~/Backup/config.rb").to_s
    }

end
