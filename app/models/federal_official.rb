class FederalOfficial < ApplicationRecord
    has_many :UsedTweets

    def self.add_officials
        xlsx = Roo::Spreadsheet.open('senators.xlsx')
        puts xlsx.info
        sheet = xlsx.sheet(0)
        sheet.each do |row|
            puts row[0]
            puts row[1]
            puts row[2]
            puts row[3]
            puts "-------"
            FederalOfficial.create(screen_name: row[2], name: row[1], state: row[0], position: "senator", party: row[3])
        end
    end
end
