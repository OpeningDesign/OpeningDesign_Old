namespace :paperclip_migration do
  desc "migrate files from filesystem to s3"
  task :migrate_to_s3 => :environment do
    klasses = [:document_version] # Replace with your real model names. If anyone wants to this could be picked up from args or from configuration.
    klasses.each do |klass_key|
      if klass = real_klass(klass_key)
        if klass.respond_to?(:attachment_definitions) && definitions = klass.attachment_definitions
          klass.all.each do |record|
            definitions.keys.each do |definition|
              if record.send("#{definition}_file_name")
                attachment = Paperclip::Attachment.new(definition.to_sym, record, definitions[definition.to_sym].except(:s3_credentials, :storage, :path))
                styles = attachment.styles.keys
                # I *think* we override randomly the wrong style? Maybe we should assign the
                # :original style only?
                # TODO
                styles = [ :original ]
                styles.each do |style|
                  fname = Rails.root.to_s + "/public/system/contents/#{record.id}/#{style.to_s}/#{attachment.original_filename}"
                  if File.exists?(fname)
                    file_data = File.open(fname)
                    puts "Saving file: #{fname} to Amazon S3..."
                    record.send("#{definition}").assign file_data
                    record.send("#{definition}").save
                  else
                    puts "Can't find file: #{fname} NOT MIGRATING..."
                  end
                end
              end
            end
          end
        else
          puts "There are not paperclip attachments defined for the class #{klass.to_s}"
        end
      else
        puts "#{key.to_s.classify} is not defined in this app."
      end
    end
  end

  def real_klass(key)
    key.to_s.classify.constantize
  rescue
  end
end
