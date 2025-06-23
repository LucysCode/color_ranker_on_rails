class ColorPairVotesController < ApplicationController
  def destroy
    @pair_vote   = ColorPairVote.find(params[:id])
    deleted_pos  = @pair_vote.position          # remember the old rank

    @pair_vote.destroy                          # 1. remove the row

    # 2. shift every later vote in *the same list* up by one rank
    ColorPairVote.where(session_id: session[:session_id],
                        is_ugly:    @pair_vote.is_ugly,
                        is_nice:    @pair_vote.is_nice)
                 .where("position > ?", deleted_pos)
                 .update_all("position = position - 1")

    # 3. respond (Turbo-Stream for instant DOM update, HTML fallback for full reload)
    respond_to do |format|
      format.turbo_stream do
        render turbo_stream: turbo_stream.remove(dom_id(@pair_vote))
      end
      format.html do
        redirect_to rank_color_pairs_path,
                    notice: "Pair vote deleted."
      end
    end
  rescue ActiveRecord::RecordNotFound
    head :no_content
  end
end

