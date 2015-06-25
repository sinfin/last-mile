module LastMile::Utils
  def run_locally(cmd,opts = {})
    puts cmd

    if question = opts[:confirm]
      return unless agree(question)
    end

    unless system(cmd)
      puts 'Command failed.'
      exit
    end
  end

  def sudo_upload(local,remote)
    run_locally "rsync --rsync-path=\"sudo rsync\" #{local} #{user}@#{domain}:#{remote}"
  end

  def upload(local,remote)
    run_locally "rsync #{local} #{user}@#{droplet_config.fetch(:ipv4)}:#{remote}"
  end



end
