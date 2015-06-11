require 'highline/import'

# -*- coding: utf-8 -*-
module LastMile::Deploy
  include LastMile::Utils  

  def create_shared_dir(name)
    queue! %[mkdir -p "#{deploy_to}/#{shared_path}/#{name}"]
    queue! %[chmod g+rx,u+rwx "#{deploy_to}/#{shared_path}/#{name}"]
  end

  def create_shared_file(file)
    queue! %[touch "#{deploy_to}/#{shared_path}/#{file}"]
    queue  %[echo "-----> Be sure to edit '#{deploy_to}/#{shared_path}/#{file}'."]
  end

  def create_db_commands
    [ "createuser -RSd #{appname}" ]
    [ "psql -d template1 --username=#{appname} -password -c 'CREATE DATABASE #{db_name}_#{rails_env}'" ]
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
