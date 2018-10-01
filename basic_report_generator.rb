require 'date'

module BasicReportGenerator

  def self.output_report(report_lines)
    puts report_lines.join("\n")
    Dir.mkdir('reports') unless File.directory?('reports')
    filename = "basic_report_#{DateTime.now.strftime('%Y-%m-%d-%H-%M-%S')}"
    file = File.open("reports/#{filename}.txt", 'w+')
    file.write(report_lines.join("\n"))
  end

  def self.report_lines(report_data)
    report_lines = report_header_lines + summary_header_lines +
      summary_lines(report_data) + month_section_header_lines
    report_data[:months].each do |month_data|
      report_lines += month_lines(month_data)
    end
    report_lines
  end

  def self.summary_lines(report_data)
    [
      'summary_lines',
      ''
    ]
  end

  def self.month_lines(month_data)
    [
      'month_lines',
      ''
    ]
  end

  def self.report_header_lines
    File.read('basic_report_templates/report_header.txt').split("\n") + ['']
  end

  def self.summary_header_lines
    File.read('basic_report_templates/summary_header.txt').split("\n") + ['']
  end

  def self.month_section_header_lines
    File.read('basic_report_templates/month_section_header.txt').split("\n") + ['']
  end

end
