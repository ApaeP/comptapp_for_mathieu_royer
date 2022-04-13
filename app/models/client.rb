# == Schema Information
#
# Table name: clients
#
#  id         :bigint           not null, primary key
#  user_id    :bigint           not null
#  name       :string
#  address    :string
#  country    :string
#  rcs        :string
#  siret      :string
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
class Client < ApplicationRecord
  belongs_to :user
  has_many :invoices, dependent: :destroy

  has_one_attached :logo

  validates :name, presence: true

  def fac_name
    name.split.map(&:downcase).join('_')
  end

  def initials
    name.split.map { |e| e.first.upcase }.join
  end

  def safe_logo
    if logo.attached? && logo.blob&.representable?
      logo.url
    else
      'basic_logo.png'
    end
  end
end
