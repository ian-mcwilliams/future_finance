require_relative 'lib/generate_report'

include GenerateReport

filename = 'f3m_finance'

GenerateReport.generate_report(filename)