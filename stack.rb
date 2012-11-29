dep 'stack' do
  requires 'running.nginx', 'mysql configured', 'postgres.managed', 'latest mongo', 'imagemagick.managed', 'rvm'
end
