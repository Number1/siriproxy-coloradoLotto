require 'nokogiri'
require 'open-uri'
require 'cora'
require 'siri_objects'
require 'pp'

class SiriProxy::Plugin::Coloradolotto < SiriProxy::Plugin
    
    def initialize(config = {})
        
        #if you have custom configuration options, process them here!
    end
    
    
    doc = Nokogiri::HTML(open('http://www.coloradolottery.com/games/lotto/'))

    past = doc.css('div[id="powerBallHeaderBox"]')
    
    future = doc.css('div[class="jackpotBox"]')
    
    def winning_num(past)
        
        winner = past.css('div[class="number"]').map do |win|
            win.text.strip
        end

        return winner
        
    end

    def draw_date(past)

        draw_date = past.css('a[1]').map do |win|
            win.text.strip
        end
        
        draw_date = draw_date[0].delete(' ')

        return draw_date
    end

    def future_draw(future)

        future_date = future.css('div[id="nextDrawingTextColor"]').map do |win|
            win.text.strip
        end
        
        future_date = future_date[0].sub!('Next Drawing', '')
        
        return future_date
    end

    def next_jackpot(future)
        
        jackpot = future.css('span[class="jackpotAmount"]').map do |win|
            win.text.strip
        end
        
        return jackpot
    end
    
    listen_for /lotto/i do
    
    say "Checking on that for you"
    
    num = winning_num(past)
    
    draw = draw_date(past)
    
    next_draw = future_draw(future)
    
    jackpot = next_jackpot(future)
    
    add_views = SiriAddViews.new
    
    add_views.make_root(last_ref_id)
    
    answer = SiriAnswer.new(SiriAnswerLine.new('Last Drawing: ', draw, num),    SiriAnswerLine.new('NextDrawing: ', next_draw, ' for ', jackpot) )
    
    utterance = SiriAssistantUtteranceView.new("Here you go")
    
    add_views.views << SiriAnswerSnippet.new(answer)
    add_views.views << utterance
    send_object add_views
    
    request_complete
    
    end

end


    