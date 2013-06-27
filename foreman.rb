dep 'foreman', :app_path, :use_faye?, :foreman_in_gemfile? do
  use_faye?.default('no').choose(%w[yes no])
  foreman_in_gemfile = shell %{grep "foreman" Gemfile}.present?
  met? {
    Babushka::Renderable.new(app_path / "Procfile.production").from?(dependency.load_path.parent / "foreman/Procfile.production.erb") &&
    foreman_in_gemfile
  }
  meet {
    render_erb "foreman/Procfile.production.erb", :to => (app_path / "Procfile.production").to_s
    shell %{echo 'gem "foreman"' >> Gemfile}
    shell %{bundle install}
  }
end
