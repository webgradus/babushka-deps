dep 'backup-server' do
    met? {
        Babushka::Renderable.new("~/Backup/config.rb").from?(dependency.load_path.parent / "backup-server/config.rb.erb")
    }
    meet {
        log "backup gem install..."
        rvm_run_with_ruby "2.0.0", "gem install backup"
        rvm_run_with_ruby "2.0.0", "backup generate:config"
        shell "mkdir models", :cd => "~/Backup/"

        log "whenever gem install..."
        rvm_run_with_ruby "2.0.0", "gem install whenever"
        shell "mkdir config", :cd => "~/Backup/"
        cd "~/Backup/" do
            rvm_run_with_ruby "2.0.0", "wheneverize ."
        end

        log "copy config file..."
        render_erb "backup-server/config.rb.erb", :to => ("~/Backup/config.rb").to_s
    }

end
