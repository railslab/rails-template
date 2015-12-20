require_relative './template_recipes'

Dir[ File.expand_path('../recipes/*', __FILE__) ].each do |f|
  puts "loading #{File.basename(f, '.rb')}"
  require f
end

Rails::Generators::AppGenerator.include Recipes

cook(ENV['RECIPE'], ENV['COMMIT'].present?) if ENV['RECIPE']
