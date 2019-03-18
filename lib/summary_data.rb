module SummaryData

  def self.months_summary(months, opening_balance)
    closing = nil
    months.map do |key, month|
      opening = closing || opening_balance
      closing = month[:transactions][-1][:balance]
      minimum = month[:transactions].map { |transaction| transaction[:balance] }.min
      minimum = opening if opening < minimum
      delta = ((closing * 100).to_i - (opening * 100).to_i).to_f / 100
      {
        month: key,
        opening: opening,
        minimum: minimum,
        closing: closing,
        delta: delta
      }
    end
  end

  def self.sheets_summary(transactions, sheet_names)
    sheet_names.map do |sheet_name|
      amounts = transactions.select { |t| t[:sheet_name] == sheet_name }.map { |t| t[:amount].to_f }
      income = amounts.select { |amount| amount > 0 }.map { |amount| amount * 100.to_i }.reduce(:+).to_f / 100
      expenditure = amounts.select { |amount| amount < 0 }.map { |amount| amount * 100.to_i }.reduce(:+).to_f / 100
      {
        sheet_name: sheet_name,
        income: income,
        expenditure: expenditure,
        balance: ((income * 100).to_i + (expenditure * 100).to_i).to_f / 100
      }
    end
  end

end