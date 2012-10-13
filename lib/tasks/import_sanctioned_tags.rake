namespace :odb do
  desc "Import sanctioned tags from a csv file"
  task :import_sanctioned_tags, [:file] => :environment do |t, args|
    puts "About to import sanctioned tags from file #{args[:file]}. Currently, there are #{SanctionedTag.count} sanctioned tags in the database"
    num_imported = 0
    CSV.foreach(args[:file]) do |row|
      print "...#{row[0]}"
      num_imported += 1 if SanctionedTag.create(:name => row[0]).valid?
    end
    puts "\nImported #{num_imported} sanctioned tags"
  end
end
