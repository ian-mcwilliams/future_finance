require 'rxl'

module ExcelSpreadsheetWrapper
  def self.hash_spreadsheet(params)
    file = Rxl.read_file("artefacts/#{params[:filename]}.xlsx")
    file.keys.each { |key| file.delete(key) unless params[:sheet_names].include?(key) }
    file
  end
end