dep 'stack' do
  requires 'running.nginx', 'postgres.managed', 'latest mongo', 'imagemagick.managed', 'redis', 'rvm'
end
