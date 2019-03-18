require 'rxl'

module ExcelReportGenerator

  def self.report_object(report_data)
    report = {
      'months_summary' => months_summary(report_data),
      'sheets_summary' => sheets_summary(report_data),
      'payee_summary' => payee_summary(report_data),
      'all_months' => all_months(report_data)
    }
    report.merge!(month_sheets(report_data))
    report
  end

  def self.output_report(hash_tables, filepath)
    Rxl.write_file_as_tables(filepath, hash_tables)
  end

  def self.payee_summary(report_data)
    columns = %i[payee_name income expenditure balance]
    formats = {
      headers: header_formats,
      'B' => { format: :number, decimals: 2 },
      'C' => { format: :number, decimals: 2 },
      'D' => { format: :number, decimals: 2 }
    }
    { columns: columns, formats: formats, rows: report_data[:payee_summary] }
  end

  def self.sheets_summary(report_data)
    columns = %i[sheet_name income expenditure balance]
    formats = {
      headers: header_formats,
      'B' => { format: :number, decimals: 2 },
      'C' => { format: :number, decimals: 2 },
      'D' => { format: :number, decimals: 2 }
    }
    { columns: columns, formats: formats, rows: report_data[:sheets_summary] }
  end

  def self.months_summary(report_data)
    columns = %i[month opening minimum closing delta]
    formats = {
      headers: header_formats,
      'B' => { format: :number, decimals: 2 },
      'C' => { format: :number, decimals: 2 },
      'D' => { format: :number, decimals: 2 },
      'E' => { format: :number, decimals: 2 }
    }
    { columns: columns, formats: formats, rows: report_data[:months_summary] }
  end

  def self.month_sheets(report_data)
    report_data[:months].each_with_object({}) do |(k, v), h|
      h[k] = { columns: month_columns, formats: month_formats, rows: v[:transactions] }
    end
  end

  def self.all_months(report_data)
    trans_arrays = report_data[:months].values.map { |month| month[:transactions] }
    transactions = trans_arrays.each_with_object([]) { |trans, a| a.concat(trans) }
    { columns: month_columns, formats: month_formats, rows: transactions }
  end

  def self.month_columns
    %i[month type payee purpose date description amount balance]
  end

  def self.month_formats
    {
      headers: header_formats,
      'E' => { format: :date },
      'G' => { format: :number, decimals: 2 },
      'H' => { format: :number, decimals: 2 },
    }
  end

  def self.header_formats
    {
      bold: true,
      h_align: 'center',
      fill: '999999'
    }
  end

end