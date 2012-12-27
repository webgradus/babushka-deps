dep 'stack' do
  requires 'running.nginx', 'mysql configured', 'postgres.managed', 'latest mongo', 'imagemagick.managed', 'redis installed', 'rvm'
end
