require 'pry'
require 'awesome_print'
require 'csv'
require 'json'
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
#   common
# ].each do |json_file|
#   write_array_on_csv(hash_key_values(JSON.parse(File.read(json_file + '.json'))), json_file)
# end



%w[
  common
].each do |translation_file|
  data = CSV.parse(File.read("#{translation_file}-translations.csv"), col_sep: ',', headers: true).map(&:to_h)

  result = key_values_to_hash(data)

  File.open("#{translation_file}-en.json", 'w') do |f|
    f.write(result[0].to_json)
  end

  File.open("#{translation_file}-pt-BR.json", 'w') do |f|
    f.write(result[1].to_json)
  end
end



