class ColorRankerController < ApplicationController
  protect_from_forgery with: :null_session, if: -> { request.format.json? }

  MAX_COLORS = 3
  MAX_UGLY_COLORS = MAX_COLORS
  MAX_NICE_COLORS = MAX_COLORS

  def rank_colors
    @ugly_colors = ColorVote.where(session_id: session[:session_id], is_ugly: true).order(:position)
    @nice_colors = ColorVote.where(session_id: session[:session_id], is_nice: true).order(:position)
    @max_colors = MAX_COLORS
  
    # current_color = session[:current_color] || []
    unless session[:current_color].is_a?(Array) && session[:current_color].size == 2
      # Only generate a new color if explicitly requested via `params[:new_color]`
      if params[:new_color] == "true"
        begin
          new_color = generate_unique_color
        end while ColorVote.exists?(hex_color: new_color, session_id: session[:session_id])
        session[:current_color] = new_color
      end
    end
    
    current_color = session[:current_color].is_a?(Array) ? session[:current_color] : [] 
    
    if params[:new_color] == "true"
      if ColorVote.where(session_id: session[:session_id]).count >= 16**12
        @message = "Woah you went through 16,777,216 colors? That's some serious dedication."
        @left_color = color_pair[0]
        @right_color - color_pair[1]
        @hex_color = ["#FFFFFF"]

        # return
      elsif ColorVote.where(session_id: session[:session_id], is_ugly: true).count >= MAX_UGLY_COLORS &&
            ColorVote.where(session_id: session[:session_id], is_nice: true).count >= MAX_NICE_COLORS
        @image_url = "https://i.kym-cdn.com/entries/icons/facebook/000/027/475/Screen_Shot_2018-10-25_at_11.02.15_AM.jpg"
        @show_pikachu = true
        @message = "You ranked all the colors! Wanna reset? :)"
        @hex_color = ["#FFFFFF"]

        # return

      else
        begin
          new_color = generate_unique_color
        end while ColorVote.exists?(hex_color: new_color, session_id: session[:session_id])
        
        session[:current_color] = new_color
        @hex_color = new_color

        if params[:last_vote] == "ugly" &&
          ColorVote.where(session_id: session[:session_id], is_ugly: true).count >= MAX_UGLY_COLORS
          @message = "You selected the maximum ugly colors! Want to select more great colors?"
       elsif params[:last_vote] == "nice" &&
          ColorVote.where(session_id: session[:session_id], is_nice: true).count >= MAX_NICE_COLORS
          @message = "You selected the maximum nice colors! Want to select more ugly colors?"
       end

      end
  # Edit
    elsif params[:new_color] == "true"
      if ColorVote.where(session_id: session[:session_id], is_ugly: true).count >= MAX_UGLY_COLORS &&
         ColorVote.where(session_id: session[:session_id], is_nice: true).count >= MAX_NICE_COLORS

        @hex_color = ["#FFFFFF"]
        @image_url = "https://i.kym-cdn.com/entries/icons/facebook/000/027/475/Screen_Shot_2018-10-25_at_11.02.15_AM.jpg"
        @show_pikachu = true
        @message = "You ranked all the colors! Wanna reset? :)"
      else
        hex_color = current_color || generate_unique_color
        begin
          new_color = generate_unique_color
        end while ColorVote.exists?(hex_color: hex_color, session_id: session[:session_id])
        session[:current_color] = new_color
        @hex_color = new_color
      end

    else
      if session[:current_color].present?
        @hex_color = session[:current_color]
      else
        begin
          new_color = generate_unique_color
        end while ColorVote.exists?(hex_color: new_color, session_id: session[:session_id])
        session[:current_color] = new_color
        @hex_color = new_color
      end

      if ColorVote.where(session_id: session[:session_id], is_ugly: true).count >= MAX_UGLY_COLORS &&
          ColorVote.where(session_id: session[:session_id], is_nice: true).count >= MAX_NICE_COLORS
        @image_url = "https://i.kym-cdn.com/entries/icons/facebook/000/027/475/Screen_Shot_2018-10-25_at_11.02.15_AM.jpg"
        @show_pikachu = true
        @message = "You ranked all the colors! Wanna reset? :)"
        @hex_color = ["#FFFFFF"]
      end

    end
  end


  def update_position
    ordered_ids = params[:ordered_ids]
    list_type = params[:list_type]

    # Ensure the request has the correct data
    return head :bad_request unless ordered_ids.present? && list_type.present?

    # Loop through each color and update its position
    ordered_ids.each_with_index do |id, index|
      hex_color_vote = ColorVote.find_by(id: id, session_id: session[:session_id])
      next unless hex_color_vote

      # Update position only if it's the correct list
      if list_type == "ugly_colors_list" && hex_color_vote.is_ugly
        hex_color_vote.update(position: index)
      elsif list_type == "nice_colors_list" && hex_color_vote.is_nice
        hex_color_vote.update(position: index)
      end
    end

    head :ok
  end
  

  def vote_color
    hex_color = session[:current_color]
    is_ugly = params[:vote_type] == "ugly"
    is_nice = params[:vote_type] == "nice"
  
    # Prevent going over the vote limit
    if is_ugly && ColorVote.where(session_id: session[:session_id], is_ugly: true).count >= MAX_UGLY_COLORS
      head :forbidden and return
    elsif is_nice && ColorVote.where(session_id: session[:session_id], is_nice: true).count >= MAX_NICE_COLORS
      head :forbidden and return
    end
  
    unless ColorVote.exists?(
      hex_color: hex_color,
      session_id: session[:session_id]
    )
      position_scope = ColorVote.where(
        session_id: session[:session_id],
        is_ugly: is_ugly,
        is_nice: is_nice
      )
      position = position_scope.count
  
      ColorVote.create(
        hex_color: hex_color,
        is_ugly: is_ugly,
        is_nice: is_nice,
        session_id: session[:session_id],
        position: position
      )
    end    
  
    Rails.logger.info "Created vote: #{ColorVote.last.inspect}" if ColorVote.last&.session_id == session[:session_id]
  
    head :ok
  end
    
  

  def reset_colors
    if ColorVote.exists?(session_id: session[:session_id])
      ColorVote.where(session_id: session[:session_id]).delete_all
      redirect_to rank_colors_path, notice: "All color colors reset. Start fresh!"
    else
      redirect_to rank_colors_path, notice: "Color colors already reset."
    end
  end

  def reset_ugly_colors
    if ColorVote.exists?(session_id: session[:session_id], is_ugly: true)
      ColorVote.where(session_id: session[:session_id], is_ugly: true).delete_all
      redirect_to rank_colors_path, notice: "All ugly colors reset!"
    else
      redirect_to rank_colors_path, notice: "Ugly colors already reset."
    end
  end

  def reset_nice_colors
    if ColorVote.exists?(session_id: session[:session_id], is_nice: true)
      ColorVote.where(session_id: session[:session_id], is_nice: true).delete_all
      redirect_to rank_colors_path, notice: "All nice colors reset!"
    else
      redirect_to rank_colors_path, notice: "Nice colors already reset."
    end
  end


  def generate_unique_color(exclude: [])
    begin
      new_color = RandomColor.random_color
    end while (
      ColorVote.exists?(
        ["(left_color = :color OR right_color = :color) AND session_id = :session_id",
         { color: new_color, session_id: session[:session_id] }]
      ) || exclude.include?(new_color)
    )
  
    new_color
  end
end

