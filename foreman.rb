dep 'foreman', :app_path, :use_faye do
  foreman_in_gemfile = shell? %{grep "foreman" Gemfile}
  met? {
    Babushka::Renderable.new(app_path / "Procfile.production").from?(dependency.load_path.parent / "foreman/Procfile.production.erb") &&
    foreman_in_gemfile
  }
  meet {
    render_erb "foreman/Procfile.production.erb", :to => (app_path / "Procfile.production").to_s
    shell %{echo 'gem "foreman"' >> Gemfile}
    shell %{echo 'gem "foreman-export-initscript", :git => "git@github.com:mixan946/foreman-export-initscript.git"' >> Gemfile}
    shell %{bundle install}
  }
end
