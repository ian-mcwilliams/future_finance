require 'simple_xlsx_reader'

module ExcelSpreadsheetWrapper
  def self.hash_spreadsheet(filename, target)
    raw_spreadsheet = excel_spreadsheet(filename)
    excel_spreadsheet_to_hash_spreadsheet(raw_spreadsheet, target)
  end

  def self.excel_spreadsheet(filename)
    SimpleXlsxReader.open("artefacts/#{filename}.xlsx")
  end

  def self.excel_spreadsheet_to_hash_spreadsheet(raw_spreadsheet, target)
    hash_spreadsheet = {}
    planner_sheet = raw_spreadsheet.sheets.select { |sheet| sheet.name == target }[0]
    planner_sheet.rows.each_with_index do |row, row_i|
      row.each_with_index do |cell, col_i|
        value = cell.is_a?(Date) ? cell.strftime('%d-%m-%Y') : cell
        hash_spreadsheet[cell_index(col_i, row_i)] = { value: value }
      end
    end
    { 'planner' => { cells: hash_spreadsheet } }
  end

  def self.cell_index(col, row)
    "#{col_string(col)}#{row + 1}"
  end

  def self.col_string(i)
    name = 'A'
    i.times { name.succ! }
    name
  end
end