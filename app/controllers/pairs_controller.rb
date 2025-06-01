class PairsController < ApplicationController
  protect_from_forgery with: :null_session, if: -> { request.format.json? }

  MAX_PAIRS = 3
  MAX_UGLY_PAIRS = MAX_PAIRS
  MAX_NICE_PAIRS = MAX_PAIRS

  def rank_color_pairs
    @ugly_pairs = ColorPairVote.where(session_id: session[:session_id], is_ugly: true).order(:position)
    @nice_pairs = ColorPairVote.where(session_id: session[:session_id], is_nice: true).order(:position)
    @max_pairs = MAX_PAIRS
  
    # current_pair = session[:current_color_pair] || []
    unless session[:current_color_pair].is_a?(Array) && session[:current_color_pair].size == 2
      session[:current_color_pair] = generate_unique_color_pair
    end
    current_pair = session[:current_color_pair].is_a?(Array) ? session[:current_color_pair] : [] 

    
    if params[:new_pair] == "true"
      if ColorPairVote.where(session_id: session[:session_id]).count >= 16**12
        @message = "Woah you went through 281,474,976,710,656 colors pairs? That's some serious dedication."
        @left_color = color_pair[0]
        @right_color - color_pair[1]
        @color_pair = ["#FFFFFF", "#FFFFFF"]
        # return
      elsif ColorPairVote.where(session_id: session[:session_id], is_ugly: true).count >= MAX_UGLY_PAIRS &&
            ColorPairVote.where(session_id: session[:session_id], is_nice: true).count >= MAX_NICE_PAIRS
        @image_url = "https://i.kym-cdn.com/entries/icons/facebook/000/027/475/Screen_Shot_2018-10-25_at_11.02.15_AM.jpg"
        @show_pikachu = true
        @message = "You ranked all the pairs! Wanna reset? :)"
        @color_pair = ["#FFFFFF", "#FFFFFF"]
        # return

      else
        begin
          new_pair = generate_unique_color_pair
        end while ColorPairVote.exists?(left_color: new_pair[0], right_color: new_pair[1], session_id: session[:session_id])
        
        session[:current_color_pair] = new_pair
        @color_pair = new_pair

        if params[:last_vote] == "ugly" &&
          ColorPairVote.where(session_id: session[:session_id], is_ugly: true).count >= MAX_UGLY_PAIRS
          @message = "You selected the maximum ugly pairs! Want to select more great pairs?"

       elsif params[:last_vote] == "nice" &&
          ColorPairVote.where(session_id: session[:session_id], is_nice: true).count >= MAX_NICE_PAIRS
          @message = "You selected the maximum nice pairs! Want to select more ugly pairs?"

       end

      end
  
    elsif params[:new_left_color] == "true"
      if ColorPairVote.where(session_id: session[:session_id], is_ugly: true).count >= MAX_UGLY_PAIRS &&
         ColorPairVote.where(session_id: session[:session_id], is_nice: true).count >= MAX_NICE_PAIRS

        @color_pair = ["#FFFFFF", "#FFFFFF"]
        @image_url = "https://i.kym-cdn.com/entries/icons/facebook/000/027/475/Screen_Shot_2018-10-25_at_11.02.15_AM.jpg"
        @show_pikachu = true
        @message = "You ranked all the pairs! Wanna reset? :)"
      else
        right_color = current_pair[1] || generate_unique_color
        begin
          new_left = generate_unique_color(exclude: [right_color])
        end while ColorPairVote.exists?(left_color: new_left, right_color: right_color, session_id: session[:session_id])
        new_pair = [new_left, right_color]
        session[:current_color_pair] = new_pair
        @color_pair = new_pair
      end

  elsif params[:new_right_color] == "true"
    if ColorPairVote.where(session_id: session[:session_id], is_ugly: true).count >= MAX_UGLY_PAIRS &&
        ColorPairVote.where(session_id: session[:session_id], is_nice: true).count >= MAX_NICE_PAIRS

      @color_pair = ["#FFFFFF", "#FFFFFF"]
      @image_url = "https://i.kym-cdn.com/entries/icons/facebook/000/027/475/Screen_Shot_2018-10-25_at_11.02.15_AM.jpg"
      @show_pikachu = true
      @message = "You ranked all the pairs! Wanna reset? :)"
    else
      left_color = current_pair[0] || generate_unique_color
      begin
        new_right = generate_unique_color(exclude: [left_color])
      end while ColorPairVote.exists?(left_color: left_color, right_color: new_right, session_id: session[:session_id])
      new_pair = [left_color, new_right]
      session[:current_color_pair] = new_pair
      @color_pair = new_pair
    end


    else
      if session[:current_color_pair].present?
        @color_pair = session[:current_color_pair]
      else
        begin
          new_pair = generate_unique_color_pair
        end while ColorPairVote.exists?(left_color: new_pair[0], right_color: new_pair[1], session_id: session[:session_id])
        session[:current_color_pair] = new_pair
        @color_pair = new_pair
      end

      if ColorPairVote.where(session_id: session[:session_id], is_ugly: true).count >= MAX_UGLY_PAIRS &&
          ColorPairVote.where(session_id: session[:session_id], is_nice: true).count >= MAX_NICE_PAIRS
        @image_url = "https://i.kym-cdn.com/entries/icons/facebook/000/027/475/Screen_Shot_2018-10-25_at_11.02.15_AM.jpg"
        @show_pikachu = true
        @message = "You ranked all the pairs! Wanna reset? :)"
        @color_pair = ["#FFFFFF", "#FFFFFF"]
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
      color_pair_vote = ColorPairVote.find_by(id: id, session_id: session[:session_id])
      next unless color_pair_vote

      # Update position only if it's the correct list
      if list_type == "ugly_pairs_list" && color_pair_vote.is_ugly
        color_pair_vote.update(position: index)
      elsif list_type == "nice_pairs_list" && color_pair_vote.is_nice
        color_pair_vote.update(position: index)
      end
    end

    head :ok
  end
  

  def vote_pair
    color_pair = session[:current_color_pair]
    left_color, right_color = color_pair
    is_ugly = params[:vote_type] == "ugly"
    is_nice = params[:vote_type] == "nice"
  
    # Prevent going over the vote limit
    if is_ugly && ColorPairVote.where(session_id: session[:session_id], is_ugly: true).count >= MAX_UGLY_PAIRS
      head :forbidden and return
    elsif is_nice && ColorPairVote.where(session_id: session[:session_id], is_nice: true).count >= MAX_NICE_PAIRS
      head :forbidden and return
    end
  
    unless ColorPairVote.exists?(
      left_color: left_color,
      right_color: right_color,
      session_id: session[:session_id]
    )
      position_scope = ColorPairVote.where(
        session_id: session[:session_id],
        is_ugly: is_ugly,
        is_nice: is_nice
      )
      position = position_scope.count
  
      ColorPairVote.create(
        left_color: left_color,
        right_color: right_color,
        is_ugly: is_ugly,
        is_nice: is_nice,
        session_id: session[:session_id],
        position: position
      )
    end    
  
    Rails.logger.info "Created vote: #{ColorPairVote.last.inspect}" if ColorPairVote.last&.session_id == session[:session_id]
  
    head :ok
  end
    
  

  def reset_pairs
    if ColorPairVote.exists?(session_id: session[:session_id])
      ColorPairVote.where(session_id: session[:session_id]).delete_all
      redirect_to rank_color_pairs_path, notice: "All color pairs reset. Start fresh!"
    else
      redirect_to rank_color_pairs_path, notice: "Color pairs already reset."
    end
  end

  def reset_ugly_pairs
    if ColorPairVote.exists?(session_id: session[:session_id], is_ugly: true)
      ColorPairVote.where(session_id: session[:session_id], is_ugly: true).delete_all
      redirect_to rank_color_pairs_path, notice: "All ugly pairs reset!"
    else
      redirect_to rank_color_pairs_path, notice: "Ugly pairs already reset."
    end
  end

  def reset_nice_pairs
    if ColorPairVote.exists?(session_id: session[:session_id], is_nice: true)
      ColorPairVote.where(session_id: session[:session_id], is_nice: true).delete_all
      redirect_to rank_color_pairs_path, notice: "All nice pairs reset!"
    else
      redirect_to rank_color_pairs_path, notice: "Nice pairs already reset."
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

