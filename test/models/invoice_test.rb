# == Schema Information
#
# Table name: invoices
#
#  id            :bigint           not null, primary key
#  user_id       :bigint           not null
#  emission_date :datetime
#  payment_date  :datetime
#  number        :integer
#  description   :string
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#
require "test_helper"

class InvoiceTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
end
