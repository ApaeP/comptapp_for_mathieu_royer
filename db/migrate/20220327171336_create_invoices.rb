class CreateInvoices < ActiveRecord::Migration[7.0]
  def change
    create_table :invoices do |t|
      t.references :user, null: false, foreign_key: true
      t.references :client, null: false, foreign_key: true
      t.datetime :payment_date
      t.integer :monthly_number
      t.integer :quarter
      t.string :name
      t.string :description
      t.integer :amount_without_vat_cents, default: 0
      t.integer :amount_cents, default: 0
      t.boolean :subject_to_vat, default: false

      t.timestamps
    end
  end
end
