class ColorVotesController < ApplicationController
  def destroy
    @color_vote = ColorVote.find(params[:id])
    list_flag   = @color_vote.is_ugly ? :ugly : :nice    # which list it's in
    deleted_pos = @color_vote.position
    @color_vote.destroy

    # Shift positions of the remaining votes in the same list ↓1
    ColorVote.where(session_id: session[:session_id],
                    is_ugly:   @color_vote.is_ugly,
                    is_nice:   @color_vote.is_nice)
             .where("position > ?", deleted_pos)
             .update_all("position = position - 1")

    respond_to do |format|
      format.turbo_stream { render turbo_stream: turbo_stream.remove(dom_id(@color_vote)) }
      format.html         { redirect_back fallback_location: rank_colors_path, notice: "Vote deleted." }
    end
  end
end
