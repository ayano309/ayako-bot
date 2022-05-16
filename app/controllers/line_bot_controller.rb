class LineBotController < ApplicationController
  protect_from_forgery except: [:callback]
  skip_before_action :verify_authenticity_token


  def callback
    @post=Post.offset( rand(Post.count) ).first

    body = request.body.read
    signature = request.env['HTTP_X_LINE_SIGNATURE']
    unless client.validate_signature(body, signature)
      return head :bad_request
    end
    events = client.parse_events_from(body)
    events.each do |event|

      if event.message['text'].include?("元気")
        response = "今日も元気だよ"
      elsif event.message["text"].include?("ありがとう")
        response = "いつもありがとうね"
      elsif event.message['text'].include?("ご飯")
        response = "お腹すいたね"
      elsif event.message['text'].include?("明日")
        response = "また明日ね" 
      elsif event.message['text'].include?("おやすみ")
        response = "おやすみー" 
      else
        response = @post.name
      end

      case event
      when Line::Bot::Event::Message
        case event.type
        when Line::Bot::Event::MessageType::Text
          message = {
            type: 'text',
            text: response
          }
          client.reply_message(event['replyToken'], message)
        end
      end
    end
    head :ok
  end

  private

    def client
      @client ||= Line::Bot::Client.new { |config|
        config.channel_secret = ENV['LINE_CHANNEL_SECRET']
        config.channel_token = ENV['LINE_CHANNEL_TOKEN']
      }
    end
end