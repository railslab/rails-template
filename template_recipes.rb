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
    say recipe, :green
    response = send recipe
    return if response == :skip_commit
    return unless commit

    msg = recipe.to_s.tr '_', ' '
    git_add_commit msg
  end
  module_function :cook

  # apenas inicializar o repositório git
  def git_init
    git :init
  end

  # instalar spring para acelerar rails console e rake
  def setup_spring
    run 'spring binstub --all'
  end

  def disable_generators
    application <<-EOF.strip_heredoc
      config.generators do |g|
            g.assets false
            g.helper false
            g.javascripts false
            g.stylesheets false
            g.test_framework false
          end
    EOF
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

  # configurar database.yml para mysql, perguntando o nome do banco para ser criado
  def config_db
    mirror 'config/database.yml'
    database_name = 'test' #ask 'database name?'
    gsub_file 'config/database.yml', /database: test/, "database: #{database_name}"
  end

  def add_ruby_version_to_gemfile
    version = run_capture 'rbenv global'
    insert_into_file 'Gemfile', "ruby '#{version}'", after: /source .+\n/
  end

  def rubocop
    mirror '.rubocop.yml',
           'bin/rubocop-precommit'
  end

  def tasks_extras
    directory 'lib/tasks'
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

  # impede que um helper de um controller seja carregado em outro
  # simple_form_helper será carregado apenas se colocar include SimpleFormHelper no application_helper
  def disable_include_all_helpers
    application 'config.action_controller.include_all_helpers = false'
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

  def layout_flash_messages
    enable_gem 'bootstrap_flash_messages'
    insert_into_file 'app/views/layouts/application.html.erb',
                     "  <%= flash_messages(:close, :fade) %>\n",
                     before: /^\s+<%= yield %>/
  end

  def layout_env_dev
    gsub_file 'app/views/layouts/application.html.erb',
              '<html>',
              %q(<html<%== ' id="env-dev"' if Rails.env.development? %>>)
    append_to_file 'app/assets/stylesheets/application.css',
                   "#env-dev body { border-top: 1px dashed red; }\n"
  end

  # https://devcenter.heroku.com/articles/getting-started-with-rails4#heroku-gems
  # https://devcenter.heroku.com/articles/getting-started-with-rails4#use-postgres
  # https://devcenter.heroku.com/articles/getting-started-with-rails4#webserver
  def heroku(server = 'puma') # set server to nil to enable ask during cook
    server ||= yes?('Server: (ENTER)Puma (default), (Y)Unicorn') ? 'unicorn' : 'puma'

    enable_gem 'rails_12factor', :production
    enable_gem 'pg', :production
    enable_gem server, :production

    mirror "config/#{server}.rb"

    args = server == 'puma' ? '-C' : '-p $PORT -c'
    create_file 'Procfile', "web: bundle exec #{server} #{args} config/#{server}.rb\n"
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

    mirror 'config/locales/simple_form.pt-BR.yml'
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

    mirror 'app/assets/javascripts/app.js.coffee'
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

    mirror 'app/assets/stylesheets/bootstrap-sass.css.scss',
           'app/assets/stylesheets/bootstrap-custom.css'

    append_require_css 'bootstrap-sass'
    append_require_js 'bootstrap'
  end

  def nprogress_rails
    enable_gem 'nprogress-rails'

    append_require_js 'nprogress'
    append_require_js 'nprogress-turbolinks'

    append_require_css 'nprogress'
    append_require_css 'nprogress-bootstrap'
  end

  def inherited_resources
    enable_gem 'inherited_resources'
    mirror 'app/controllers/concerns/inherited_resources_defaults.rb',
           'config/initializers/inherited_resources.rb'
  end

  def pagination_with_kaminari
    enable_gem 'kaminari'
    enable_gem 'kaminari-i18n'
    # ou utilizar https://github.com/matenia/bootstrap-kaminari-views mas precisa especificar o tema.
    generate 'kaminari:views bootstrap3 -e slim'
    uncomment_lines 'app/controllers/concerns/inherited_resources_defaults.rb',
                    'end_of_association_chain'
  end

  # apenas configura o devise, sem criar user
  def devise_config
    enable_gem 'devise'
    enable_gem 'devise-i18n'
    enable_gem 'devise-i18n-views'
    enable_gem 'devise-bootstrap-views'

    generate 'devise:install'

    gsub_file 'config/initializers/devise.rb',
              'config.password_length = 8..72',
              'config.password_length = Rails.env.production? ? 8..72 : 1..72'

    insert_into_file 'app/controllers/application_controller.rb',
                     "  # before_action :authenticate_user!\n",
                     after: "::Base\n"

    mirror 'app/views/layouts/devise.html.slim'
  end

  def devise_user
    generate 'devise user' unless File.read('config/routes.rb').match('devise_for :users')

    uncomment_lines 'app/controllers/application_controller.rb',
                     'before_action :authenticate_user!'

    uncomment_lines 'app/controllers/concerns/inherited_resources_defaults.rb',
                    'begin_of_association_chain'

    insert_into_file 'app/models/user.rb',
                     "  def to_s; email end\n",
                     before: /^end$/
  end

  def helper_simple_form
    mirror 'app/helpers/simple_form_helper.rb'
  end

  def guard_livereload
    enable_gem 'guard', :console
    enable_gem 'guard-livereload', :console
    run 'guard init livereload'
  end

  # rake db:seeds:development:users
  def seeds
    enable_gem 'seedbank', :development
    directory 'db/seeds'
  end

  def scaffold_bootstrap_template
    directory 'lib/templates/slim/scaffold'
    append_to_file 'app/assets/stylesheets/application.css',
                   "body { margin-top: 20px; }\n"
  end

  # instalar overcommit por ultimo para nao atrapalhar os commits de cada cook
  def overcommit_setup
    enable_gem 'overcommit', :console
    mirror '.overcommit.yml'
    directory '.git-hooks'
    run 'overcommit --install'
  end

