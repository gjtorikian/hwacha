require "hwacha/version"
require "typhoeus"

class Hwacha
  def initialize(opts)
    @options = {:max_concurrency => 20, :followlocation => true}.merge(opts)
  end

  def check(urls)
    hydra = Typhoeus::Hydra.new(@options)

    Array(urls).each do |url|
      request = Typhoeus::Request.new(url)
      request.on_complete do |response|
        yield response.effective_url, response
      end
      hydra.queue request
    end

    hydra.run
  end

  def find_existing(urls)
    check(urls) do |url, response|
      yield url if response.success?
    end
  end

  # Hwacha!!!
  alias :fire :check
  alias :strike_true :find_existing
end
