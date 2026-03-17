Rails.application.routes.draw do
  namespace :api do
    namespace :v1 do

      # Auth
      post   "auth/login",         to: "auth#login"
      delete "auth/logout",        to: "auth#logout"
      post   "auth/refresh",       to: "auth#refresh"
      get    "auth/me",            to: "auth#me"

      # Departments (admin)
      resources :departments, only: [:index, :show, :create, :update]

      # Users
      resources :users, only: [:index, :show, :create, :update, :destroy] do
        get :requests, on: :member
      end

      # Transport requests
      resources :transport_requests, only: [:index, :show, :create, :update, :destroy] do
        member do
          post :approve
          post :reject
        end
        resource  :assignment,          only: [:show, :create, :update]
        resources :trip_status_updates, only: [:index, :create]
      end

      # Vehicles
      resources :vehicles, only: [:index, :show, :create, :update, :destroy] do
        collection { get :available }
      end

      # Drivers
      resources :drivers, only: [:index, :show, :create, :update, :destroy] do
        collection { get :available }
        member     { get :assignments }
      end

      # Notifications
      resources :notifications, only: [:index, :show] do
        member { patch :mark_read }
      end

    end
  end
end