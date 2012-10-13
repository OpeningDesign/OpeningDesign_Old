class UserToNode < ActiveRecord::Base

  validates_uniqueness_of :node_id, :scope => :user_id
  validates :vote, :numericality => { :less_than_or_equal_to => 360 }
  validates :vote, :numericality => { :greater_than_or_equal_to => 0 }
  validate :within_max_num_votes

  after_update :propagate_votes

  belongs_to :user
  belongs_to :node

  scope :by_user_and_node, lambda {|user, node| where "user_id = ? and node_id = ?", user.id, node.id }

  def has_voted(vote)
    self.vote = vote
    self.voted = true
    self.save
  end

  def remove_vote
    self.vote = 0
    self.voted = false
    self.save!
  end

  def self.get(user, node)
    UserToNode.by_user_and_node(user, node).first || UserToNode.create(:user => user, :node => node, :vote => 0)
  end

  private

  scope :voted, where(:voted => true)
  scope :by_user, lambda {|user| where "user_id = ?", user.id }

  def within_max_num_votes
    errors.add(:vote, "You cannot have more than 10 votes") if voted && UserToNode.by_user(user).voted.count >= 10
  end

  def propagate_votes
    node.propagate_votes_up
  end

end
