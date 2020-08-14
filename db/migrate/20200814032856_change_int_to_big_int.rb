class ChangeIntToBigInt < ActiveRecord::Migration[6.0]
  def change
    change_column :used_tweets, :tweet_id, :bigint
  end
end
