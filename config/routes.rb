Rails.application.routes.draw do
  get 'dev(/:action(/:id))', controller: 'dev'
end
