Rails.application.routes.draw do
  root 'home#index'

  # API routes
  # namespace :api do
  # end

  # Catch-all route for Next.js pages
  get '*path', to: 'home#index', constraints: lambda { |req|
    !req.xhr? && req.format.html?
  }
end
