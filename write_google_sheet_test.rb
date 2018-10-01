require_relative 'lib/google_spreadsheet_wrapper'
require 'awesome_print'


def load_sheet
  hash_spreadsheet = GoogleSpreadsheetWrapper.google_spreadsheet_as_hash_spreadsheet('f3m_finance')
  balance = current_balance_from_sheets(hash_spreadsheet)
  ap balance
  all_transactions = transactions_from_sheet(hash_spreadsheet)
  ap all_transactions
end

def write_sheet
  google_filename = 'test_write_sheet'
  GoogleSpreadsheetWrapper.create_google_spreadsheet(google_filename)
end

write_sheet
