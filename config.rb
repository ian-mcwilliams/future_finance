require 'yaml'

module Config

  def self.run_parameters(run = nil)
    params_hash = YAML.load_file('artefacts/parameters.yml')
    raw_params = params_hash[run || params_hash['run']]
    {
      start_date: DateTime.parse(raw_params['start_date']),
      end_date: DateTime.parse(raw_params['end_date']),
      opening_balance: raw_params['opening_balance'],
      source: raw_params['source'],
      filename: raw_params['filename'],
      sheet_names: raw_params['sheet_names']
    }
  end

end