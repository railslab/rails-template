# https://github.com/tapajos/brazilian-rails/blob/master/lib/inflector_portuguese.rb
ActiveSupport::Inflector.inflections do |inflect|
  # producao
  inflect.plural(/ao$/i,  'oes')
  inflect.singular(/oes$/i, 'ao')

  # album
  inflect.plural(/m$/i,  'ns')
  inflect.singular(/ns$/i, 'm')

  # correntista
  inflect.plural(/ta$/i,  'tas')
  inflect.singular(/tas$/i, 'ta')

  # encaixe
  inflect.plural(/xe$/i,  'xes')
  inflect.singular(/xes$/i, 'xe')

  # transferencia
  inflect.plural(/ia$/i,  'ias')
  inflect.singular(/ias$/i, 'ia')
end
