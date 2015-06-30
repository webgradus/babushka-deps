dep 'backup-server', :ruby_version do
    ruby_version.default("2.2.2").choose(%w[2.2.2 2.1.6])
    met? {
        "~/Backup".p.exists?
        # Babushka::Renderable.new("~/Backup/config.rb").from?(dependency.load_path.parent / "backup-server/config.rb.erb")
    }
    meet {
        log "backup gem install..."
        rvm_run_with_ruby ruby_version, "gem install backup --no-rdoc --no-ri"
        rvm_run_with_ruby ruby_version, "backup generate:config"
        shell "mkdir models", :cd => "~/Backup/"

        log "whenever gem install..."
        rvm_run_with_ruby ruby_version, "gem install whenever --no-rdoc --no-ri"
        shell "mkdir config", :cd => "~/Backup/"
        cd "~/Backup/" do
            rvm_run_with_ruby ruby_version, "wheneverize ."
        end

        log "copy config file..."
        render_erb "backup-server/config.rb.erb", :to => ("~/Backup/config.rb").to_s
    }

end
