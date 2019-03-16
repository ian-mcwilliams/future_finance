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

end