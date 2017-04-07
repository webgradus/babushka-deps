dep 'eye.running' do
  hostname = shell("hostname")
  requires 'eye.configured'.with(hostname)
  requires 'eye.scripted'
  met? {
    shell("ps -ef | grep eye") {|shell| shell.stdout.include?("eye monitoring") }
  }
  meet {
     shell "/etc/init.d/eye start"
  }
end

dep 'eye.installed' do
  met? {
    rvm_run_with_ruby("2.3.3", "gem list eye") {|shell| shell.stdout.include?("eye") }
  }
  meet {
    rvm_run_with_ruby "2.3.3", "gem install eye --no-rdoc --no-ri"
    # Eye Http on rubygems has issues, need to install from Github
    # rvm_run_with_ruby "2.3.3", "gem install eye-http --no-rdoc --no-ri"
    shell("git clone https://github.com/kostya/eye-http.git")
    cd "/root/eye-http" do
      shell("gem build eye-http.gemspec")
      shell("gem install eye-http-0.9.gem")
    end
    shell("rm -rf /root/eye-http")
    eye_lib_path = rvm_run_with_ruby "2.3.3", "gem which eye"
    #puts eye_lib_path
    #puts File.expand_path(eye_lib_path, "../bin/eye")
    shell("ln -sf #{File.expand_path(eye_lib_path, "../bin/eye")} /usr/local/bin/eye")
    shell("mkdir /root/eye")
  }
end

dep 'eye.configured', :hostname do
  requires 'eye.installed'
  met? {
    Babushka::Renderable.new("/root/eye/server.eye").from?(dependency.load_path.parent / "eye/server.eye.erb") &&
    Babushka::Renderable.new("/root/eye/extended_router.rb").from?(dependency.load_path.parent / "eye/extended_router.rb") &&
    Babushka::Renderable.new("/root/eye/extended_controller.rb").from?(dependency.load_path.parent / "eye/extended_controller.rb") &&
    Babushka::Renderable.new("/root/eye/http_decorator.rb").from?(dependency.load_path.parent / "eye/http_decorator.rb")
  }
  meet {
    render_erb "eye/server.eye.erb", :to => "/root/eye/server.eye"
    render_erb "eye/extended_router.rb", :to => "/root/eye/extended_router.rb"
    render_erb "eye/extended_controller.rb", :to => "/root/eye/extended_controller.rb"
    render_erb "eye/http_decorator.rb", :to => "/root/eye/http_decorator.rb"
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

dep 'eye-process.configured', :app_name, :app_type do
  met? {
    shell? "grep #{app_name} server.eye", :cd => "/root/eye"
  }
  meet {
    cd "/root/eye" do
        shell %Q{export p="process '#{app_name}' do
          pid_file #{app_type == 'rails' ? "'/opt/#{app_name}/shared/tmp/pids/unicorn.pid'" : "'/opt/#{app_name}/tmp/pids/unicorn.pid'"}
          start_command '/etc/init.d/#{app_name} start'
          restart_command '/etc/init.d/#{app_name} restart'
          stop_command '/etc/init.d/#{app_name} stop'
          restart_grace 30.seconds
          end" && awk -v proc="$p" '/Apps/{print;print proc;next}1' server.eye > server.tmp && mv server.tmp server.eye}
    end
    shell "/etc/init.d/eye restart"
  }
end
