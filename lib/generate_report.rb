require_relative 'report_data'
require_relative 'google_spreadsheet_wrapper'
require_relative 'basic_report_generator'
require_relative 'excel_spreadsheet_wrapper'

module GenerateReport

  def self.generate_report(params, source, destination)
    report_data = ReportData.report_data(source, params)
    report_object = destination.report_object(report_data)
    destination.output_report(report_object)
  end

end
