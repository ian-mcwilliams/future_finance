require 'rxl'

module ExcelReportGenerator

  def self.report_object(report_data)
    month_sheets(report_data)
  end

  def self.output_report(hash_tables, filepath)
    Rxl.write_file_as_tables(filepath, hash_tables)
  end

  def self.month_sheets(report_data)
    month_columns = %i[type payee purpose date description amount balance]
    month_formats = {
      headers: {
        bold: true,
        h_align: 'center',
        fill: '999999'
      },
      'D' => { format: :date },
      'F' => { format: :number, decimals: 2 },
      'G' => { format: :number, decimals: 2 },
    }
    report_data[:months].each_with_object({}) do |(k, v), h|
      h[k] = {
        columns: month_columns,
        formats: month_formats,
        rows: v[:transactions]
      }
    end
  end

end