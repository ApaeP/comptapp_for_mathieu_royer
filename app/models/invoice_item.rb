# == Schema Information
#
# Table name: invoice_items
#
#  id               :bigint           not null, primary key
#  invoice_id       :bigint           not null
#  name             :string
#  unit_price_cents :integer
#  quantity         :float
#  vat_rate         :float            default(0.0)
#  created_at       :datetime         not null
#  updated_at       :datetime         not null
#
class InvoiceItem < ApplicationRecord
  VAT_RATE = 20

  belongs_to :invoice

  monetize :unit_price_cents

  validates :name, presence: true
  validates :unit_price_cents, presence: true
  validates :quantity, presence: true

  delegate :user, to: :invoice

  before_commit :set_vat_rate, on: %i[ create update ]

  def amount_without_vat
    unit_price * quantity
  end

  def vat_amount
    (amount_without_vat / 100) * vat_rate
  end

  def full_price
    amount_without_vat + vat_amount
  end

  def human_price
    "#{full_price} €"
  end

  private

  def set_vat_rate
    if user.subject_to_vat? || invoice.subject_to_vat
      self.update_column(:vat_rate, VAT_RATE)
    else
      if user.total_from_current_year + amount_without_vat > User::VAT_TRIGGER_AMOUNT.to_money
        over_trigger_amount               = user.total_from_current_year + amount_without_vat - User::VAT_TRIGGER_AMOUNT.to_money
        number_of_units_over_tax_trigger  = ((user.total_from_current_year + amount_without_vat - User::VAT_TRIGGER_AMOUNT.to_money) / unit_price).ceil(2)
        number_of_units_under_tax_trigger = (quantity - number_of_units_over_tax_trigger).ceil(2)

        self.update_column(:quantity, number_of_units_under_tax_trigger)
        self.invoice.update_column(:subject_to_vat, true)
        self.class.create(
          invoice: invoice,
          name: name,
          unit_price_cents: unit_price_cents,
          quantity: number_of_units_over_tax_trigger,
          vat_rate: VAT_RATE
        )
      end
    end
  end
end
