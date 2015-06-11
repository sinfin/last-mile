# -*- coding: utf-8 -*-
require 'droplet_kit'


module LastMile::DigitalOcean


  def droplet_config
    @droplet_config ||= YAML.load_file(do_config_path)
  end


  # FIXME: update image_id
  def create_droplet(name, image_id = 11397076)
    client = DropletKit::Client.new(access_token: token)

    unless token = ENV.fetch("DIGITAL_OCEAN_TOKEN")
      raise "Missing DIGITAL_OCEAN_TOKEN in the environment"
    end

    if client.droplets.all.find { |droplet| droplet.name == name }
      puts "Droplet already exists."
      return
    end

    ssh_keys = client.ssh_keys.all.map{|key| key.id}
    droplet_new = DropletKit::Droplet.new(name: name,
                                          region: 'ams3',
                                          image: image_id,
                                          size: '512mb',
                                          ipv6: true,
                                          private_networking: true,
                                          ssh_keys: ssh_keys)

    puts "Creating droplet #{name}..."
    droplet = client.droplets.create(droplet_new)

    while droplet.networks.v4.size == 0
      putc "."; sleep 1
      droplet = client.droplets.find(id: droplet.id)
    end

    droplet_conf = {
      ipv4: 'TODO',
      ipv4_private: droplet.networks.v4.first.ip_address,
      ipv6: droplet.networks.v6.first.ip_address,
      domain: name
    }

    # TODO Setup private network

    # Write down conf
    File.open(do_config_path, 'w') { |f| YAML.dump(droplet_conf, f) }
    system "cat #{do_config_path}"
    puts "Done and written to #{do_config_path}!"
  end

  private
  
  def do_config_path
    "config/deploy/#{rails_env}/droplet.yml"
  end

end
