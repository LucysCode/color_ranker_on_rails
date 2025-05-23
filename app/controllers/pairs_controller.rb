class PairsController < ApplicationController
  MAX_PAIRS = 6

  def rank_color_pairs
    @max_pairs = MAX_PAIRS

    if params[:new_pair] == "true" || session[:current_color_pair].blank?
      @color_pair = generate_unique_color_pair
      session[:current_color_pair] = @color_pair
    else
      @color_pair = session[:current_color_pair]
    end
  end

  def reset_pairs
    ColorVote.where(session_id: session[:session_id]).delete_all
    session[:current_color_pair] = nil
    redirect_to rank_color_pairs_path(new_pair: true), notice: "All colors reset. Start fresh!"
  end

  private

  def generate_unique_color_pair
    # Generate two unique random colors that don't already exist in votes for this session
    first_color = generate_unique_color
    second_color = generate_unique_color(exclude: [first_color])

    [first_color, second_color]
  end

  def generate_unique_color(exclude: [])
    begin
      new_color = RandomColor.random_color
    end while ColorVote.exists?(hex_color: new_color, session_id: session[:session_id]) || exclude.include?(new_color)
    
    new_color
  end

end
