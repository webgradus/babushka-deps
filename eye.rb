dep 'eye.running' do
  requires 'eye.configured', 'eye.scripted'
  met? {
    shell("ps -ef | grep eye") {|shell| shell.stdout.include?("eye monitoring") }
  }
  meet {
     shell "/etc/init.d/eye start"
  }
end

dep 'eye.installed' do
  met? {
    rvm_run_with_ruby("2.0.0", "gem list eye") {|shell| shell.stdout.include?("eye") }
  }
  meet {
    rvm_run_with_ruby "2.0.0", "gem install eye --no-rdoc --no-ri"
    eye_lib_path = rvm_run_with_ruby "2.0.0", "gem which eye"
    puts eye_lib_path
    puts File.expand_path(eye_lib_path, "../bin/eye")
    shell("ln -sf #{File.expand_path(eye_lib_path, "../bin/eye")} /usr/local/bin/eye")
  }
end

dep 'eye.configured' do
  requires 'eye.installed'
  hostname = shell("hostname")
  met? {
    Babushka::Renderable.new("/root/eye/server.eye").from?(dependency.load_path.parent / "eye/server.eye.erb")
  }
  meet {
    render_erb "eye/server.eye.erb", :to => "/root/eye/server.eye"
  }
end

dep 'eye.scripted' do
  requires 'rcconf.bin'
  met? {
    Babushka::Renderable.new("/etc/init.d/eye").from?(dependency.load_path.parent / "eye/init.erb")
  }
  meet {
    render_erb "eye/init.erb", :to => "/etc/init.d/eye", :perms => '755', :sudo => true
    sudo "update-rc.d eye defaults"
  }
end

