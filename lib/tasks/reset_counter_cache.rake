namespace :utils do
  # https://www.krautcomputing.com/blog/2015/01/13/recalculate-counter-cache-columns-in-rails/
  desc "Reset Counter Cache on all models with counter_cache and that differ in counts"
  task reset_counter_cache: :environment do
    # Make sure to load all models first
    Rails.application.eager_load!

    ActiveRecord::Base.descendants.each do |many_class|
      many_class.reflections.each do |name, reflection|
        if reflection.options[:counter_cache]
          one_class = reflection.class_name.constantize
          one_table, many_table = [one_class, many_class].map(&:table_name)
          ids = one_class.joins(many_table.to_sym)
                         .group("#{one_table}.id")
                         .having("#{one_table}.#{many_table}_count != COUNT(#{many_table}.id)")
                         .pluck("#{one_table}.id", "#{one_table}.#{many_table}_count")
          ids.each do |id, count|
            puts "#{one_class}.reset_counters #{id}, :#{many_table}"
            one_class.reset_counters id, many_table
          end
        end
      end
    end
  end
end
