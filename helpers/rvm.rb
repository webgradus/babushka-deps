def rvm_script
    "rvm" #/usr/local/rvm/scripts/rvm"
end

def rvm_installed?
  "/usr/local/rvm".p.exists?
end

def rvm_run cmd
    log_shell("rvm_run: #{cmd}", rvm_script + " " + cmd)
end

def rvm_run_with_ruby ruby_version, cmd, &block
    log_shell("rvm_run: #{cmd}", rvm_script + " use #{ruby_version} do " + cmd, &block)
end

def rvm_shell cmd
    log_shell("rvm shell: #{cmd}", "rvm-shell -c '#{cmd}'")
end

def current_rubies
  out = rvm_run("list rubies")
  rubies = out.scan(/^[=> ]{3}([^ ]+) /).flatten
end
