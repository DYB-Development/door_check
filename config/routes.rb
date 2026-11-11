DoorCheck::Engine.routes.draw do
  resource :second_step, only: %i[new create] do
    post :passkey
  end
  resource :authenticator, only: %i[new create]
  resource :backup_codes, only: :create
  resources :passkeys, only: %i[new create]
  resource :passkey_sign_in, only: %i[new create]
  resource :email_sign_in, only: %i[new create]
  resource :email_code, only: %i[new create]
  resource :approval_request, only: %i[new create show]
  resources :approvals, only: :index do
    member do
      post :approve
      post :decline
    end
  end
  get "email_link/:token", to: "email_links#show", as: :email_link
end
