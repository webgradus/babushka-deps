dep 'stack' do
  requires 'git.managed', 'running.nginx', 'mysql configured', 'postgres.managed', 'imagemagick.managed', 'rvm'
end
