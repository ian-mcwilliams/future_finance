require_relative 'config'
require_relative 'lib/generate_report'

params = Config.run_parameters

GenerateReport.generate_report(params)