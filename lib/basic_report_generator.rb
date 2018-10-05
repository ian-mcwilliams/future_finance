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
    report_data[:months].each do |key, value|
      report_lines += month_lines(key, value) + ['']
    end
    report_lines
  end

  def self.formatted_lines(all_arrays, widths)
    all_arrays.each_with_object([]) do |current_array, a|
      i = 0
      a << current_array.each_with_object('') do |item, s|
        i += 1
        s << item.to_s
        widths.times do
          break if s.length > widths * i
          s << ' '
        end
      end
    end
  end

  def self.summary_lines(report_data)
    month_summary_arrays = []
    report_data[:months].each do |key, value|
      month_summary_arrays << [
        key,
        value[:opening_balance],
        value[:closing_balance],
        value[:minimum_balance],
        (value[:closing_balance] - value[:opening_balance]).round(2)
      ]
    end
    all_arrays = [%w[month opening closing minimum delta]] + month_summary_arrays
    formatted_lines(all_arrays, 20) + ['']
  end

  def self.month_lines(month, month_data)
    month_data_array = month_data[:transactions].each_with_object([]) do |transaction, a|
      a << [
        transaction[:date].strftime('%Y/%m/%d'),
        transaction[:type],
        transaction[:payee],
        transaction[:purpose],
        transaction[:description],
        transaction[:amount],
        transaction[:balance]
      ]
    end
    all_arrays = [
      ["MONTH #{month}"],
      ['']
    ]
    all_arrays += [%w[date type payee purpose description amount balance]]
    all_arrays.concat(month_data_array)
    formatted_lines(all_arrays, 20)
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
