module LastMile::Utils
  def run_locally(cmd,opts = {})
    puts cmd

    if opts[:confirm]
      return unless agree("Execute? ")
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
    run_locally "rsync #{local} #{user}@#{domain}:#{remote}"
  end



end
