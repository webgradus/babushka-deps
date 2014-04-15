dep 'foreman', :app_path, :use_faye do
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
