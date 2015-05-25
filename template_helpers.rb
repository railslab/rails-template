module ::Thor::Actions
  def source_paths
    [File.expand_path(File.dirname(__FILE__))]
  end
end

# override run to always capture and trim output
def run_capture(command)
  run(command, capture: true).to_s.strip
end

def git_add_commit(msg)
  git add: '.'
  # git :status
  # TODO: message prefix/suffix/template
  git commit: %(-m '#{msg}')
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

def run_commit(*methods)
  methods.each do |method|
    msg = method.to_s.tr '_', ' '
    send method.to_sym
    # git_add_commit msg
  end
end

def mirror(*names)
  names.each do |name|
    copy_file name, name, force: true
  end
end
