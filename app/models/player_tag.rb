class PlayerTag < ActiveRecord::Base
  belongs_to :player
  belongs_to :tag
end
