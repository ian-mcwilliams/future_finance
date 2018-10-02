require 'date'
require_relative 'data_ingres'

module ReportData
  include DataIngres

  def self.report_data(source, filename)
    hash_spreadsheet = source.hash_spreadsheet(filename)
    input_data = {
      current_balance: DataIngres.current_balance_from_sheets(hash_spreadsheet),
      transactions: DataIngres.transactions_from_sheet(hash_spreadsheet)
    }
    hash_future_finance(input_data)
  end

  def self.hash_future_finance(input_data)
    transactions = all_extracted_transactions(input_data[:transactions])
    transactions
  end

  def self.all_extracted_transactions(raw_transactions)
    transactions = []
    raw_transactions.each do |raw_transaction|
      transactions.concat(extracted_transactions(raw_transaction))
    end
    transactions
  end

  def self.extracted_transactions(raw_transaction)
    duration_days = 365
    today = DateTime.now
    end_date = DateTime.parse(raw_transaction['final_payment']) unless raw_transaction['final_payment'].empty?
    end_date ||= today + duration_days
    transactions = []
    if raw_transaction['frequency'] == 'monthly'
      current_date = today
      (duration_days / 27).times do
        current_date = next_month_date(current_date, end_date, raw_transaction['payment_date'])
        break if current_date.nil?
        transactions << transaction_hash(current_date, raw_transaction)
        current_date += 1
      end
    elsif raw_transaction['frequency'] == 'annual'
      current_date = today
      (duration_days / 365).times do
        current_date = next_year_date(current_date, end_date, raw_transaction['payment_date'])
        break if current_date.nil?
        transactions << transaction_hash(current_date, raw_transaction)
        current_date += 1
      end
    elsif raw_transaction['frequency'] == 'quarterly'
      current_date = today
      (duration_days / 91).times do
        current_date = next_quarter_date(current_date, end_date, raw_transaction['payment_date'])
        break if current_date.nil?
        transactions << transaction_hash(current_date, raw_transaction)
        current_date += 1
      end
    end
    transactions
  end

  def self.transaction_hash(current_date, transaction)
    {
      type: transaction['type'],
      payee: transaction['payee'],
      purpose: transaction['purpose'],
      date: current_date,
      description: transaction['description'],
      amount: transaction['amount']
    }
  end

  def self.next_quarter_date(start_date, end_date, payment_date)
    current_date = start_date
    valid_months = payment_date[/(\S{3}\/){3}\S{3}/].split('/')
    3.times do
      current_date = next_month_date(current_date, end_date, payment_date[/\d+\S{2}/])
      break if current_date.nil?
      return current_date if valid_months.include?(current_date.strftime('%b').downcase)
      current_date += 1
    end
    nil
  end

  def self.next_year_date(start_date, end_date, payment_date)
    current_year = start_date.strftime('%Y')
    target_date = DateTime.parse("#{payment_date} #{current_year}")
    target_date = target_date >= start_date ? target_date : target_date.next_year
    target_date > end_date ? nil : target_date
  end

  def self.next_month_date(start_date, end_date, payment_date)
    target_string = "#{start_date.strftime('%Y/%m')}/#{payment_date[/\d+/]}"
    target_date = DateTime.parse(target_string)
    today_date = DateTime.parse(start_date.strftime('%Y/%m/%d'))
    target_date = target_date >= today_date ? target_date : target_date.next_month
    target_date > end_date ? nil : target_date
  end

end

{
  "type" => "registration",
  "payee" => "companies house",
  "purpose" => "registration fee",
  "frequency" => "annual",
  "payment date" => "31st october",
  "desc" => "",
  "amount" => "13.00",
  "precision" => "actual",
  "final payment" => ""
}