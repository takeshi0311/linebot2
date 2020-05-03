class LinebotController < ApplicationController
  require 'line/bot'
  # callbackアクションのCSRFトークン認証を無効
  protect_from_forgery :except => [:callback]
  def callback
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
          seed1 = select_word
          seed2 = select_word
          while seed1 == seed2
            seed2 = select_word
          end
          message = [{
            "type": "template",
            "altText": "this is a carousel template",
            "template": {
                "type": "carousel",
                "columns": [
                    {
                      "thumbnailImageUrl": "https://rimage.gnst.jp/rest/img/p70mjp8z0000/t_0op3.jpg?t=1588445234&rw=212&rh=212&q=80",
                      "imageBackgroundColor": "#FFFFFF",
                      "title": "大人の隠れ家個室 土間土間 池袋西口駅前店",
                      "text": "ＪＲ池袋駅西口 徒歩1分",
                      "defaultAction": {
                          "type": "uri",
                          "label": "View detail",
                          "uri": "https://r.gnavi.co.jp/a188901/"
                      },
                      "actions": [
                          {
                              "type": "uri",
                              "label": "地図を見る",
                              "data": "https://r.gnavi.co.jp/a188901/map/"
                          },
                          {
                              "type": "postback",
                              "label": "電話する",
                              "data": "050-3469-9958"
                          },
                          {
                              "type": "uri",
                              "label": "詳しく見る",
                              "uri": "https://r.gnavi.co.jp/a188901/"
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
          },{
            type: 'text',
            text: "#{seed1} × #{seed2} !!"
          }]
          client.reply_message(event['replyToken'], message)
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
  def select_word
    # この中を変えると返ってくるキーワードが変わる
    seeds = ["コロナ", "タケシ", "ネックレス", "結婚"]
    seeds.sample
  end
end