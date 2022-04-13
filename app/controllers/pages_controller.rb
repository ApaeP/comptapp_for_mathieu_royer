class PagesController < ApplicationController
  skip_before_action :authenticate_user!, only: %i[ home ]

  def home
  end

  def dashboard
    @quarter = Quarter.new(current_user)
    @quarters = [ @quarter.prev.prev, @quarter.prev, @quarter ].reverse

    @total_money = current_user.invoices.sum(&:full_price)
    @total_money_paid = current_user.invoices.paid.sum(&:full_price)
  end
end
