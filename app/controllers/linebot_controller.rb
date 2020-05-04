class LinebotController < ApplicationController
  require 'line/bot'  
  # callbackアクションのCSRFトークン認証を無効
  protect_from_forgery :except => [:callback]
  def callback
    API_KEY= Rails.application.credentials[:API_KEY]
    url='https://api.gnavi.co.jp/RestSearchAPI/v3/?keyid='
    url << API_KEY

    body = request.body.read
    signature = request.env['HTTP_X_LINE_SIGNATURE']
    unless client.validate_signature(body, signature)
      error 400 do 'Bad Request' end
    end
    events = client.parse_events_from(body)
    events.each { |event|
      case event
      when Line::Bot::Event::Message
        case event.type
        when Line::Bot::Event::MessageType::Text
          if event
            word = event
            url << "&name=" << word #名前で検索
          end
          url=URI.encode(url) 
          uri = URI.parse(url)
          json = Net::HTTP.get(uri)
          result = JSON.parse(json)
          rests=result["rest"]

        rests.each do |rest|
          message = [{
            "type": "template",
            "altText": "#{rest[:name]}",
            "template": {
                "type": "carousel",
                "columns": [
                    {
                      "thumbnailImageUrl": "#{rest[:image_url]}",
                      "imageBackgroundColor": "#FFFFFF",
                      "title": "#{rest[:name]}",
                      "text": "#{rest[:adress]}",
                      "defaultAction": {
                          "type": "uri",
                          "label": "View detail",
                          "uri": "#{rest[:url]}"
                      },
                      "actions": [
                          {
                              "type": "uri",
                              "label": "地図を見る",
                              "uri": "#{rest[:adress]}"
                          },
                          {
                              "type": "uri",
                              "label": "電話する",
                              "uri": "https://line.me/R/call/81/#{rest[:tel]}"
                          },
                          {
                              "type": "uri",
                              "label": "詳しく見る",
                              "uri": "#{rest[:url]}"
                          }
                      ]
                    },
                    {
                      "thumbnailImageUrl": "https://example.com/bot/images/item2.jpg",
                      "imageBackgroundColor": "#000000",
                      "title": "this is menu",
                      "text": "description",
                      "defaultAction": {
                          "type": "uri",
                          "label": "View detail",
                          "uri": "http://example.com/page/222"
                      },
                      "actions": [
                          {
                              "type": "postback",
                              "label": "Buy",
                              "data": "action=buy&itemid=222"
                          },
                          {
                              "type": "postback",
                              "label": "Add to cart",
                              "data": "action=add&itemid=222"
                          },
                          {
                              "type": "uri",
                              "label": "View detail",
                              "uri": "http://example.com/page/222"
                          }
                      ]
                    }
                ],
                "imageAspectRatio": "rectangle",
                "imageSize": "cover"
            }
          client.reply_message(event['replyToken'], message)
        end
        end
      end
    }
    head :ok
  end

  private
  def client
    @client ||= Line::Bot::Client.new { |config|
      config.channel_secret = ENV["LINE_CHANNEL_SECRET"]
      config.channel_token = ENV["LINE_CHANNEL_TOKEN"]
    }
  end
end