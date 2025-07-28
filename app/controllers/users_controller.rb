class UsersController < ApplicationController
  before_action :authenticate_user!

  def my_votes
    @nice_color_votes = current_user.color_votes.where(is_nice: true)
    @ugly_color_votes = current_user.color_votes.where(is_ugly: true)

    @nice_color_pair_votes = current_user.color_pair_votes.where(is_nice: true)
    @ugly_color_pair_votes = current_user.color_pair_votes.where(is_ugly: true)
  end
end
