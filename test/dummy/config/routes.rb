Rails.application.routes.draw do
  mount DoorCheck::Engine => "/door_check"

  post "sign_in", to: "sessions#create"
  delete "sign_out", to: "sessions#destroy"
  get "proofs", to: "sessions#proofs"
end
