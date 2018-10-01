require 'date'

module BasicReportGenerator

  def output_report(report_lines)
    puts report_lines.join("\n")
    Dir.mkdir('reports') unless File.directory?('reports')
    filename = "basic_report_#{DateTime.now.strftime('%Y-%m-%d-%H-%M-%S')}"
    file = File.open("reports/#{filename}.txt", 'w+')
    file.write(report_lines.join("\n"))
  end

end
