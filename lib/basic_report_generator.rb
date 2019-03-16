require 'date'

module BasicReportGenerator

  def self.output_report(report_lines, _)
    puts report_lines.join("\n")
    Dir.mkdir('reports') unless File.directory?('reports')
    filename = "basic_report_#{DateTime.now.strftime('%Y-%m-%d-%H-%M-%S')}"
    file = File.open("reports/#{filename}.txt", 'w+')
    file.write(report_lines.join("\n"))
  end

  def self.report_object(report_data)
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
    report_data[:months_summary].each do |month|
      month_summary_arrays << [
        month[:month],
        two_decimal_number_string(month[:opening]),
        two_decimal_number_string(month[:closing]),
        two_decimal_number_string(month[:minimum]),
        two_decimal_number_string(month[:delta])
      ]
    end
    all_arrays = [%w[month opening closing minimum delta]] + month_summary_arrays
    formatted_arrays = formatted_lines(all_arrays, 20) + ['']
    total_delta = (month_summary_arrays.map { |item| item[4].to_f }.inject(0, :+)).round(2)
    average_delta = two_decimal_number_string((total_delta / month_summary_arrays.count).round(2))
    formatted_arrays << ["TOTAL DELTA: #{two_decimal_number_string(total_delta)}, AVERAGE DELTA: #{average_delta}"]
    formatted_arrays << ['']
  end

  def self.month_lines(month, month_data)
    month_data_array = month_data[:transactions].each_with_object([]) do |transaction, a|
      a << [
        transaction[:date].strftime('%Y/%m/%d'),
        transaction[:type],
        transaction[:payee],
        transaction[:purpose],
        transaction[:description],
        two_decimal_number_string(transaction[:amount]),
        two_decimal_number_string(transaction[:balance])
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

  def self.two_decimal_number_string(input)
    new_string = input.to_s
    return "#{new_string}.00" unless new_string.index('.')
    decimal_length = new_string[new_string.index('.') + 1..-1].length
    raise("more than two decimal places given for output value: #{input}") if decimal_length > 2
    "#{new_string}#{'0' * (2 - decimal_length)}"
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
