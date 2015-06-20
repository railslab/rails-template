require_relative './template_recipes'
Rails::Generators::AppGenerator.include Recipes

cook(ENV['RECIPE'], ENV['COMMIT'].present?) if ENV['RECIPE']
