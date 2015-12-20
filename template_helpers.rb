class Thor
  module Actions
    def source_paths
      [File.expand_path(File.dirname(__FILE__))]
    end
  end
end

module Helpers
  # override run to always capture and trim output
  def run_capture(command)
    run(command, capture: true).to_s.strip
  end

  def git_add_commit(msg)
    git add: '.'
    # git :status
    # TODO: message prefix/suffix/template
    git commit: %(-m 'template: #{msg}')
    # git diff: 'HEAD^'
  end

  # append each path to .gitignore
  def git_ignore(*paths)
    paths.each {|path| append_to_file '.gitignore', "#{path}\n"}
  end

  def dev(line)
    environment line, env: 'development'
  end

  def pro(line)
    environment line, env: 'production'
  end

  def tool(name)
    gem name, group: :development, require: false
  end

  def mirror(*names)
    names.each do |name|
      copy_file name, name, force: true, mode: :preserve
    end
  end

  def enable_gem(name, group = nil)
    gem_name = "gem '#{name}'"
    uncomment_lines 'Gemfile', gem_name
    return if File.read('Gemfile').match gem_name
    if group
      prepend_gem_group name, group
    else
      append_gem name
    end
  end

  def prepend_gem_group(name, group)
    groups = [group].flatten.map(&:inspect).join(', ')
    insert_into_file 'Gemfile',
                     "  gem '#{name}'\n",
                     after: "group #{groups} do\n"
  end

  def append_gem(name)
    append_file 'Gemfile', "gem '#{name}'\n"
  end

  def add_eof(file)
    append_file file, "\n", force: true
  end

  def replace_file(file, content, &block)
    remove_file file
    create_file file, content, &block
  end

  # FIX is inserting both before require_tree|require_self
  def append_require_css(name)
    insert_into_file 'app/assets/stylesheets/application.css',
                     " *= require #{name}\n",
                     before: or_rx(' *= require_tree .', ' *= require_self')
  end

  def append_require_js(name)
    insert_into_file 'app/assets/javascripts/application.js',
                     "//= require #{name}\n",
                     before: or_rx('//= require_tree .', '//= require_self')
  end

  def append_secret_production(var, key)
    append_file 'config/secrets.yml', "  #{var}: #{key}\n"
  end

  def append_secret_production_env(key)
    append_secret_production(key, "<%= ENV['#{key.upcase}'] %>")
  end

  def bundle
    inside Rails.root do
      Bundler.with_clean_env do
        run 'bundle install'
      end
    end
  end

  private

  def project_name
    Rails.application.class.parent_name.underscore
  end

  def file_exist?(path)
    File.exist? relative_to_original_destination_root(path)
  end

  def or_rx(*args)
    rx = args.map(&Regexp.method(:escape))
    rx = rx.map {|r| "(#{r})"}
    rx = rx.join('|')
    Regexp.new(rx)
  end
end
