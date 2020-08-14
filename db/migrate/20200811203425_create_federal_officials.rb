class CreateFederalOfficials < ActiveRecord::Migration[6.0]
  def change
    create_table :federal_officials do |t|
      t.string :screen_name
      t.string :name
      t.string :state
      t.string :position
      t.string :party

      t.timestamps
    end
  end
end
