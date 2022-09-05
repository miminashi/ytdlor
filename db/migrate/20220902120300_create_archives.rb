class CreateArchives < ActiveRecord::Migration[7.0]
  def change
    create_table :archives do |t|
      t.string :title
      t.string :original_url
      t.string :status

      t.timestamps
    end
  end
end
