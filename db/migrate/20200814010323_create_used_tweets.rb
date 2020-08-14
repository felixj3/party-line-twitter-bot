class CreateUsedTweets < ActiveRecord::Migration[6.0]
  def change
    create_table :used_tweets do |t|
      t.integer :tweet_id
      t.belongs_to :federal_official

      t.timestamps
    end
  end
end
