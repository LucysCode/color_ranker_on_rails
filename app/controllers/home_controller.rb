class HomeController < ApplicationController
  def index
    
# Singles
    if session[:current_color].present?
      @hex_color = session[:current_color]
    else
      begin
        new_color = RandomColor.random_color
      end while ColorVote.exists?(hex_color: new_color, session_id: session[:session_id])
  
      session[:current_color] = new_color
      @hex_color = new_color
    end

# Pairs
    if session[:current_color_pair].present?
      @color_pair = session[:current_color_pair]
    else
      begin
        new_pair = generate_unique_color_pair
      end while ColorPairVote.exists?(left_color: new_pair[0], right_color: new_pair[1], session_id: session[:session_id])
      session[:current_color_pair] = new_pair
      @color_pair = new_pair
    end

  end
  

  def generate_unique_color_pair
    # Generate two unique random colors that don't already exist in votes for this session
    left_color = generate_unique_color
    right_color = generate_unique_color(exclude: [left_color])

    [left_color, right_color]
  end

  def generate_unique_color(exclude: [])
    begin
      new_color = RandomColor.random_color
    end while (
      ColorPairVote.exists?(
        ["(left_color = :color OR right_color = :color) AND session_id = :session_id",
         { color: new_color, session_id: session[:session_id] }]
      ) || exclude.include?(new_color)
    )
  
    new_color
  end

end
