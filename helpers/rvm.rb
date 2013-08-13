def source_rvm
    log_shell("sourcing rvm", "source /usr/local/rvm/scripts/rvm")
end

def rvm_script
    "/usr/local/rvm/scripts/rvm"
end

def rvm_installed?
  "/usr/local/rvm".p.exists?
end

def rvm_run cmd    
    log_shell("rvm_run: #{cmd}", "source /usr/local/rvm/scripts/rvm; " + rvm_script + " " + cmd)    
end

def current_rubies
  out = rvm_run("list rubies")
  rubies = out.scan(/^[=> ]{3}([^ ]+) /).flatten
end
