dep 'stack' do
  requires 'running.nginx', 'postgres.managed', 'imagemagick.managed', 'redis', 'rvm', 'eye.running'
end
