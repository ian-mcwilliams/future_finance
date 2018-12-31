require 'date'
require_relative 'data_ingres'

module ReportData
  include DataIngres

  def self.report_data(source, filename)
    hash_spreadsheet = source.hash_spreadsheet(filename)
    input_data = planner_data(DataIngres.transactions_from_sheet(hash_spreadsheet))
    transactions = all_extracted_transactions(input_data)
    { months: hash_months(transactions, input_data[:opening_balance]) }
  end

  def planner_data(transactions)
    transactions.delete_if { |item| item.values.delete_if(&:empty?).empty? }
    run_spec = transactions.delete_at(0)
    {
      transactions: transactions,
      start_date: DateTime.parse(run_spec['payee']),
      end_date: DateTime.parse(run_spec['frequency']),
      opening_balance: run_spec['position'].delete('.').to_i
    }
  end

  def self.hash_months(transactions, opening_balance)
    months = transactions.map { |transaction| transaction[:date].strftime('%y%m') }.uniq
    draft_hash_months = months.each_with_object({}) do |month, h|
      month_transactions = transactions.select { |t| t[:date].strftime('%y%m') == month }
      h[month] = { transactions: month_transactions }
    end
    positioned_transactions(draft_hash_months)
    balanced_transactions(draft_hash_months, opening_balance)
    draft_hash_months
  end

  def self.positioned_transactions(draft_hash_months)
    draft_hash_months.values.each do |month|
      last_transactions = month[:transactions].select { |transaction| transaction[:last] }
      month[:transactions].delete_if { |transaction| transaction[:last] }
      month[:transactions].concat(last_transactions)
      month[:transactions].each { |transaction| transaction.delete(:last) }
      last_transactions = month[:transactions].select { |transaction| transaction[:first] }
      month[:transactions].delete_if { |transaction| transaction[:first] }
      month[:transactions] = last_transactions + month[:transactions]
      month[:transactions].each { |transaction| transaction.delete(:first) }
    end
  end

  def self.balanced_transactions(draft_hash_months, start_balance)
    current_balance = nil
    draft_hash_months.values.each do |month|
      opening_balance = current_balance || start_balance
      current_balance = opening_balance
      minimum_balance = current_balance
      month[:transactions].each do |transaction|
        current_balance += (transaction[:amount].delete(',').to_f * 100).to_i
        minimum_balance = current_balance if current_balance < minimum_balance
        transaction[:balance] = current_balance.to_f / 100
      end
      month[:opening_balance] = opening_balance.to_f / 100
      month[:closing_balance] = current_balance.to_f / 100
      month[:minimum_balance] = minimum_balance.to_f / 100
    end
  end

  def self.all_extracted_transactions(input_data)
    extracted_transactions = []
    input_data[:transactions].each do |raw_transaction|
      extracted_transactions.concat(extracted_transactions(raw_transaction, input_data[:start_date], input_data[:end_date]))
    end
    extracted_transactions.sort_by { |item| item[:date] }
  end

  def self.extracted_transactions(raw_transaction, start_date, end_date)
    if raw_transaction['purpose'] == 'corporation tax'
      i=0
    end
    duration_days = (end_date - start_date).to_i
    end_date = DateTime.parse(raw_transaction['final_payment']) unless raw_transaction['final_payment'].empty?
    end_date ||= start_date + duration_days
    transactions = []
    case raw_transaction['frequency']
    when 'weekly'
      current_date = start_date
      ((duration_days / 7) + 1).times do
        current_date = next_week_date(current_date, end_date, raw_transaction['payment_date'])
        break if current_date.nil?
        transactions << transaction_hash(current_date, raw_transaction)
        current_date += 1
      end
    when 'monthly'
      current_date = start_date
      ((duration_days / 27) + 1).times do
        current_date = next_month_date(current_date, end_date, raw_transaction['payment_date'])
        break if current_date.nil?
        transactions << transaction_hash(current_date, raw_transaction)
        current_date += 1
      end
    when 'annual'
      current_date = start_date
      ((duration_days / 365) + 1).times do
        current_date = next_year_date(current_date, end_date, raw_transaction['payment_date'])
        break if current_date.nil?
        transactions << transaction_hash(current_date, raw_transaction)
        current_date += 1
      end
    when 'quarterly'
      current_date = start_date
      ((duration_days / 91) + 1).times do
        current_date = next_quarter_date(current_date, end_date, raw_transaction['payment_date'])
        break if current_date.nil?
        transactions << transaction_hash(current_date, raw_transaction)
        current_date += 1
      end
    when 'one-off'
      current_date = start_date
      target_date = DateTime.parse(raw_transaction['payment_date'])
      if current_date <= target_date && target_date <= end_date
        transactions << transaction_hash(target_date, raw_transaction)
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
      amount: transaction['amount'],
      last: transaction['payment_date'] == 'last',
      first: transaction['position'] == 'first'
    }
  end

  def self.next_week_date(start_date, end_date, payment_date)
    target_date = start_date
    target_day = DateTime.parse(payment_date).strftime('%u')
    7.times do
      target_date += 1 unless target_date.strftime('%u') == target_day
    end
    target_date > end_date ? nil : target_date
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
    if payment_date == 'last'
      target_date = DateTime.new(start_date.year, start_date.month, -1)
    else
      target_string = "#{start_date.strftime('%Y/%m')}/#{payment_date[/\d+/]}"
      target_date = DateTime.parse(target_string)
    end
    today_date = DateTime.parse(start_date.strftime('%Y/%m/%d'))
    target_date = target_date >= today_date ? target_date : target_date.next_month
    target_date > end_date ? nil : target_date
  end

end
