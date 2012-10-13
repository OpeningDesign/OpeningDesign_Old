class DocumentVersionsController < ApplicationController
  filter_resource_access
  def show
    @document_version = DocumentVersion.find(params[:id])
  end

  def download
    @version = DocumentVersion.find(params[:id])
    @version.update_attribute(:downloads_count, @version.downloads_count + 1)
    redirect_to @version.content.expiring_url(3)
  end

end
