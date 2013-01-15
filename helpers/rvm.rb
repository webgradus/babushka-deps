def rvm_script
    "source /usr/local/rvm/scripts/rvm"
end

def rvm_installed?
  "/usr/local/rvm".p.exists?
end

def rvm_run cmd    
    shell("chsh -s /bin/bash && " + rvm_script + " && " + cmd)    
end

def current_rubies
  out = rvm_run("rvm list rubies")
  rubies = out.scan(/^[=> ]{3}([^ ]+) /).flatten
end
