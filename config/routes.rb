Rails.application.routes.draw do
  root 'home#index'

  # API routes
  namespace :api do
    namespace :v1 do
      resources :conversations, only: [:create, :index, :show] do
        resources :messages, only: [:create, :index]
      end
    end
  end

  # Catch-all route for Next.js pages
  get '*path', to: 'home#index', constraints: lambda { |req|
    !req.xhr? && req.format.html?
  }
end
