module MonthsData

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
      opening_balance = current_balance || (start_balance * 100).to_i
      current_balance = opening_balance
      minimum_balance = current_balance
      month[:transactions].each do |transaction|
        current_balance += (transaction[:amount].to_s.delete(',').to_f * 100).to_i
        minimum_balance = current_balance if current_balance < minimum_balance
        transaction[:balance] = current_balance.to_f / 100
      end
      month[:opening_balance] = opening_balance.to_f / 100
      month[:closing_balance] = current_balance.to_f / 100
      month[:minimum_balance] = minimum_balance.to_f / 100
    end
  end

end