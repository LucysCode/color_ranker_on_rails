# This ColorVote model is where you define attributes, validations, and custom methods related to the ColorVote object. 

class ColorVote < ApplicationRecord
    validates :hex_color, presence: true, uniqueness: true
    validate :only_one_vote_type

    private

    def only_one_vote_type
      if is_ugly && is_nice
        errors.add(:base, "A color can't be both ugly and nice.")
      end
    end
end
