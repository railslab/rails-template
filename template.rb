require_relative './template_recipes'

run_commit ENV['RECIPE'] if ENV['RECIPE']

exit

run_commit :git_init,
           :add_ruby_version_to_gemfile,
           :tools,
           :gem_lograge,
           :gem_slim,
           :gem_extras,
           :remove_sqlit3_from_production,
           :timezone_brasilia,
           :default_locale_br,
           :raise_unpermitted_parameters_on_dev,
           :local_mailer,
           :clean_routes_comments,
           :editor_config,
           :metatags,
           :heroku,
           :inflections,
           :dev_route,
           :bootstrap,
           :simple_form,
           :gem_nprogress_rails
