require 'awesome_print'
require 'bundler'

module GoogleSpreadsheetWrapper
  def self.hash_spreadsheet(google_filename)
    google_spreadsheet_to_hash_spreadsheet(google_spreadsheet(google_filename))
  end

  def self.create_google_spreadsheet(google_filename)
    session = GoogleDrive::Session.from_service_account_key('client_secret.json')
    puts '......'
    spreadsheet = session.create_spreadsheet(google_filename)
    worksheet = spreadsheet.add_worksheet('first_sheet')
    worksheet.save
  end

  def self.google_spreadsheet(google_filename)
    session = GoogleDrive::Session.from_service_account_key('client_secret.json')
    session.spreadsheet_by_title(google_filename)
  end

  def self.google_spreadsheet_to_hash_spreadsheet(google_spreadsheet)
    hash_spreadsheet = google_spreadsheet.worksheets.each_with_object({}) do |google_worksheet, current_hash|
      current_hash[google_worksheet.title] = {
        cells: google_worksheet_to_hash_cells(google_worksheet)
      }
    end
    hash_spreadsheet
  end

  def self.google_worksheet_to_hash_cells(google_worksheet)
    hash_cells = {}
    google_worksheet.rows.each_with_index do |google_row, row_i|
      google_row.each_with_index do |cell_value, col_i|
        hash_cells[RubyXL::Reference.ind2ref(row_i, col_i)] = {
          value: cell_value
        }
      end
    end
    hash_cells
  end
end