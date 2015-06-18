module Overcommit::Hook::PreCommit
  class RakeStatsSave < Base
    def run
      result = execute %w(rake stats:save)
      execute %w(git add stats) if result.success?
      return :pass if result.success?

      [:fail, result.stdout]
    end
  end
end
