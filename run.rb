require_relative 'config'
require_relative 'lib/basic_report_generator'
require_relative 'lib/excel_spreadsheet_wrapper'
require_relative 'lib/excel_report_generator'
require_relative 'lib/generate_report'
require_relative 'lib/google_spreadsheet_wrapper'

# params = Config.run_parameters

# source = {
#   excel: ExcelSpreadsheetWrapper,
#   google: GoogleSpreadsheetWrapper,
# }[params[:source].to_sym]
#
# destinations = [BasicReportGenerator, ExcelReportGenerator]
#
# GenerateReport.generate_report(params, source, destinations)


require_relative 'lib/report_data'


params = Config.run_parameters('personal')
personal_report_data = ReportData.report_data(ExcelSpreadsheetWrapper, params)
params = Config.run_parameters('income')
income_report_data = ReportData.report_data(ExcelSpreadsheetWrapper, params)
GenerateReport.personal_report(personal_report_data, income_report_data, params[:save_filepath])

