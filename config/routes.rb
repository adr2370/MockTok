MockTok::Application.routes.draw do
  get "pages/signup"

  root :to => 'interviews#index'
  match '/signup', to: 'pages#signup'

  resources :users

  resources :interviews do
    collection do
      get 'findOpenInterview'
      post 'findOpenInterview'
      get 'goToInterviewIfReady'
      post 'goToInterviewIfReady'
    end
  end

end
