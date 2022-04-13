class CreateClients < ActiveRecord::Migration[7.0]
  def change
    create_table :clients do |t|
      t.references :user, null: false, foreign_key: true
      t.string :name
      t.string :address
      t.string :country
      t.string :rcs
      t.string :siret

      t.timestamps
    end
  end
end
