DoorCheck::Engine.routes.draw do
  resource :second_step, only: %i[new create]
  resource :authenticator, only: %i[new create]
end
