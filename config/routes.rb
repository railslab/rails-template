Rails.application.routes.draw do
  match 'dev(/:action(/:id))', controller: 'dev', via: :all
end
