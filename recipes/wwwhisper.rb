module Recipes
  def wwwhisper
    run 'heroku addons:create wwwhisper:starter'
    enable_gem 'rack-wwwhisper', :production
    pro "config.middleware.insert 0, 'Rack::WWWhisper'"
    say 'Add other user at: https://*.herokuapp.com/wwwhisper/admin/'
  end
end
