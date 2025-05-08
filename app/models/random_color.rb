# def generate_random_hex_color
#     "#" + "%06x" % (rand * 0xffffff)
# end

class RandomColor
    def self.random_color
      '#' + 6.times.map { rand(16).to_s(16) }.join.upcase
    end
  end

# utility file to keep this method modular and reusable