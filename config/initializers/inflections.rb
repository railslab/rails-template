ActiveSupport::Inflector.inflections do |inflect|
  inflect.plural(/ao$/i,  'oes')
  inflect.singular(/oes$/i, 'ao')

  inflect.plural(/m$/i,  'ns')
  inflect.singular(/ns$/i, 'm')
end
