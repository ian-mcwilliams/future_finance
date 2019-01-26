require_relative 'report_data'
require_relative 'google_spreadsheet_wrapper'
require_relative 'basic_report_generator'
require_relative 'excel_spreadsheet_wrapper'
require 'json'

module GenerateReport

  def self.generate_report(target)
    params = run_parameters(target)
    source = {
      excel: ExcelSpreadsheetWrapper,
      google: GoogleSpreadsheetWrapper,
    }[params[:source].to_sym]
    report_data = ReportData.report_data(source, params)
    report_lines = BasicReportGenerator.report_lines(report_data)
    BasicReportGenerator.output_report(report_lines)
  end

  def self.run_parameters(target)
    raw_params = JSON.parse(File.read('artefacts/parameters.json'))[target]
    {
      start_date: DateTime.parse(raw_params['start_date']),
      end_date: DateTime.parse(raw_params['end_date']),
      opening_balance: raw_params['opening_balance'],
      source: raw_params['source'],
      filename: raw_params['filename'],
      sheet_name: raw_params['sheet_name']
    }
  end

end
