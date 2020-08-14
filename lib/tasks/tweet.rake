desc "Select random tweet from federal official and tweet to client twitter account"
task :tweet => :environment do
    # the => environment is a dependency for this task
    # allows us to call Active Record Models in this task
    puts "Tweeting..."
    Bot.task
    puts "Done Tweeting"
end