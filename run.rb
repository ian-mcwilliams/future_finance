require_relative 'config'
require_relative 'lib/basic_report_generator'
require_relative 'lib/excel_spreadsheet_wrapper'
require_relative 'lib/excel_report_generator'
require_relative 'lib/generate_report'
require_relative 'lib/google_spreadsheet_wrapper'
require_relative 'lib/report_data'

def run_basic
  params = Config.run_parameters

  source = {
    excel: ExcelSpreadsheetWrapper,
    google: GoogleSpreadsheetWrapper,
  }[params[:source].to_sym]

  destinations = [BasicReportGenerator, ExcelReportGenerator]

  GenerateReport.generate_report(params, source, destinations)
end



def run_alt
  params = Config.run_parameters('f3m')
  company_report_data = ReportData.report_data(ExcelSpreadsheetWrapper, params)
  params = Config.run_parameters('personal')
  personal_report_data = ReportData.report_data(ExcelSpreadsheetWrapper, params)
  params = Config.run_parameters('income')
  income_report_data = ReportData.report_data(ExcelSpreadsheetWrapper, params)
  save_filepath = "reports/full_#{DateTime.now.strftime('%y%m%d%H%M%S')}.xlsx"
  GenerateReport.full_report(company_report_data, personal_report_data, income_report_data, save_filepath)
end

args = ARGV.map { |arg| arg }

if args.empty?
  run_basic
elsif args[0] == 'alt'
  run_alt
end
