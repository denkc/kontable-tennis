class Tag < ActiveRecord::Base
  has_many :player_tags
  has_many :players, :through => :player_tags
  accepts_nested_attributes_for :players
  attr_accessible :player_ids
  
  validates :name, presence: true
  validates_uniqueness_of :name
  
  before_validation :downcase_name
  
  def self.names
    Tag.pluck(:name).map(&:titleize)
  end
  
  def downcase_name
    self.name = self.name.downcase if self.name
  end
  
  def display_name
    name.titleize
  end
end
