require_relative 'report_data'
require_relative 'google_spreadsheet_wrapper'
require_relative 'basic_report_generator'

module GenerateReport
  include ReportData
  include GoogleSpreadsheetWrapper
  include BasicReportGenerator

  def self.generate_report(filename)
    source = GoogleSpreadsheetWrapper
    report_data = ReportData.report_data(source, filename)
    report_lines = BasicReportGenerator.report_lines(report_data)
    BasicReportGenerator.output_report(report_lines)
  end

end
