require 'pry'
require 'csv'
require 'date'


class OfficeReservations

  def initialize(date)
    @date = date
  end

  def data
    file = 'data.csv'
    csv = CSV.read(file)
    csv.shift(1)
    output = []
    csv.each do |office|
      data_hash = {}
      data_hash[:capacity] = office[0]
      data_hash[:monthlyprice] = office[1]
      data_hash[:startday] = Date.strptime(office[2],"%m/%d/%y")
      if office[3] == nil
        data_hash[:endday] = "current"
      else
        data_hash[:endday] = Date.strptime(office[3],"%m/%d/%y")
      end
      output << data_hash
    end
    output
  end

  def month
    Date.strptime(@date,"%Y-%m")
  end

  def days_in_month
    Date.new(@date[0..4].to_i, @date[6..7].to_i, -1).day
  end

  def month_range
    month_end = month + days_in_month
    range = (month...month_end)
  end

  def prorate(startdate,enddate)
    if enddate == "current"
      if startdate > month
        days = days_in_month - (startdate.day - month.day)
      else
        days = days_in_month
      end
    else
      if startdate > month
        days = days_in_month - (startdate.day - month.day)
      elsif enddate < (month + days_in_month- 1)
        days = enddate - month
      else
        days = days_in_month
      end
    end
    percentage = days.to_f/days_in_month
  end

  def in_month?(startdate,enddate)
    if enddate == "current"
      if month_range.include?(startdate) || startdate < month
        true
      else
        false
      end
    else
      if month_range.include?(startdate) || month_range.include?(enddate)
        true
      elsif startdate < month && enddate >= month
        true
      else
        false
      end
    end
  end

  def sum_revenue
    revenue = 0
    data.each do |line|
      if in_month?(line[:startday],line[:endday])
        revenue += prorate(line[:startday],line[:endday]) * line[:monthlyprice].to_f
      end
    end
    revenue.round(2)
  end

  def unreserved_capacity
    capacity = 0
    data.each do |line|
      if in_month?(line[:startday],line[:endday]) == false
        capacity += line[:capacity].to_f
      end
    end
    capacity.to_i
  end

  def output
    "expected revenue: $#{sum_revenue}, expected total capacity of the unreserved offices: #{unreserved_capacity}"
  end

end

puts OfficeReservations.new("2014-08").output
