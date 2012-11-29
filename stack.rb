dep 'stack' do
  requires 'running.nginx', 'mysql configured', 'postgres.managed', 'imagemagick.managed', 'rvm'
end
