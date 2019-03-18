require_relative 'report_data'
require_relative 'basic_report_generator'
require_relative 'excel_report_generator'

module GenerateReport

  def self.generate_report(params, source, destinations)
    report_data = ReportData.report_data(source, params)
    Dir.mkdir('reports') unless File.directory?('reports')
    destinations.each do |destination|
      report_object = destination.report_object(report_data)
      destination.output_report(report_object, params[:save_filepath])
    end
  end

  def self.personal_report(personal_report_data, income_report_data, save_filepath)
    Dir.mkdir('reports') unless File.directory?('reports')
    personal = ExcelReportGenerator.report_object(personal_report_data)
    income = ExcelReportGenerator.report_object(income_report_data)
    combined_report_object = {
      'months_summary' => personal.delete('months_summary'),
      'sheets_summary' => personal.delete('sheets_summary'),
      'all_transactions' => personal.delete('all_months'),
      'income_summary' => income['months_summary'],
      'income_transactions' => income['all_months']
    }
    # combined_report_object.merge!(personal)
    ExcelReportGenerator.output_report(combined_report_object, save_filepath)
  end

end
