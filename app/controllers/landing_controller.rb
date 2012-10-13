class LandingController < ApplicationController

  def index
    @social_activities = Activities.aggregated[0..300]
    @popular_projects = Project.root_projects.by_popularity.limit(10)
    @tags = Node.tag_counts_on(:tags)
  end

  def unsupported
    @skip_redirect_for_unsupported = true
  end

end
