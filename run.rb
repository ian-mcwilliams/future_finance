require_relative 'config'
require_relative 'lib/basic_report_generator'
require_relative 'lib/excel_spreadsheet_wrapper'
require_relative 'lib/excel_report_generator'
require_relative 'lib/generate_report'
require_relative 'lib/google_spreadsheet_wrapper'

params = Config.run_parameters

source = {
  excel: ExcelSpreadsheetWrapper,
  google: GoogleSpreadsheetWrapper,
}[params[:source].to_sym]

destination = {
  basic: BasicReportGenerator,
  excel: ExcelReportGenerator
}[params[:destination].to_sym]

GenerateReport.generate_report(params, source, destination)