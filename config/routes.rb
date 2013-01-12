MockTok::Application.routes.draw do
  get "pages/signup"

  root :to => 'pages#signup'
  match '/signup', to: 'pages#signup'

  resources :users do
    collection do
      get 'login_or_create'
      post 'login_or_create'
    end
  end

  resources :interviews do
    collection do
      get 'findOpenInterview'
      post 'findOpenInterview'
      get 'goToInterviewIfReady'
      post 'goToInterviewIfReady'
      get 'waiting'
      post 'waiting'
    end
  end

end
