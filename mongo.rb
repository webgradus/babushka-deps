dep 'latest mongo' do
  requires 'mongo.apt_repository', 'mongo.managed'
end

dep 'mongo.apt_repository' do
  url "http://downloads-distro.mongodb.org/repo/debian-sysvinit"
  distribution " "
  components "dist", "10gen"

  after do
    sudo "apt-key adv --keyserver keyserver.ubuntu.com --recv 7F0CEB10"
    sudo 'apt-get update'
  end
end

dep 'mongo.managed' do
  installs { via :apt, 'mongodb-org' }
  provides 'mongo'
  provides 'mongod'
end
