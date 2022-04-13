class Quarter
  include ActionView::Helpers::NumberHelper

  attr_reader :year, :number, :invoices

  def initialize(user, year: Time.now.year, number: (Time.now.month / 3.0).ceil)
    @user     = user
    @year     = year
    @number   = number
    @invoices = @user.invoices.from_quarter(year: year, quarter: number)
  end

  def name
    "#{@number.ordinalize} trimestre #{@year}"
  end

  def total_money
    @total_money ||= @invoices.sum(&:full_price)
  end

  def prev
    @prev ||= Quarter.new(@user, year: previous_quarter_year, number: previous_quarter_number)
  end

  def previous_quarter_number
    [*1..4][(@number - 2) % 4]
  end

  def previous_quarter_year
    @number == 1 ? Time.now.year - 1 : Time.now.year
  end

  def percentage_to_previous_quarter
    @percentage_to_previous_quarter ||=
      100 * ( (total_money - prev.total_money).fdiv(prev.total_money) )
      .round(2)
  end

  def next
    @next ||= Quarter.new(@user, year: next_quarter_year, number: next_quarter_number)
  end

  def next_quarter_number
    [*1..4][(@number) % 4]
  end

  def next_quarter_year
    @number == 4 ? Time.now.year + 1 : Time.now.year
  end

  def percentage_to_next_quarter

  end
end
