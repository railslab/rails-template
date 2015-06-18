namespace :stats do
  def calculate
    require 'rails/code_statistics'
    cs = CodeStatistics.new(*STATS_DIRECTORIES)
    stats = cs.instance_variable_get(:@statistics)
    stats['Total'] = cs.instance_variable_get(:@total)
    Hash[stats.map { |k, v| [k.downcase, v.instance_values] }]
  end

  def yml
    calculate.to_yaml
  end

  def json
    JSON.pretty_generate(calculate)
  end

  def csv
    calculate.inject([]) { |a, e| a << e.values.join(',') }.join ', '
  end

  def txt
    capture(:stdout) { Rake::Task['stats'].invoke }
  end

  desc 'stats in yaml format'
  task yml: :environment do
    puts yml
  end

  desc 'stats in json format'
  task json: :environment do
    puts json
  end

  desc 'stats in csv format'
  task csv: :environment do
    puts csv
  end

  desc 'save all stats to stats/*'
  task save: :environment do
    Dir.mkdir('stats') unless Dir.exist? 'stats'
    File.write('stats/stats.yml', yml)
    File.write('stats/stats.json', json)
    File.write('stats/stats.txt', txt)
  end
end
