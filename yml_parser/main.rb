require 'pry'
require 'yaml'
require 'awesome_print'
require 'csv'
require 'deep_merge'

def build_hash(path, value)
  result = {}
  key = path.first
  result[key] = path.size.eql?(1) ? value : build_hash(path[1..], value)
  result
end

def key_values_to_hash(key_values)
  en_result = {}
  pt_result = {}
  key_values.each do |key_value|
    next if key_value['key'].nil? || key_value['key'].empty?
 
    path = key_value['key'].split('.')

    pt = key_value['pt']
    en = key_value['en'].nil? || key_value['en'].empty? ? pt : key_value['en']

    en_result.deep_merge! build_hash(path, en)
    pt_result.deep_merge! build_hash(path, pt)
  end
  [en_result, pt_result]
end

def hash_key_values(hash, current_path: '')
  result = []
  hash.each do |k, v|
    new_current_path = String.new(current_path)
    new_current_path += '.' unless new_current_path.empty?
    new_current_path += k.to_s
    if v.is_a?(Hash)
      result.push(*hash_key_values(v, current_path: new_current_path))
    else
      result.push([new_current_path, v])
    end
  end
  result
end

def write_array_on_csv(arr, file_name)
  CSV.open(file_name + '.csv', 'w') do |csv|
    csv << %w[key value]
    arr.each do |e|
      csv << e
    end
  end
end

# %w[
#   activerecord.pt-BR
#   alerts.pt-BR
#   application.pt-BR
#   autonomy.pt-BR
#   errors.pt-BR
#   import.pt-BR
#   mailer.pt-BR
#   models.pt-BR
#   pundit.pt-BR
# ].each do |yml_file|
#   write_array_on_csv(hash_key_values(YAML.load_file(yml_file + '.yml')), yml_file)
# end

[
  'activerecord',
  'application',
  'autonomy',
  'errors',
  'import',
  'mailer',
  'pundit'
].each do |translation_file|
  data = CSV.parse(File.read("translations/#{translation_file}.csv"), col_sep: ',', headers: true).map(&:to_h)

  result = key_values_to_hash(data)

  File.open("en/#{translation_file}.en.yml", 'w') do |f|
    f.write(result[0].to_yaml)
  end
end

