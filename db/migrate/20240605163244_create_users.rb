class CreateUsers < ActiveRecord::Migration[7.1]
  def change
    create_table :users do |t|
      t.string :name
      t.string :email
      t.string :college
      t.string :linkedin_link
      t.string :password_digest
      t.boolean :is_admin

      t.timestamps
    end
  end
end
