class HomeController < ApplicationController
  MAX_COLORS = 3
  MAX_UGLY_COLORS = MAX_COLORS
  MAX_NICE_COLORS = MAX_COLORS

  def index

    @ugly_colors = ColorVote.where(session_id: session[:session_id], is_ugly: true)
                         .order(:position)

    @nice_colors = ColorVote.where(session_id: session[:session_id], is_nice: true)
                         .order(:position)
    @max_colors = MAX_COLORS

    if params[:new_color] == "true"

      # Limit for all hex. Stop color generation
      if ColorVote.where(session_id: session[:session_id]).count >= 16**6
        @hex_color = "#FFFFFF"
        @message = "Woah you went through 16,777,216 colors? That's some serious dedication."

      # Limit for maxed votes. Stop color generation
      elsif ColorVote.where(session_id: session[:session_id], is_ugly: true).count >= MAX_UGLY_COLORS &&
        ColorVote.where(session_id: session[:session_id], is_nice: true).count >= MAX_NICE_COLORS
        @image_url = "https://i.kym-cdn.com/entries/icons/facebook/000/027/475/Screen_Shot_2018-10-25_at_11.02.15_AM.jpg"
        @show_pikachu = true
        @message = "You ranked all the colors! Wanna reset? :)"
        @hex_color = ["#FFFFFF"]

      # Limit for one category maxed votes. Continue color generation.
      else
        begin
          new_color = RandomColor.random_color
        end while ColorVote.exists?(hex_color: new_color, session_id: session[:session_id])

        session[:current_color] = new_color
        @hex_color = new_color
        
        if params[:last_vote] == "ugly" && 
          ColorVote.where(session_id: session[:session_id], is_ugly: true).count >= MAX_UGLY_COLORS
          @message = "You selected the maximum ugly colors! Want to select more great colors?"
          # begin
          #   new_color = RandomColor.random_color
          # end while ColorVote.exists?(hex_color: new_color, session_id: session[:session_id])
  
          # session[:current_color] = new_color
          # @hex_color = new_color
        elsif params[:last_vote] == "nice" && 
          ColorVote.where(session_id: session[:session_id], is_nice: true).count >= MAX_NICE_COLORS
          @message = "You selected the maximum great colors! Want to select more ugly colors?"
          # begin
          #   new_color = RandomColor.random_color
          # end while ColorVote.exists?(hex_color: new_color, session_id: session[:session_id])
  
          # session[:current_color] = new_color
          # @hex_color = new_color
        end
      end

    # If a color is present, keep. If not, generate a new color.
    else
      if session[:current_color].present?
        @hex_color = session[:current_color]
      else
        begin
          new_color = RandomColor.random_color
        end while ColorVote.exists?(hex_color: new_color, session_id: session[:session_id])
    
        session[:current_color] = new_color
        @hex_color = new_color
      end

      if ColorVote.where(session_id: session[:session_id], is_ugly: true).count >= MAX_UGLY_COLORS &&
        ColorVote.where(session_id: session[:session_id], is_nice: true).count >= MAX_NICE_COLORS
        @image_url = "https://i.kym-cdn.com/entries/icons/facebook/000/027/475/Screen_Shot_2018-10-25_at_11.02.15_AM.jpg"
        @show_pikachu = true
        @message = "You ranked all the colors! Wanna reset? :)"
        @hex_color = ["FFFFFF"]
      end
    end    

  end

  # Backend logic for when the list order is changed
  def update_position
    ordered_ids = params[:ordered_ids]
    list_type = params[:list_type]

    # Ensure the request has the correct data
    return head :bad_request unless ordered_ids.present? && list_type.present?

    # Loop through each color and update its position
    ordered_ids.each_with_index do |id, index|
      color_vote = ColorVote.find_by(id: id, session_id: session[:session_id])
      next unless color_vote

      # Update position only if it's the correct list
      if list_type == "ugly_colors_list" && color_vote.is_ugly
        color_vote.update(position: index)
      elsif list_type == "nice_colors_list" && color_vote.is_nice
        color_vote.update(position: index)
      end
    end

    head :ok
  end

  def vote
    Rails.logger.info "Received vote: #{params[:vote]}"
    hex_color = session[:current_color]
    is_ugly = params[:vote] == "ugly"
    is_nice = params[:vote] == "nice"

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

    head :ok
  end

  def reset
    if ColorVote.exists?(session_id: session[:session_id])
      ColorVote.where(session_id: session[:session_id]).delete_all
      redirect_to root_path, notice: "All colors reset. Start fresh!"
    else
      redirect_to root_path, notice: "Colors already reset."
    end
  end

  def reset_ugly
    if ColorVote.exists?(session_id: session[:session_id], is_ugly: true)
      ColorVote.where(session_id: session[:session_id], is_ugly: true).delete_all
      redirect_to root_path, notice: "All ugly colors reset!"
    else
      redirect_to root_path, notice: "Ugly colors already reset."
    end
  end

  def reset_nice
    if ColorVote.exists?(session_id: session[:session_id], is_nice: true)
      ColorVote.where(session_id: session[:session_id], is_nice: true).delete_all
      redirect_to root_path, notice: "All nice colors reset!"
    else
      redirect_to root_path, notice: "Nice colors already reset."
    end
  end

end
