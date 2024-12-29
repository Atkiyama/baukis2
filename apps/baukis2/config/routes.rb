Rails.application.routes.draw do
  namespace :staff do
    root 'top#index'
    resources :staff_members
  end
  namespace :admin do
    root 'top#index'
    resources :staff_members
  end
  namespace :customer do
    root 'top#index'
  end
end
