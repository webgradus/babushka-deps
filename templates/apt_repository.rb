meta :apt_repository do
  accepts_value_for :url
  accepts_value_for :distribution
  accepts_list_for  :components

  def sources_path
    '/etc/apt/sources.list'
  end

  def deb
    "deb #{url} #{distribution.blank? ? SystemDetector.profile_for_host.name : distribution} #{components.join(' ')}"
  end

  template do
    met? { sources_path.p.grep(deb) }

    meet do
      log_block "Adding `#{deb}` to sources" do
        shell %{echo "#{deb}" >> #{sources_path}}, :sudo => true
      end
    end

    after { sudo 'apt-get update' }
  end
end