require 'date'
require_relative 'data_ingres'
require_relative 'months_data'
require_relative 'summary_data'
require_relative 'transaction_extractor'

module ReportData
  include DataIngres

  def self.report_data(source, params)
    hash_spreadsheets = source.hash_spreadsheet(params)
    source_transactions = DataIngres.transactions_from_sheets(hash_spreadsheets)
    transactions = TransactionExtractor.all_extracted_transactions(source_transactions, params)
    data = { months: MonthsData.hash_months(transactions, params[:opening_balance]) }
    data[:months_summary] = SummaryData.months_summary(data[:months], params[:opening_balance])
    data[:sheets_summary] = SummaryData.sheets_summary(transactions, params[:sheet_names])
    data
  end

end
