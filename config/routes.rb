Rails.application.routes.draw do
  post '/submissions', to: 'formsg#submissions'
  # For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html
end
