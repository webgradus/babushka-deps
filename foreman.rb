dep 'foreman', :app_path, :use_faye, :web_server do
  foreman_in_gemfile = shell? %{grep "foreman" Gemfile}, :cd => app_path
  met? {
    Babushka::Renderable.new(app_path / "Procfile.production").from?(dependency.load_path.parent / "foreman/Procfile.production.erb") &&
    foreman_in_gemfile
  }
  meet {
    render_erb "foreman/Procfile.production.erb", :to => (app_path / "Procfile.production").to_s
    cd app_path do
        shell %{echo 'gem "foreman"' >> Gemfile}
        shell %{echo 'gem "foreman-export-initscript", :github => "webgradus/foreman-export-initscript"' >> Gemfile}
        shell %{bundle install}
    end
    foreman_in_gemfile = shell? %{grep "foreman" Gemfile}, :cd => app_path
  }
end

dep 'foreman.export', :app_path, :use_faye, :web_server do
  requires 'foreman'.with(app_path, use_faye, web_server)
  app_name = app_path.to_s.split("/")[-1]
  met? {
    "/etc/init/#{app_name}".p.exists?
  }
  meet {
    cd app_path do
      # shell "bundle exec foreman export initscript /etc/init.d -f ./Procfile.production -a #{app_name} -u root -l /opt/#{app_name}/log"
      shell "bundle exec foreman export upstart /etc/init -a #{app_name} -u root -l /opt/#{app_name}/log"
      # shell "chmod 755 /etc/init.d/#{app_name}"
    end
  }
end

dep 'foreman.start', :app_path, :use_faye, :web_server do
  requires 'foreman.export'.with(app_path, use_faye, web_server)
  app_name = app_path.to_s.split("/")[-1]
  met? {
    "/run/#{app_name}/web.1.pid".p.exists?
  }
  meet {
    # shell "/etc/init.d/#{app_name} start"
    shell "service #{app_name} start"
  }
end
