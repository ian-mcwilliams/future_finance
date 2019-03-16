module SummaryData

  def self.months_summary(months, opening_balance)
    closing = nil
    months.map do |key, month|
      opening = closing || opening_balance
      closing = month[:transactions][-1][:balance]
      minimum = month[:transactions].map { |transaction| transaction[:balance] }.min
      minimum = opening if opening < minimum
      {
        month: key,
        opening: opening,
        minimum: minimum,
        closing: closing,
        delta: closing - opening
      }
    end
  end

end