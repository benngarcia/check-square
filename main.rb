require 'faraday'
require 'json'
require 'nokogiri'


class Agent
  class << self
    # ftr this would be a browserless obj w/e lmao
    def setup
      Faraday.get('http://browserless:3000/metrics')
    rescue Faraday::ConnectionFailed
      $global_fails += 1 && sleep 2
      $global_fails > 10 ? exit : retry
    end

    def check_square
      make_request
        .yield_self { parse_response _1 }
        .yield_self { check_availability _1 }
        .yield_self { notify_or_exit _1 }
    end

    private

    def make_request
      Faraday.post "http://browserless:3000/content", { url: $url, waitUntil: 'networkidle2' }.to_json, 'Content-Type' => 'application/json'
    end

    def parse_response(response)
      JSON.parse(response.body)['data']
    end

    def check_availability(page_source)
      html_doc = Nokogiri::HTML(page_source)
      # btw doing this the convoluted way so I can add more info to the message at a later time
      html_doc.xpath('//div[contains(text(), "No availability within the next 30 days")]')
    end

    def notify_or_exit(new_content)
      if new_content.empty?
        Faraday.post(ntfy_url, message: "Paragon Fit Studio has new Availability!!", { 'Content-Type' => 'application/json', 'Title': 'Paragon Fit Studio Availability', 'Tags': 'partying_face'})
      end

      exit
    end
  end
end

if __FILE__ == $0
  $global_fails = 0
  $url = 'https://book.squareup.com/appointments/g25dw5kf6jsny0/location/7ZQQFNETS189K/availability'
  $ntfy_url = 'https://ntfy.sh/paragon' # u can spam my phone for the funnies if u wanted to be mean.
  Agent.setup.check_square(url)
end
