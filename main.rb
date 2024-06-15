require 'faraday'
require 'nokogiri'
require 'ferrum'


class Agent
  class << self
    def check_square
      make_request
        .yield_self { parse_response _1 }
        .yield_self { check_availability _1 }
        .yield_self { notify_or_exit _1 }
    end

    private

    def make_request
      browser = Ferrum::Browser.new(headless: true, timeout: 30, window_size: [1440, 900], browser_options: { 'no-sandbox': nil, 'disable-dev-shm-usage': nil })
      browser.go_to $url
      sleep 10
      page_source = browser.body
      browser.quit
      page_source
    end

    def parse_response(response)
      Nokogiri::HTML(response)
    end

    def check_availability(page_source)
      # btw doing this the convoluted way so I can add more info to the message at a later time
      page_source.xpath('//div[contains(text(), "No availability within the next 30 days")]')
    end

    def notify_or_exit(new_content)
      if new_content.empty?
        Faraday.post("https://ntfy.sh/paragon", "Paragon Fit Studio has new Availability!! or something went wrong lmao.", content_type: 'application/json', title: 'Paragon Fit Studio Availability', tags: 'partying_face')
      end

      exit
    end
  end
end

if __FILE__ == $0
  $global_fails = 0
  $url = 'https://book.squareup.com/appointments/g25dw5kf6jsny0/location/7ZQQFNETS189K/availability'
  Agent.check_square
end
