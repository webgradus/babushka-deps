meta :apt_repository do
  accepts_value_for :url
  accepts_value_for :distribution
  accepts_list_for  :components

  def sources_path
    '/etc/apt/sources.list'
  end

  def deb
    "deb #{url} #{distribution.blank? ? System.codename : distribution} #{components.join(' ')}"
  end

  template do
    met? { grep deb, sources_path }

    meet do
      log_block "Adding `#{deb}` to sources" do
        shell %{echo "#{deb}" >> #{sources_path}}, :sudo => true
      end
    end

    after { sudo 'apt-get update' }
  end
end