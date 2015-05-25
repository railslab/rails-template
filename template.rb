require_relative './template_recipes'

run_commit :add_ruby_version_to_gemfile

exit

run_commit :git_init,
           :add_ruby_version_to_gemfile,
           :gem_thin_on_dev,
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
           :tools,
           :dev_route,
           :bootstrap,
           :simple_form

