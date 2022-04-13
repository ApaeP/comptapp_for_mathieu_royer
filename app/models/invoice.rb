# == Schema Information
#
# Table name: invoices
#
#  id             :bigint           not null, primary key
#  user_id        :bigint           not null
#  client_id      :bigint           not null
#  payment_date   :datetime
#  monthly_number :integer
#  quarter        :integer
#  name           :string
#  description    :string
#  amount_cents   :integer          default(0)
#  subject_to_vat :boolean          default(FALSE)
#  created_at     :datetime         not null
#  updated_at     :datetime         not null
#
class Invoice < ApplicationRecord
  include ActionView::Helpers::NumberHelper

             # bleu   vert   gris
  COLORS = %w[ 6D98BA 418B82 66818F ]

  default_scope { order(created_at: :desc) }
  belongs_to :user
  belongs_to :client
  has_many :invoice_items, inverse_of: :invoice, dependent: :destroy

  accepts_nested_attributes_for :invoice_items, allow_destroy: true, reject_if: :all_blank

  validate do
    has_at_least_one_item
  end

  monetize :amount_cents, :amount_without_vat_cents

  before_create :set_monthly_number, :set_name, :set_quarter
  after_commit :set_if_subject_to_vat, :set_amount_with_vat, :set_amount_without_vat, on: %i[ create update ]

  scope :paid,          ->  { where.not(payment_date: nil).order(:created_at) }
  scope :unpaid,        ->  { where(payment_date: nil).order(:created_at) }
  scope :from_year,     -> (year: Time.now.year) { where(created_at: DateTime.new(year, 1, 1)..DateTime.new(year, -1, -1)).order(:created_at) }
  scope :from_quarter,  -> (year: Time.now.year, quarter: (Time.now.month / 3.0).ceil) { where(created_at: DateTime.new(year, 3 * quarter).all_quarter).order(:created_at) }
  scope :from_month,    -> (year: Time.now.year, month: Time.now.month) { where(created_at: DateTime.new(year, month, 1).all_month).order(:created_at) }
  scope :from_period,   -> (period, year: Time.now.year, month: Time.now.month, day: Time.now.day, quarter: (Time.now.month / 3.0).ceil) do
    range = case period
            when :year    then DateTime.new(year).all_year
            when :quarter then DateTime.new(year, 3 * quarter).all_quarter
            when :month   then DateTime.new(year, month).all_month
            when :day     then DateTime.new(year, month, day).all_day
            end
    where(created_at: range).order(:created_at)
  end

  def number
    year = created_at.year
    month = format('%02d', created_at.month)
    invoice_number = format('%03d', monthly_number)
    "#{year}#{month}_#{invoice_number}"
  end

  def short_description
    "#{description[0..32]}..."
  end

  def paid?
    payment_date.present?
  end

  def paid!
    update(payment_date: DateTime.now)
  end

  def unpaid!
    update(payment_date: nil)
  end

  def year
    created_at.year
  end

  def quarter
    (created_at.month / 3.0).ceil
  end

  def month
    created_at.month
  end

  def rand_color
    COLORS.sample
  end

  def vat_amount
    invoice_items.map(&:vat_amount).sum(Money.new(0))
  end

  private

  def set_monthly_number
    self.monthly_number = self.class.from_month(year: created_at.year, month: created_at.month).count + 1
  end

  def set_name
    self.name = "FAC_#{number}_#{client.fac_name}"
  end

  def set_quarter
    self.quarter = (created_at.month / 3.0).ceil
  end

  def set_amount_with_vat
    self.update_column(:amount_cents, self.invoice_items.sum(Money.new(0)) { |e| e.full_price } * 100)
  end

  def set_amount_without_vat
    self.update_column(:amount_without_vat_cents, self.invoice_items.sum(Money.new(0)) { |e| e.amount_without_vat } * 100)
  end

  def set_if_subject_to_vat
    self.update_column(:subject_to_vat, user.subject_to_vat?)
  end

  def has_at_least_one_item
    return if invoice_items.any?

    errors.add(:invoice_items, :missing_invoice_items, message: "should exist")
  end
end
