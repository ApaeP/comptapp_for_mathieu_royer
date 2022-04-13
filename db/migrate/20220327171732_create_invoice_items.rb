class CreateInvoiceItems < ActiveRecord::Migration[7.0]
  def change
    create_table :invoice_items do |t|
      t.references :invoice, null: false, foreign_key: true
      t.string :name
      t.integer :unit_price_cents
      t.float :quantity
      t.float :vat_rate, default: 0

      t.timestamps
    end
  end
end
