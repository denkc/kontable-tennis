class Player < ActiveRecord::Base
  has_many :winning_matches, class_name: 'Match', foreign_key: 'winner_id'
  has_many :losing_matches,  class_name: 'Match', foreign_key: 'loser_id'

  has_many :winning_games, class_name: 'Game', foreign_key: 'winner_id'
  has_many :losing_games,  class_name: 'Game', foreign_key: 'loser_id'
  
  has_many :player_tags
  has_many :tags, :through => :player_tags

  before_validation :downcase_name

  validates :name, presence: true
  validates_uniqueness_of :name
  validates_uniqueness_of :rank, :allow_nil => true

  scope :ranked, where('rank IS NOT NULL').order('rank asc')
  scope :active, where(:active => true)
  scope :inactive, where(:active => false)

  def display_name
    name.titleize
  end

  def self.active_names
    Player.active.pluck(:name).map(&:titleize)
  end

  def most_recent_match
    Match.where(['winner_id = ? OR loser_id = ?', id, id]).order('occured_at desc').first
  end

  def matches
    Match.where(['winner_id = ? OR loser_id = ?', id, id]).order('occured_at desc')
  end

  def games
    Game.where(['winner_id = ? OR loser_id = ?', id, id])
  end

  def ordered_games
    Game.joins(:match).where(['matches.winner_id = ? OR matches.loser_id = ?', id, id]).order('matches.occured_at desc, games.id desc')
  end
  
  def inactive?
    !active?
  end

  private

  def downcase_name
    self.name = self.name.downcase if self.name
  end

end
