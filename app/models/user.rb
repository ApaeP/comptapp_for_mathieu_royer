# == Schema Information
#
# Table name: users
#
#  id                     :bigint           not null, primary key
#  email                  :string           default(""), not null
#  encrypted_password     :string           default(""), not null
#  reset_password_token   :string
#  reset_password_sent_at :datetime
#  remember_created_at    :datetime
#  first_name             :string
#  last_name              :string
#  provider               :string
#  uid                    :string
#  github_name            :string
#  avatar_url             :string
#  business_name          :string
#  business_address       :string
#  business_country       :string
#  siret                  :string
#  iban                   :string
#  bic                    :string
#  created_at             :datetime         not null
#  updated_at             :datetime         not null
#
class User < ApplicationRecord
  VAT_TRIGGER_AMOUNT = 34_400

  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable, :omniauthable

  has_many :clients, dependent: :destroy
  has_many :invoices, dependent: :destroy
  has_many :invoice_items, through: :invoices

  has_one_attached :logo

  validates :email, presence: true

  def self.from_omniauth(auth)
    where(provider: auth.provider, uid: auth.uid).first_or_create do |user|
      user.provider = auth.provider
      user.first_name, user.last_name = auth.info.name.split
      user.avatar_url = auth.extra.raw_info.avatar_url
      user.uid = auth.uid
      user.github_name = auth.info.nickname
      user.email = auth.info.email
      user.password = Devise.friendly_token[0, 20]
    end
  end

  def safe_avatar_url
    avatar_url || 'default_avatar.png'
  end

  def full_name
    return email unless first_name.present? && last_name.present?

    "#{first_name.capitalize} #{last_name.upcase}"
  end

  def invoices_from_current_year
    invoices.from_year
  end

  def total_from_current_year
    invoices_from_current_year.sum(Money.new(0)) { |e| e.amount }
  end

  def subject_to_vat?
    total_from_current_year.to_f > VAT_TRIGGER_AMOUNT
  end
end
