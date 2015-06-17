namespace :stats do
  def calculate
    require 'rails/code_statistics'
    cs = CodeStatistics.new(*STATS_DIRECTORIES)
    stats = cs.instance_variable_get(:@statistics)
    stats['Total'] = cs.instance_variable_get(:@total)
    data = {}
    stats.each do |k, v|
      data[k.downcase] = {
        'lines' => v.lines,
        'code_lines' => v.code_lines,
        'classes' => v.classes,
        'methods' => v.methods
      }
    end
    data
  end

  desc 'stats in yaml format'
  task yml: :environment do
    puts calculate.to_yaml
  end

  desc 'stats in json format'
  task json: :environment do
    puts JSON.pretty_generate(calculate)
  end

  desc 'stats in csv format'
  task csv: :environment do
    numbers = []
    calculate.each do |_, h|
      numbers << h.values.join(',')
    end
    puts numbers.join ', '
  end
end
