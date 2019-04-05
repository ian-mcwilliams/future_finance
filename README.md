# Future Finance

Just a quick description to help anyone that wants to try out this minimal sketch of a tool.

## Usage

Clone the project to your local environment

Set up your input spreadsheet and parameters yaml (you may need to create the artefacts directory as a child of root)

From the root directory:

```ruby
ruby run.rb
```

## Filling in the spreadsheet

See sample_planner.xlsx in the spec dir for example input sheet.

### frequency (required)
Frequency can be "annual", "monthly", "weekly" or "one-off"

### payment_date (required)
If annual, specify the date eg "25th Aug", "2nd Jun"
If monthly, specify the date eg "1st", "15th"
If weekly, specify day eg "Mon", "Wed"
If one-off specify the date eg "01/12/2019"

If "first" or "last" is specified in the date column, the system will make it the first/last in that given time period (only confirmed it works for month, and if two firsts/lasts are specified, then who knows what will happen!)

### position (optional)
If "first" or "last" is specified in the position column, it will position the item to first or last for the date of the particular instance

### amount (required)
Prefix with a minus for a cost, without one for income

### start_date (optional)
Add a start date, this line will only be included on and after this date eg 11/09/2019

### end_date (optional)
Add an end date, this line will only be included before and on this date eg 11/09/2019

### description columns
type, payee, purpose and description - put any value as desired, they contextualise the output but can be used as best fits your needs

## Run Files

### Spreadsheet

Save the completed planner file in the project's artefacts dir.

The file can have any name you like, see the parameters.yml for how the sheet will be run.

One or many sheets can be specified for the run, see the description of the parameters.yml for how it will be run.

### Parameters

The artefacts dir must contain a file called parameters.yml with content like this:

```
run: basic
basic:
  start_date: 06/04/2019
  end_date: 05/04/2020
  opening_balance: 2000.00
  source: excel
  filename: sample_planner
  sheet_names:
    - bills
    - income
```

#### run

add the name of the config you want to run (notice that the line below matches this key)

#### start_date
the start date for this planning (often tomorrow)

#### end_date
the end date for this planning (perhaps a year today)

#### opening balance
the start balance on the opening date (can be negative)

#### source
excel, always excel

#### filename
the name of the excel file you have put in artefacts (don't include the filename extension here)

#### sheet_names
the names of the sheets in the specified file you want to be included

