MockTok::Application.routes.draw do
  get "pages/signup"

  root :to => 'pages#signup'
  match '/signup', to: 'pages#signup'
  match '/interviews/auth', to: 'interviews#auth'
  match '/interviews/webhook', to: 'interviews#webhook'

  resources :users do
    collection do
      get 'login_or_create'
      post 'login_or_create'
      get 'playback'
      post 'playback'
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
      get 'interview_done'
      post 'interview_done'
      get 'review'
      post 'review'
      get 'interviewer_review'
      post 'interviewer_review'
      get 'interviewee_review'
      post 'interviewee_review'
    end
  end

end
