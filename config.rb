require 'yaml'

module Config

  def self.run_parameters(run = nil)
    params_hash = YAML.load_file('artefacts/parameters.yml')
    raw_params = params_hash[run || params_hash['run']]
    save_filepath = "reports/excel/#{params_hash['run']}_#{DateTime.now.strftime('%y%m%d%H%M%S')}.xlsx"
    {
      start_date: DateTime.parse(raw_params['start_date']),
      end_date: DateTime.parse(raw_params['end_date']),
      opening_balance: raw_params['opening_balance'],
      source: raw_params['source'],
      destination: params_hash['output'],
      filename: raw_params['filename'],
      sheet_names: raw_params['sheet_names'],
      save_filepath: save_filepath
    }
  end

end