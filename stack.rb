dep 'stack' do
  requires 'running.nginx', 'postgres.managed', 'imagemagick.managed', 'redis', 'rvm', 'eye.running'
end
dep 'light-stack' do
  requires 'running.nginx', 'postgres.managed', 'imagemagick.managed', 'rvm', 'eye.running'
end
