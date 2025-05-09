# app logic, routes, and controllers

# Route to return new random color when button is clicked

# class HomeController < ApplicationController
#     def index
#       @hex_color = RandomColor.random_color
#       #   @random_color = "#" + "%06x" % (rand * 0xffffff)
#     end
# end


class HomeController < ApplicationController
  def index
    if params[:new_color] == "true"
      @hex_color = RandomColor.random_color
      session[:current_color] = @hex_color
    else
      @hex_color = session[:current_color] || RandomColor.random_color
      session[:current_color] ||= @hex_color
    end
  end

  def vote
    color = session[:current_color]
    vote_type = params[:vote]

    # You can implement storing this vote in a database or log later
    # For now, just log it
    Rails.logger.info "Color #{color} voted as #{vote_type}"

    head :ok # Respond with no content
  end
end
