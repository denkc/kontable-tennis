class Tag < ActiveRecord::Base
  has_many :player_tags
  has_many :players, :through => :player_tags
  accepts_nested_attributes_for :players
  attr_accessible :player_ids
  
  validates :name, presence: true
  validates_uniqueness_of :name
  
  def self.names
    Tag.pluck(:name)
  end
end
