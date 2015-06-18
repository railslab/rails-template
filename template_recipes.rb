# estudar http://guides.rubyonrails.org/generators.html e https://github.com/startae/start
require_relative './template_helpers'

# rubocop:disable Metrics/MethodLength
# rubocop:disable Metrics/ModuleLength
module Recipes
  include Helpers

  def help
    puts Recipes.public_instance_methods(false)
  end

  def cook(recipe, commit = true)
    send recipe
    return unless commit

    msg = recipe.to_s.tr '_', ' '
    git_add_commit msg
  end
  module_function :cook

  # apenas inicializar o repositório git
  def git_init
    git :init
  end

  # ignorar arquivos de configuração de IDEs
  def git_ignore_ide_files
    git_ignore '/.idea/', '*.sublime-workspace'
  end

  # utilizar Gemfile com várias gems comentadas
  def replace_gemfile
    mirror 'Gemfile'
  end

  def reset_routes
    replace_file 'config/routes.rb', <<-EOF.strip_heredoc
      Rails.application.routes.draw do
      end
    EOF
  end

  # versão alternativa para o método acima
  def clean_routes_comments
    gsub_file 'config/routes.rb',
              /^.*#.+/,
              ''
    gsub_file 'config/routes.rb',
              /\n(\n|\s|#)+/,
              "\n"
  end

  # colocar a pasta bin no path utilizando direnv
  def direnv
    create_file '.envrc', "PATH_add bin\n"
    run 'direnv allow .'
  end

  # instalar spring para acelerar rails console e rake
  def setup_spring
    run 'spring binstub --all'
  end

  # configurar database.yml para mysql, perguntando o nome do banco para ser criado
  def config_db
    mirror 'config/database.yml'
    database_name = ask 'database name?'
    gsub_file 'config/database.yml', /database: test/, "database: #{database_name}"
    rake 'db:create'
  end

  def add_ruby_version_to_gemfile
    version = run_capture 'rbenv global'
    insert_into_file 'Gemfile', "ruby '#{version}'", after: /source .+\n/
  end

  def tools
    mirror '.rubocop.yml',
           'bin/rubocop-precommit',
           '.overcommit.yml',
           'lib/tasks/auto_annotate_models.rake',
           'lib/tasks/reset_counter_cache.rake',
           'lib/tasks/stats.rake'
  end

  def single_line_logs_with_lograge
    enable_gem 'lograge'
    application 'config.lograge.enabled = true'
  end

  def timezone_brasilia
    application "config.time_zone = 'Brasilia'"
  end

  def default_locale_br
    enable_gem 'rails-i18n'
    application "config.i18n.default_locale = :'pt-BR'"
    mirror 'config/locales/pt-BR.yml'
  end

  def brazillian_inflections
    mirror 'config/initializers/inflections.rb'
  end

  def raise_unpermitted_parameters_on_dev
    dev 'config.action_controller.action_on_unpermitted_parameters = :raise'
  end

  def local_mailer
    dev "config.action_mailer.default_url_options = { host: 'localhost', port: 3000 }"
  end

  def editors_config_files
    mirror '.editorconfig',
           'rails.sublime-project'
  end

  # https://gist.github.com/kevinSuttle/1997924
  def layout_head_metatags
    mirror 'app/views/layouts/_meta.erb'
    insert_into_file 'app/views/layouts/application.html.erb',
                     "\n  <%= render 'layouts/meta' %>",
                     after: '</title>'
  end

  def layout_bootstrap_container
    gsub_file 'app/views/layouts/application.html.erb', "\n<%= yield %>\n", <<-EOF.strip_heredoc

    <div class="container-fluid">
      <%= yield %>
    </div>
    EOF
  end

  def layout_add_space_between_js_and_css
    gsub_file 'app/views/layouts/application.html.erb', 'true %>', "true %>\n"
  end

  # https://devcenter.heroku.com/articles/getting-started-with-rails4#heroku-gems
  # https://devcenter.heroku.com/articles/getting-started-with-rails4#use-postgres
  # https://devcenter.heroku.com/articles/getting-started-with-rails4#webserver
  def heroku(server = nil)
    server ||= yes?('Server: (ENTER)Puma (default), (Y)Unicorn') ? 'unicorn' : 'puma'

    enable_gem 'rails_12factor', :production
    enable_gem 'pg', :production
    enable_gem server, :production

    mirror "config/#{server}.rb"

    args = server == 'puma' ? '-C' : '-p $PORT -c'
    create_file 'Procfile', "web: bundle exec #{server} #{args} config/#{server}.rb\n"
  end

  def pagination_with_kaminari_gem
    enable_gem 'kaminari'
    enable_gem 'kaminari-i18n'
    # ou utilizar https://github.com/matenia/bootstrap-kaminari-views mas precisa especificar o tema.
    generate 'kaminari:views bootstrap3 -e slim'
  end

  def simple_form_bootstrap
    enable_gem 'simple_form'
    generate 'simple_form:install --bootstrap'

    # smaller label form size, from 3 to 2.
    gsub_file 'config/initializers/simple_form_bootstrap.rb',
              'col-sm-9',
              'col-sm-10'

    gsub_file 'config/initializers/simple_form_bootstrap.rb',
              'col-sm-3',
              'col-sm-2'

    gsub_file 'config/initializers/simple_form_bootstrap.rb',
              'col-sm-offset-3',
              'col-sm-offset-2'

    mirror 'app/helpers/simple_form_helper.rb'
  end

  # utilizar application.js apenas para as diretivas do sprockets
  def setup_js
    enable_gem 'coffee-rails'

    replace_file 'app/assets/javascripts/application.js', <<-EOF.strip_heredoc
      //= require jquery
      //= require jquery_ujs
      //= require turbolinks
      //= require_tree .
    EOF

    mirror 'app/assets/javascripts/app.coffee'
  end

  # utilizar application.css apenas para as diretivas do sprockets
  def setup_css
    enable_gem 'sass-rails'

    replace_file 'app/assets/stylesheets/application.css', <<-EOF.strip_heredoc
      /*
       *= require_tree .
       */
    EOF
  end

  def bootstrap
    enable_gem 'bootstrap-sass'
    enable_gem 'sass-rails'
    enable_gem 'coffee-rails'

    mirror 'app/assets/stylesheets/bootstrap-sass.scss',
           'app/assets/stylesheets/bootstrap-custom.css'

    append_require_css 'bootstrap-sass'
    append_require_js 'bootstrap'
  end

  # rota utilizada para debug e testes
  def dev_route
    route "match 'dev(/:action(/:id))', controller: 'dev', via: :all"

    mirror 'app/controllers/dev_controller.rb',
           'app/views/layouts/dev.html.erb'
    directory 'app/views/dev'
  end

  def gem_nprogress_rails
    gem 'nprogress-rails' # https://github.com/caarlos0/nprogress-rails

    insert_into_file 'app/assets/javascripts/application.js', after: "//= require turbolinks\n" do
      "//= require nprogress\n" \
      "//= require nprogress-turbolinks\n"
    end

    insert_into_file 'app/assets/stylesheets/application.css', before: ' *= require_tree .' do
      " *= require nprogress\n" \
      " *= require nprogress-bootstrap\n"
    end
  end

  def default_project
    cook :git_init
    cook :git_ignore_ide_files
    cook :replace_gemfile
    cook :reset_routes
    cook :direnv
    cook :setup_spring
    cook :config_db
    cook :add_ruby_version_to_gemfile
    cook :tools
    cook :single_line_logs_with_lograge
    cook :timezone_brasilia
    cook :default_locale_br
    cook :brazillian_inflections
    cook :raise_unpermitted_parameters_on_dev
    cook :local_mailer
    cook :editors_config_files
    cook :layout_head_metatags
    cook :layout_bootstrap_container
    cook :layout_add_space_between_js_and_css
    cook :heroku
    cook :pagination_with_kaminari_gem
    cook :simple_form_bootstrap
    cook :setup_js
    cook :setup_js
    cook :bootstrap
  end
end
