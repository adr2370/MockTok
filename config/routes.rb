MockTok::Application.routes.draw do
  root :to => 'interviews#index'

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
