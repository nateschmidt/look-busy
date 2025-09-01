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
  resources :goals
  
  # Ad hoc todos
  resources :ad_hoc_todos, only: [:create, :destroy]
  
  # Notes
  resources :notes, only: [:create]
  
  # Todo items
  resources :todo_items, only: [:create, :update]
  
  # Dashboard
  get 'dashboard/weekly', to: 'dashboard#weekly', as: :weekly_dashboard
  post 'dashboard/generate_todos', to: 'dashboard#generate_todos', as: :generate_todos
  delete 'dashboard/clear_todos', to: 'dashboard#clear_todos', as: :clear_todos

  # Defines the root path route ("/")
  root "pages#home"
end
