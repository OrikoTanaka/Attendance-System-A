Rails.application.routes.draw do
  
  root 'static_pages#top'
  get '/signup', to: 'users#new'

  # ログイン機能
  get    '/login', to: 'sessions#new'
  post   '/login', to: 'sessions#create'
  delete '/logout', to: 'sessions#destroy'

  resources :users do
    member do
      get 'edit_user_info'
      patch 'update_user_info' 
      get 'attendances/edit_one_month'
      patch 'attendances/update_one_month'
    end
    collection do
      post 'import' # csvインポート
      get 'working_list' # 出勤社員一覧ページ
      get 'edit_basic_info' # 基本情報修正ページ
    end
    resources :attendances, only: :update
  end

  # 拠点情報機能
  resources :bases do
    member do
      get 'edit_bases_info'
      patch 'update_bases_info'
    end
  end

  
end