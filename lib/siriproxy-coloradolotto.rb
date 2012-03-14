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
        winner = winner.to_s
        winner = winner.delete('"')
        winner = winner.sub!('[', '')
        winner = winner.sub!(']', '')
        return winner
        
    end

    def draw_date(past)

        draw_date = past.css('a[1]').map do |win|
            win.text.strip
        end
        
        draw_date = draw_date[0].delete('') + ':'

        return draw_date
    end

    def future_draw(future)

        future_date = future.css('div[id="nextDrawingTextColor"]').map do |win|
            win.text.strip
        end
        
        future_date = future_date[0].sub!('Next Drawing', '')
        future_date = future_date.to_s
        future_date = future_date.delete(' ')
        future_date = future_date.delete('\n')
        return future_date
    end

    def next_jackpot(future)
        
        jackpot = future.css('span[class="jackpotAmount"]').map do |win|
            win.text.strip
        end
        jackpot = jackpot.to_s
        jackpot = jackpot.delete('"')
        jackpot = jackpot.delete('[')
        jackpot = jackpot.delete(']')
        
        return jackpot
    end
    
    listen_for /lotto/i do
    
    say "Checking on that for you"
    
    num = winning_num(past)
    
    draw = draw_date(past)
    
    next_draw = future_draw(future)
    
    jackpot = next_jackpot(future)
    
    object = SiriAddViews.new
    
    object.make_root(last_ref_id)
    
    answer = SiriAnswer.new("Last Winning Lotto Numbers from #{draw}", [
        SiriAnswerLine.new(num),
        SiriAnswerLine.new("Next drawing on:#{next_draw} with a jackpot of #{jackpot}")
        ])
    
    utterance = SiriAssistantUtteranceView.new("Here you go. Good luck!")
    

    object.views << SiriAnswerSnippet.new([answer])
    object.views << utterance    
    send_object object
    
    request_completed
    
    end

end


    