class NodeImage < ActiveRecord::Base
  belongs_to :node
  has_attached_file :media,
    :styles => { :thumb => "32x32>", :original => "360x360>" },
    :path => "/node_images/:id/:style/:filename",
    :storage => :s3,
    :s3_credentials => Odr::Application.s3_credentials,
    :bucket => SimpleConfig.s3_bucket,
    :s3_permissions => 'private',
    :s3_protocol => 'https',
    :s3_headers => {"Content-Disposition" => "attachment"},
    :whiny => false
  # attr_accessible :title, :body

  def url
    media.expiring_url(240, :original)
  end

end
