# -*- coding: utf-8 -*-
require 'highline/import'

# -*- coding: utf-8 -*-
module LastMile::Deploy
  include LastMile::Utils

  def create_shared_dir(name)
    # FIXME: vytvoření adresářů (souborů) od doby odsunutí do last mile nefunguje (nic neudělá)
    puts queue! %[mkdir -p "#{deploy_to}/#{shared_path}"]
    puts queue! %[mkdir -p "#{deploy_to}/#{shared_path}/#{name}"]
    puts queue! %[chmod g+rx,u+rwx "#{deploy_to}/#{shared_path}/#{name}"]
  end

  def create_shared_file(file)
    queue! %[touch "#{deploy_to}/#{shared_path}/#{file}"]
    queue  %[echo "-----> Be sure to edit '#{deploy_to}/#{shared_path}/#{file}'."]
  end

  def create_production_db
    # ssh_as_postgres = Proc.new { |cmd|  run_locally("ssh root@db1.sinfin.io -C \"sudo -u postgres #{cmd}'\") }
    private_ip = droplet_config.fetch :ipv4_private
    password = SecureRandom.hex(10)
    db_user = appname
    db = "#{db_name}_#{rails_env}"

    puts %{
Please, do this manually:
------------------------------
*) Login to DB machine as `postgres` user

  ssh root@db1.sinfin.io
  su postgres
  cd ~

*) Execute

  createuser -RSd #{db_user}
  psql -d template1 -c "ALTER USER #{db_user} WITH PASSWORD '#{password}';"
  psql -d template1 -c 'CREATE DATABASE #{db} WITH OWNER #{db_user}'

*) Add line to /etc/postgresql/9.3/main/pg_hba.conf

  host    all             all             #{private_ip}/32        password

*) Restart DB (still with `postgres` user)

  service postgresql restart

*) Test it from droplet by

  psql -d #{db} -h #{private_ip} -U #{db_user} -W

*) Setup connection in config/deploy/production/database.yml and use 'mina setup' to upload it:

production:
  adapter: postgresql
  host: #{private_ip}
  username: #{db_user}
  password: #{password}
  database: #{db}
  encoding: utf8
  collation: cs_CZ.UTF8
  min_messages: warning
  pool: 2
  timeout: 5000

}
  end

  def foreman_export
    app_root = "/home/#{user}/#{appname}/current"
    dir = "./config/deploy/#{rails_env}"
    run_locally "mkdir -p #{dir}"
    run_locally "foreman export upstart #{dir} -a #{appname} --root #{app_root} --procfile ./Procfile -u #{user} --env #{dir}/.env"
    run_locally "chmod 600 #{dir}/*.conf"
  end

  def foreman_upload
    Dir["./config/deploy/#{rails_env}/*"].each do |file|
      sudo_upload file, "/etc/init"
    end
  end




end