# ======================================================================================================================

  # rota utilizada para debug e testes
  def dev_route
    route "match 'dev(/:action(/:id))', controller: 'dev', via: :all"

    mirror 'app/controllers/dev_controller.rb',
           'app/views/layouts/dev.html.erb'
    directory 'app/views/dev'
  end

  def scaffold_cadastro
    run 'rails destroy scaffold cadastro'
    generate 'scaffold cadastro nome email'
    rake 'db:migrate'
  end

  def minimum
    cook :git_init
    cook :replace_gemfile
    cook :reset_routes
    cook :config_db

    cook :timezone_brasilia
    cook :default_locale_br
    cook :brazillian_inflections
    cook :disable_generators

    cook :setup_js
    cook :setup_css

    cook :direnv
    cook :setup_spring

    :skip_commit
  end

  def default
    cook :minimum

    cook :git_ignore_ide_files
    cook :add_ruby_version_to_gemfile
    cook :single_line_logs_with_lograge
    cook :raise_unpermitted_parameters_on_dev
    cook :local_mailer
    # cook :disable_include_all_helpers

    cook :heroku
    cook :rubocop
    cook :tasks_extras
    cook :editors_config_files

    cook :layout_head_metatags
    cook :layout_bootstrap_container
    cook :layout_add_space_between_js_and_css
    cook :layout_flash_messages
    cook :layout_env_dev
    cook :nprogress_rails

    cook :simple_form_bootstrap
    cook :bootstrap
    cook :scaffold_bootstrap_template

    cook :inherited_resources
    cook :pagination_with_kaminari

    cook :devise_config
    cook :devise_user
    cook :seeds

    # cook :helper_simple_form

    cook :guard_livereload
    cook :overcommit_setup

    :skip_commit
  end

  def evernote
    cook :minimum

    cook :layout_bootstrap_container
    cook :layout_add_space_between_js_and_css
    cook :layout_flash_messages

    cook :simple_form_bootstrap
    cook :bootstrap
    cook :scaffold_bootstrap_template

    cook :heroku
    cook :nprogress_rails

    cook :inherited_resources
    cook :pagination_with_kaminari

    cook :devise_config
    cook :devise_user
    cook :seeds
  end
end
