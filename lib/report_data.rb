require 'date'
require_relative 'data_ingres'

module ReportData
  include DataIngres

  def self.report_data(source, filename)
    hash_spreadsheet = source.hash_spreadsheet(filename)
    input_data = {
      opening_balance: DataIngres.current_balance_from_sheets(hash_spreadsheet),
      transactions: DataIngres.transactions_from_sheet(hash_spreadsheet)
    }
    transactions = all_extracted_transactions(input_data[:transactions])
    { months: hash_months(transactions, input_data[:opening_balance]) }
  end

  def self.hash_months(transactions, opening_balance)
    months = transactions.map { |transaction| transaction[:date].strftime('%y%m') }.uniq
    current_balance = (opening_balance * 100).to_i
    minimum_balance = current_balance
    months.each_with_object({}) do |month, h|
      h[month] = { opening_balance: current_balance.to_f / 100 }
      raw_month_transactions = transactions.select { |t| t[:date].strftime('%y%m') == month }
      processed_month_transactions = []
      raw_month_transactions.map do |t|
        current_balance += t[:amount].delete('.').to_i
        minimum_balance = current_balance if current_balance < minimum_balance
        processed_month_transactions << { balance: current_balance.to_f / 100 }.merge(t)
      end
      h[month][:transactions] = processed_month_transactions
      h[month][:closing_balance] = current_balance.to_f / 100
      h[month][:minimum_balance] = minimum_balance.to_f / 100
    end
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
