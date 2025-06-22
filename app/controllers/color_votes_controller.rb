class ColorVotesController < ApplicationController
    def destroy
    @color_vote = ColorVote.find(params[:id])
    @color_vote.destroy

    redirect_to rank_colors_path, notice: "Vote deleted."
    end
end
