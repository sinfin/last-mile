module LastMile
  require_relative "./last_mile/utils"
  require_relative "./last_mile/version"
  require_relative "./last_mile/deploy"
  require_relative "./last_mile/digital_ocean"
  
  include LastMile::DigitalOcean
  include LastMile::Deploy
end
