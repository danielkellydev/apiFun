Rails.application.routes.draw do
  devise_for :users
  get 'news_view', to: 'pages#news_view'
  get 'nookal_view', to: 'pages#nookal_view', as: 'nookal_view'
  root 'pages#index'
  resources :clients, only: [:index]
  get 'fetch_cases', to: 'pages#fetch_cases'
  post 'create_note', to: 'pages#create_note', as: 'create_note'
end