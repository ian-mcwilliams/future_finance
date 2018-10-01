module HtmlReportGenerator

  def self.generate_report
    File.open('report.html', 'w+') do |report|
      report.write(html_report)
    end
  end

  def self.summary_headers
    [
      'Period',
      'Opening balance',
      'Closing balance',
      'Minimum balance'
    ]
  end

  def self.html_report
    <<~HTML
      <html>
        <head>
        </head>
        <body>
          <h1>Report</h1>
          #{html_summary}
        </body>
      </html>
    HTML
  end

  def self.html_summary
    <<~HTML
      <table>
        <tr>
          #{th_headers}
        </tr>
      <table>
    HTML
  end

  def self.th_headers
    html_array = summary_headers.map do |value|
      <<~HTML
        <th>
          #{value}
        </th>
      HTML
    end
    html_array.join
  end

end