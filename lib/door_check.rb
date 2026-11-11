require "keystone_ui"
require "rotp"
require "rqrcode"
require "door_check/version"
require "door_check/configuration"
require "door_check/engine"

module DoorCheck
  class << self
    attr_writer :configuration

    def configuration = @configuration ||= Configuration.new

    def configure = yield(configuration)
  end
end
