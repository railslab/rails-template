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
    git commit: %(-m '#template: #{msg}')
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
      gem name, group: group
    else
      gem name
    end
  end

  def replace_file(file, content, &block)
    remove_file file
    create_file file, content, &block
  end

  def append_require_css(name)
    insert_into_file 'app/assets/stylesheets/application.css',
                     " *= require #{name}\n",
                     before: ' *= require_tree .'
  end

  def append_require_js(name)
    insert_into_file 'app/assets/javascripts/application.js',
                     "//= require #{name}\n",
                     before: '//= require_tree .'
  end
end
