DoorCheck::Engine.routes.draw do
  resource :second_step, only: %i[new create]
end
