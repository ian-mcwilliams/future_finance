require_relative 'config'
require_relative 'lib/generate_report'

params = Config.run_parameters

source = {
  excel: ExcelSpreadsheetWrapper,
  google: GoogleSpreadsheetWrapper,
}[params[:source].to_sym]

destination = {
  basic: BasicReportGenerator
}[params[:destination].to_sym]

GenerateReport.generate_report(params, source, destination)