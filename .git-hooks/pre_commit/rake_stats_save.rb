module Overcommit::Hook::PreCommit
  class RakeStatsSave < Base
    def run
      fix_stash do
        result = execute %w(bin/rake stats:save)
        result = execute %w(git add stats) if result.success?
        result.success? ? :pass : [:fail, result.stdout]
      end
    end

    private
    # não é possível modificar arquivos durante o pre-commit, pois os arquivos vão para o stash e voltam
    # https://github.com/brigade/overcommit/issues/214#issuecomment-103974519
    # utilizar o hack abaixo para contornar este problema
    def fix_stash
      execute %w(git stash pop --index --quiet)
      ret = yield
      execute %w(git stash save --keep-index --quiet)
      return ret
    end
  end
end
