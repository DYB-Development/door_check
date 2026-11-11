DoorCheck::Engine.routes.draw do
  resource :second_step, only: %i[new create]
  resource :authenticator, only: %i[new create]
  get "email_link/:token", to: "email_links#show", as: :email_link
end
