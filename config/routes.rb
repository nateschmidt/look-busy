Rails.application.routes.draw do
  get 'todo_items/create'
  get 'todo_items/update'
  get 'notes/create'
  devise_for :users, skip: [:registrations]
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  # Recurring meetings
  resources :recurring_meetings
  
  # Goals
  resources :goals do
    member do
      patch :toggle_active
    end
  end
  
  # Ad hoc todos
  resources :ad_hoc_todos, only: [:create, :destroy]
  
  # Profiles
  resource :profile, only: [:show, :edit, :update]
  
  # Notes
           resources :notes, only: [:create, :update]
  
  # Todo items
           resources :todo_items, only: [:create, :update, :destroy] do
           member do
             get :notes
           end
         end
  
  # Dashboard
           get 'dashboard/weekly', to: 'dashboard#weekly', as: :weekly_dashboard
         get 'dashboard/weekly_report', to: 'dashboard#weekly_report', as: :weekly_report
         get 'dashboard/search', to: 'dashboard#search', as: :search_dashboard
         post 'dashboard/generate_weekly_todos', to: 'dashboard#generate_weekly_todos', as: :generate_weekly_todos
         delete 'dashboard/clear_todos', to: 'dashboard#clear_todos', as: :clear_todos

  # Defines the root path route ("/")
  root "pages#home"
end
