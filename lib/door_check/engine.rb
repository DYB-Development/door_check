module DoorCheck
  class Engine < ::Rails::Engine
    isolate_namespace DoorCheck

    initializer "door_check.importmap", before: "importmap" do |app|
      app.config.importmap.paths << root.join("config/importmap.rb") if app.config.respond_to?(:importmap)
    end
  end
end
