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
    port = 22 unless port
    run_locally "rsync -e 'ssh -p #{port}' --rsync-path=\"sudo rsync\" #{local} #{user}@#{domain}:#{remote}"
  end

  def upload(local,remote)
    port = 22 unless port
    run_locally "rsync -e 'ssh -p #{port}' #{local} #{user}@#{domain}:#{remote}"
  end

  def download(remote,local)
    port = 22 unless port
    run_locally "rsync -e 'ssh -p #{port}' #{user}@#{domain}:#{remote} #{local}"
  end



end
