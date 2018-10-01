require_relative 'data_ingres'

module ReportData
  include DataIngres

  def self.report_data(hash_spreadsheet)
    input_data = {
      current_balance: DataIngres.current_balance_from_sheets(hash_spreadsheet),
      transactions: DataIngres.transactions_from_sheet(hash_spreadsheet)
    }
    input_data
  end

end