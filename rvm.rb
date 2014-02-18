require File.expand_path("../helpers/rvm.rb", __FILE__)

dep 'rvm_requirements.lib' do
  installs {
    via :apt, %w[build-essential openssl libreadline6 libreadline6-dev curl zlib1g zlib1g-dev libssl-dev libyaml-dev libsqlite3-dev sqlite3 libxml2-dev libxslt1-dev autoconf libc6-dev libncurses5-dev automake libtool bison subversion]
  }
end

# alias for "rvm configured"
dep 'rvm' do
  requires 'rvm configured'
end

dep 'sh is bash' do
  met? { raw_shell("echo $SHELL").stdout == "/bin/bash\n" }
  meet {
  	shell("chsh -s /bin/bash")
  }
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
    "/usr/local/rvm/scripts/rvm".p.file?
  }

  meet {
    shell 'curl -sSL https://get.rvm.io | bash -s stable'
    shell "echo 'source /usr/local/rvm/scripts/rvm' >> ~/.bashrc"
    shell "source '/usr/local/rvm/scripts/rvm'"
  }
end

# ensure a default ruby is set
dep 'rvm default ruby is set', :default_ruby do
  requires 'sh is bash', 'rvm installed', 'rvm_requirements.lib'
  default_ruby.ask("Which ruby do you what to use as default?").choose(current_rubies)

  met?{rvm_run("current")[/system/] == nil}

  meet do
    while current_rubies.empty?
      ruby = Babushka::Prompt.get_value("You need at least one ruby installed. Which one do you want to install?", :default => "2.0.0")
      rvm_run "install #{ruby}"
    end
    if current_rubies.length == 1
      default_ruby = current_rubies[0]
    else
      default_ruby = default_ruby
    end

    rvm_run("alias create default #{default_ruby}")
  end
end

# install default rubies and gems
dep 'rvm defaults are installed' do
  requires 'rvm base'

  define_var :rubies, :default => "ruby-2.0.0", :message => "which rubies do you want to create? (seperate by ,)"
  define_var :gems, :default => "bundler, rake, gemedit, powder, pry", :message => "which gems do you want to install into global? (seperate by ,)"


  def rubies
    var(:rubies).split(/ *, */)
  end

  def gems
    var(:gems).split(/ *, */)
  end

  met? {
    # are all required rubies installed?
    ruby_list = `#{rvm_script} list rubies`
    missing = rubies.select{|r| ruby_list[/#{r}/] == nil}
      unless missing.empty?
	false
      else
	# are all required gems installed?
	result = true;
	rubies.each do |r|
	  list = `#{rvm_script} use #{r};gem list`

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
    rvm_run "install #{r}"
    log "installing gems"
    rvm_run "use #{r};" +
      "gem install #{gems.join(' ')}"
    end

  }
end

