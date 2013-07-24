dep 'imagemagick.managed' do
  provides %w[compare animate convert composite conjure import identify stream display montage mogrify]
end

dep 'libssl.lib' do
  installs {
    via :apt, 'libssl-dev'
    via :yum, 'openssl-devel'
  }  
end

dep 'libxml.lib' do
  installs { via :apt, 'libxml2-dev' }  
end

dep 'libxslt.lib' do
  installs { via :apt, 'libxslt1-dev' }
end

dep 'logrotate.managed'

dep 'ncurses.lib' do
  installs {
    via :apt, 'libncurses5-dev', 'libncursesw5-dev'
    via :macports, 'ncurses', 'ncursesw'
  }  
end

dep 'pcre.lib' do
  installs {
    via :brew, 'pcre'
    via :macports, 'pcre'
    via :apt, 'libpcre3-dev'
    via :yum, 'pcre-devel'
  }  
end

dep 'readline.lib' do
  installs {
    on :lenny, 'libreadline5-dev'
    via :apt, 'libreadline6-dev'
  }  
end

dep 'rcconf.bin' do
  requires 'whiptail.bin'
end

dep 'tcl.bin' do
  installs { via :apt, 'tcl8.5' }
end


dep 'unzip.bin'

dep 'whiptail.bin'

dep 'yaml.lib' do
  installs {
    via :brew, 'libyaml'
    via :apt, 'libyaml-dev'
  }  
end

dep 'zlib.lib' do
  installs {
    via :apt, 'zlib1g-dev'
    via :yum, 'zlib-devel'
  }  
end
