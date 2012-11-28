require File.expand_path("../helpers/rvm.rb", __FILE__)

# alias for "rvm configured"
dep 'rvm' do 
  requires 'rvm configured'
end

# installs rvm with a user-defined ruby and user-defined global gems
dep 'rvm configured' do
  requires 'sh is bash', # sourcing rvm requires a "normal" shell, not s.th. like dash
    'rvm installed',
    'rvm default ruby is set'
    'rvm defaults are installed'
end

# installs rvm
dep 'rvm installed' do
  met? {
    "~/.rvm/scripts/rvm".p.file?
  }

  meet {
    shell 'curl -L get.rvm.io | bash -s stable'
  }
end

# ensure a default ruby is set 
dep 'rvm default ruby is set' do
  requires 'rvm installed'
  define_var :default_ruby, :choices => current_rubies, :message => "Which ruby do you what to use as default?"
  
  met?{rvm_run("rvm current")[/system/] == nil}

  meet do
    while current_rubies.empty?
      ruby = prompt_for_value "You need at least one ruby installed. Which one do you want to install?", :default => "1.9.2"
      rvm_run "rvm install #{ruby}"
    end
    if current_rubies.length == 1
      default_ruby = current_rubies[0]
    else
      default_ruby = var :default_ruby
    end
    
    rvm_run("rvm use #{default_ruby} --default") 
  end
end

# install default rubies and gems
dep 'rvm defaults are installed' do
  requires 'rvm base'

  define_var :rubyies, :default => "ruby-1.9.2", :message => "which rubies do you want to create? (seperate by ,)"
  define_var :gems, :default => "bundler, rake, gemedit, powder, pry", :message => "which gems do you want to install into global? (seperate by ,)"


  def rubies
    var(:rubies).split(/ *, */)
  end

  def gems
    var(:gems).split(/ *, */)
  end

  met? {
    # are all required rubies installed?
    ruby_list = `#{rvm_script} rvm list rubies`
    missing = rubies.select{|r| ruby_list[/#{r}/] == nil}
      unless missing.empty?
	false
      else
	# are all required gems installed?
	result = true;
	rubies.each do |r|
	  list = `#{rvm_script} rvm use #{r}@global;gem list`

	  # are all gems in the gemset?
	  missing = gems.select{|e| list[/#{e}/] == nil}
	    result = false and break unless missing.empty?
	end
      end
  }

  meet {
    # log("run: rvm install 1.9.2") and STDIN.gets

    rubies.each do |r|
    log "installing ruby: #{r}"
    rvm_run "rvm install #{r}"
    log "installing gems"
    rvm_run "rvm use --create #{r}@global;" +
      "gem install #{gems.join(' ')}"
    end

  }
end

