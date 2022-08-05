def build_hash(path, value)
  result = {}
  key = path.first
  result[key] = path.size.eql?(1) ? value : build_hash(path[1..], value)
  result
end


def auau(path_values)
  result = {}
  path_values.each do |path_value|
    path = path_value[0]
    value = path_value[1]


    result.merge! build_hash(result, path, value)
  end
  result
end


blau = [[%w[a b c], 'abc'], [%w[a b d], 'abd']]

a = auau(blau)

print a


