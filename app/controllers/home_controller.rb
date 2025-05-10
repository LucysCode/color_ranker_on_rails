# app logic, routes, and controllers

# Route to return new random color when button is clicked

class HomeController < ApplicationController
  MAX_UGLY_COLORS = 5
  MAX_NICE_COLORS = 5

  def index
    @ugly_colors = ColorVote.where(is_ugly: true).order(created_at: :desc).limit(MAX_UGLY_COLORS).pluck(:hex_color)

    @nice_colors = ColorVote.where(is_nice: true).order(created_at: :desc).limit(MAX_NICE_COLORS).pluck(:hex_color)

    if params[:new_color] == "true"
      if ColorVote.where(is_ugly: true).count >= MAX_UGLY_COLORS
        @hex_color = nil
        flash.now[:notice] = "You've already selected 5 ugly colors!"
      elsif ColorVote.where(is_nice: true).count >= MAX_NICE_COLORS
        @hex_color = nil
        flash.now[:notice] = "You've already liked 5 colors!"
      elsif ColorVote.count >= 16**6
        @hex_color = nil
        flash.now[:notice] = "All hex colors have been rated!"
      else
        begin
          new_color = RandomColor.random_color
        end while ColorVote.exists?(hex_color: new_color)
        session[:current_color] = new_color
        @hex_color = new_color
      end
    else
      @hex_color = session[:current_color]
    end
  end

  def vote
    Rails.logger.info "Received vote: #{params[:vote]}"
    hex_color = session[:current_color]
    is_ugly = params[:vote] == "ugly"
    is_nice = params[:vote] == "nice"

    unless ColorVote.exists?(hex_color: hex_color)
      ColorVote.create(hex_color: hex_color, is_ugly: is_ugly, is_nice: is_nice)
    end

    head :ok
  end

  def reset
    ColorVote.delete_all
    session[:current_color] = nil
    redirect_to root_path(new_color: true), notice: "All votes reset. Start fresh!"
  end
end


# class HomeController < ApplicationController
#     def index
#       @hex_color = RandomColor.random_color
#       #   @random_color = "#" + "%06x" % (rand * 0xffffff)
#     end
# end


# class HomeController < ApplicationController
#   def index
#     if params[:new_color] == "true"
#       @hex_color = RandomColor.random_color
#       session[:current_color] = @hex_color
#     else
#       @hex_color = session[:current_color] || RandomColor.random_color
#       session[:current_color] ||= @hex_color
#     end
#   end

#   def vote
#     color = session[:current_color]
#     vote_type = params[:vote]

#     # You can implement storing this vote in a database or log later
#     # For now, just log it
#     Rails.logger.info "Color #{color} voted as #{vote_type}"

#     head :ok # Respond with no content
#   end
# end
