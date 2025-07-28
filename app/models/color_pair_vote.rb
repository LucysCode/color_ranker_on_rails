class ColorPairVote < ApplicationRecord
    belongs_to :user, optional: true
end
