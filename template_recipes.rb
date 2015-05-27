require_relative './template_helpers'

def git_init
  git :init
  git_ignore '/.idea/'
  # git_add_commit 'init'
end

def add_ruby_version_to_gemfile
  version = run_capture 'rbenv global'
  insert_into_file 'Gemfile',
                   "ruby '#{version}'",
                   after: /source .+\n/
end

def tools
  gem_group :development do
    gem 'thin'
    gem 'bump',                 require: false # https://github.com/gregorym/bump#usage
    gem 'rubocop',              require: false # https://github.com/bbatsov/rubocop#installation
    gem 'brakeman',             require: false # https://github.com/presidentbeef/brakeman
    gem 'annotate'                             # https://github.com/ctran/annotate_models
    gem 'pry-rails'                            # https://github.com/rweng/pry-rails
    gem 'overcommit',           require: false # https://github.com/brigade/overcommit
    gem 'did_you_mean'
    # http://guides.rubyonrails.org/debugging_rails_applications.html
    gem 'meta_request' # logger.debug          # https://github.com/dejan/rails_panel
    gem 'rails_db_info' # GET /rails/info/db   # https://github.com/yuki24/did_you_mean#nomethoderror
    gem 'guard-livereload',     require: false # https://github.com/guard/guard-livereload#install
    gem 'rails_best_practices', require: false # https://github.com/railsbp/rails_best_practices
    # gem 'rubocop-select',     require: false # https://github.com/packsaddle/rubocop-select
  end

  mirror '.rubocop.yml'
  mirror '.overcommit.yml'
  mirror 'lib/tasks/auto_annotate_models.rake'
  mirror 'lib/tasks/reset_counter_cache.rake'
end

def gem_lograge
  gem 'lograge'
  application 'config.lograge.enabled = true'
end

def gem_slim
  gem 'slim-rails'
  dev 'Slim::Engine.set_options pretty: true'
end

def gem_extras
  gem 'email_validator'
end

def remove_sqlit3_from_production
  gsub_file 'Gemfile',
            "gem 'sqlite3'\n",
            "gem 'sqlite3', group: [:development, :test]\n"
end

def timezone_brasilia
  application "config.time_zone = 'Brasilia'"
end

def default_locale_br
  application "config.i18n.default_locale = :'pt-BR'"
  gem 'rails-i18n'
end

def raise_unpermitted_parameters_on_dev
  dev 'config.action_controller.action_on_unpermitted_parameters = :raise'
end

def local_mailer
  dev "config.action_mailer.default_url_options = { host: 'localhost', port: 3000 }"
end

def clean_routes_comments
  gsub_file 'config/routes.rb',
            /^.*#.+/,
            ''
  gsub_file 'config/routes.rb',
            /\n(\n|\s|#)+/,
            "\n"
end

def editor_config
  mirror '.editorconfig'
end

# https://gist.github.com/kevinSuttle/1997924
def metatags
  mirror 'app/views/layouts/_meta.erb'
  insert_into_file 'app/views/layouts/application.html.erb',
                   "\n  <%= render 'layouts/meta' %>",
                   after: '</title>'
end

# https://devcenter.heroku.com/articles/getting-started-with-rails4#heroku-gems
# https://devcenter.heroku.com/articles/getting-started-with-rails4#use-postgres
# https://devcenter.heroku.com/articles/getting-started-with-rails4#webserver
def heroku(server = nil)
  server ||= yes?('Server: (Y)Puma, (N)Unicorn') ? 'puma' : 'unicorn'

  gem_group :production do
    gem 'rails_12factor'
    gem 'pg'
    gem server
  end

  mirror "config/#{server}.rb"

  args = server == 'puma' ? '-C' : '-p $PORT -c'
  create_file 'Procfile', "web: bundle exec #{server} #{args} config/#{server}.rb\n"
end

def inflections
  mirror 'config/initializers/inflections.rb'
end

def dev_route
  route "match 'dev(/:action(/:id))', controller: 'dev', via: :all"

  mirror 'app/controllers/dev_controller.rb',
         'app/views/dev/form.html.erb',
         'app/views/dev/pagination.html.slim',
         'app/views/layouts/dev.html.erb'
end

def bootstrap
  gem 'bootstrap-sass'

  mirror 'app/assets/stylesheets/bootstrap-custom.scss',
         'app/assets/stylesheets/bootstrap-imports.scss',
         'app/assets/stylesheets/bootstrap-overrides.scss'
end

def simple_form
  gem 'simple_form'
  generate 'simple_form:install', '--bootstrap'
end

def gem_nprogress_rails
  gem 'nprogress-rails' # https://github.com/caarlos0/nprogress-rails

  insert_into_file 'app/assets/javascripts/application.js', after: "//= require turbolinks\n" do
    "//= require nprogress\n" +
    "//= require nprogress-turbolinks\n"
  end

  insert_into_file 'app/assets/stylesheets/application.css', before: " *= require_tree ." do
    " *= require nprogress\n" +
    " *= require nprogress-bootstrap\n"
  end
end

def gem_kaminari
  gem 'kaminari'
  gem 'kaminari-i18n'
  generate *%w(kaminari:views bootstrap3 -e slim)
end

def mysql
  gem 'mysql2', group: :development
  mirror 'config/database.yml'
  database_name = ask "database name?"
  gsub_file 'config/database.yml', /database: test/, "database: #{database_name}"
end
