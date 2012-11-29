dep 'existing postgres db', :username, :db_name do
  requires 'postgres access'.with(username)
  met? {
    !shell("psql -l") {|shell|
      shell.stdout.split("\n").grep(/^\s*#{db_name}\s+\|/)
    }.empty?
  }
  meet {
    shell "createdb -O '#{username}' '#{db_name}'"
  }
end

dep 'existing data', :username, :db_name do
  requires 'existing postgres db'.with(username, db_name)
  met? {
    shell("psql #{db_name} -c '\\d'").scan(/\((\d+) rows?\)/).flatten.first.tap {|rows|
      if rows && rows.to_i > 0
        log "There are already #{rows} tables."
      else
        unmeetable! <<-MSG
The '#{db_name}' database is empty. Load a database dump with:
$ cat #{db_name} | ssh #{username}@#{shell('hostname -f')} 'psql #{db_name}'
        MSG
      end
    }
  }
end

dep 'pg.gem' do
  requires 'postgres.managed'
  provides []
end

dep 'postgres access', :username do
  requires 'postgres.managed', 'user exists'.with(:username => username)
  met? { !sudo("echo '\\du' | #{which 'psql'}", :as => 'postgres').split("\n").grep(/^\W*\b#{username}\b/).empty? }
  meet { sudo "createuser -SdR #{username}", :as => 'postgres' }
end

dep 'postgres backups' do
  requires 'postgres.managed'
  met? { shell? "test -x /etc/cron.hourly/psql_git" }
  meet {
    render_erb 'postgres/psql_git.rb.erb', :to => '/usr/local/bin/psql_git', :perms => '755', :sudo => true
    sudo "ln -sf /usr/local/bin/psql_git /etc/cron.hourly/"
  }
end

dep 'postgres.apt_repository' do
  url "http://pgapt.debian.net"
  distribution "squeeze-pgdg"
  components "main"

  after do
    sudo "wget -q http://pgapt.debian.net/ACCC4CF8.asc -O- | apt-key add -"
    sudo 'apt-get update'
  end
end

dep 'postgres.managed', :version do
  version.default('9.2')
  # Assume the installed version if there is one
  #version.default!(shell('psql --version').val_for('psql (PostgreSQL)')[/^\d\.\d/]) if which('psql')
  requires 'set.locale'
  requires_when_unmet 'postgres.apt_repository'
  
  installs {
    shell %q{sudo apt-get install -t squeeze-pgdg postgresql-#{owner.version} libpq-dev}
  }
  provides "psql ~> #{version}.0"
end
