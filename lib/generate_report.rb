require_relative 'report_data'

module GenerateReport

  def self.generate_report(params, source, destinations)
    report_data = ReportData.report_data(source, params)
    Dir.mkdir('reports') unless File.directory?('reports')
    destinations.each do |destination|
      report_object = destination.report_object(report_data)
      destination.output_report(report_object, params[:save_filepath])
    end
  end

end
