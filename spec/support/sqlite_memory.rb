# https://github.com/mvz/memory_test_fix
load Rails.root.join('db/schema.rb') if ActiveRecord::Base.connection_config[:database] == ':memory:'
