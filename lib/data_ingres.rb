require_relative 'google_spreadsheet_wrapper'

module DataIngres

  def self.current_balance_from_sheets(hash_spreadsheet)
    hash_account_sheets = hash_spreadsheet.select { |k, _| k =~ /^\d{4}$/ }
    hash_account_sheets.reverse_each do |_, current_sheet|
      current_balance = current_balance_from_sheet(current_sheet)
      return current_balance if current_balance
    end
    nil
  end

  def self.current_balance_from_sheet(current_sheet)
    balance_cells = current_sheet[:cells].select { |_, v| v == { value: 'BALANCE' } }
    return nil if balance_cells.empty?
    max_balance_index = balance_cells.map { |k, _| k[/\d+$/].to_i }.max
    bank_balance_column_index = column_index(current_sheet, 'balance')
    cell_key = "#{bank_balance_column_index}#{max_balance_index}"
    current_sheet[:cells][cell_key][:value].delete(',').delete('.').to_f / 100
  end

  def self.column_index(current_sheet, column_header)
    cell_keys = current_sheet[:cells].select { |_, v| v[:value] == column_header }.keys
    raise("no instance of column header 'bank_balance' found") if cell_keys.count < 1
    raise("more than one instance of 'bank_balance' found") if cell_keys.count > 1
    cell_keys[0][/^\D+/]
  end

  def self.table_sheet_to_hash_array(hash_sheet, sheet_name)
    headers = hash_sheet.select { |k, _| k =~ /^\D+1$/ }
    row_max = hash_sheet.keys.map { |k| k[/\d+/].to_i }.max
    (2..row_max).map do |row_id|
      current_row = hash_sheet.select { |k, _| k =~ /^\D#{Regexp.quote(row_id.to_s)}$/ }
      current_hash = headers.each_with_object({}) do |(cell_key, cell), h|
        target_cell_key = "#{cell_key[/^\D+/]}#{row_id}"
        h[cell[:value]] = cell_value(current_row, target_cell_key, cell[:value])
      end
      current_hash['sheet_name'] = sheet_name
      current_hash
    end
  end

  def self.cell_value(row, cell_key, header)
    return nil unless row.has_key?(cell_key)
    return row[cell_key][:value] if header != 'amount' || row[cell_key][:value].nil?
    value = row[cell_key][:value].to_s.to_f.round(2).to_s
    (2 - (value.length - 1 - value.index('.'))).times { value << '0' }
    value
  end

  def self.transactions_from_sheets(hash_spreadsheets)
    hash_spreadsheets.each_with_object([]) do |(sheet_name, hash_spreadsheet), a|
      a.concat(table_sheet_to_hash_array(hash_spreadsheet, sheet_name))
    end
  end

end