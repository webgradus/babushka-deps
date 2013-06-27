dep 'foreman', :app_path, :use_faye? do
  use_faye?.default('no').choose(%w[yes no])
  met? {
    Babushka::Renderable.new(app_path / "Procfile.production").from?(dependency.load_path.parent / "foreman/Procfile.production.erb") &&
    shell %{ grep 'foreman' ./Gemfile }
  }
  meet {
    render_erb "foreman/Procfile.production.erb", :to => (app_path / "Procfile.production").to_s
    shell %{echo 'gem "foreman"' >> Gemfile}
    shell %{bundle install}
  }
end
