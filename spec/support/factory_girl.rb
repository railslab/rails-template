RSpec.configure do |config|
  config.include FactoryGirl::Syntax::Methods

  config.before(:suite) do
    begin
      DatabaseCleaner.start if defined? DatabaseCleaner
      # Run inside transaction to rollback after, leaving the database clean
      ActiveRecord::Base.transaction do
        # Test factories in spec/factories are working.
        FactoryGirl.lint
        fail ActiveRecord::Rollback
      end
    ensure
      DatabaseCleaner.clean if defined? DatabaseCleaner
    end
  end
end
