require_relative "./last_mile/utils"
require_relative "./last_mile/version"
require_relative "./last_mile/deploy"
require_relative "./last_mile/digital_ocean"


module LastMile
  include LastMile::DigitalOcean
  include LastMile::Deploy
end
