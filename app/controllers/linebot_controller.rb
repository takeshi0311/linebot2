class LinebotController < ApplicationController
  # require 'line/bot'
  # # callbackアクションのCSRFトークン認証を無効
  # protect_from_forgery :except => [:callback]
  # def callback
  #   body = request.body.read
  #   signature = request.env['HTTP_X_LINE_SIGNATURE']
  #   unless client.validate_signature(body, signature)
  #     error 400 do 'Bad Request' end
  #   end
  #   events = client.parse_events_from(body)
  #   events.each { |event|
  #     case event
  #     when Line::Bot::Event::Message
  #       case event.type
  #       when Line::Bot::Event::MessageType::Text
  #         seed1 = select_word
  #         seed2 = select_word
  #         while seed1 == seed2
  #           seed2 = select_word
  #         end
  #         message = [{
  #           "type": "template",
  #           "altText": "this is a carousel template",
  #           "template": {
  #               "type": "carousel",
  #               "columns": [
  #                   {
  #                     "thumbnailImageUrl": "https://rimage.gnst.jp/rest/img/p70mjp8z0000/t_0op3.jpg?t=1588445234&rw=212&rh=212&q=80",
  #                     "imageBackgroundColor": "#FFFFFF",
  #                     "title": "大人の隠れ家個室 土間土間 池袋西口駅前店",
  #                     "text": "ＪＲ池袋駅西口 徒歩1分",
  #                     "defaultAction": {
  #                         "type": "uri",
  #                         "label": "View detail",
  #                         "uri": "https://r.gnavi.co.jp/a188901/"
  #                     },
  #                     "actions": [
  #                         {
  #                             "type": "uri",
  #                             "label": "地図を見る",
  #                             "uri": "https://r.gnavi.co.jp/a188901/map/"
  #                         },
  #                         {
  #                             "type": "uri",
  #                             "label": "電話する",
  #                             "uri": "https://line.me/R/call/81/05034699958"
  #                         },
  #                         {
  #                             "type": "uri",
  #                             "label": "詳しく見る",
  #                             "uri": "https://r.gnavi.co.jp/a188901/"
  #                         }
  #                     ]
  #                   },
  #                   {
  #                     "thumbnailImageUrl": "https://example.com/bot/images/item2.jpg",
  #                     "imageBackgroundColor": "#000000",
  #                     "title": "this is menu",
  #                     "text": "description",
  #                     "defaultAction": {
  #                         "type": "uri",
  #                         "label": "View detail",
  #                         "uri": "http://example.com/page/222"
  #                     },
  #                     "actions": [
  #                         {
  #                             "type": "postback",
  #                             "label": "Buy",
  #                             "data": "action=buy&itemid=222"
  #                         },
  #                         {
  #                             "type": "postback",
  #                             "label": "Add to cart",
  #                             "data": "action=add&itemid=222"
  #                         },
  #                         {
  #                             "type": "uri",
  #                             "label": "View detail",
  #                             "uri": "http://example.com/page/222"
  #                         }
  #                     ]
  #                   }
  #               ],
  #               "imageAspectRatio": "rectangle",
  #               "imageSize": "cover"
  #           }
  #         },{
  #           type: 'text',
  #           text: "#{seed1} × #{seed2} !!"
  #         }]
  #         client.reply_message(event['replyToken'], message)
  #       end
  #     end
  #   }
  #   head :ok
  # end
  # private
  # def client
  #   @client ||= Line::Bot::Client.new { |config|
  #     config.channel_secret = ENV["LINE_CHANNEL_SECRET"]
  #     config.channel_token = ENV["LINE_CHANNEL_TOKEN"]
  #   }
  # end
  # def select_word
  #   # この中を変えると返ってくるキーワードが変わる
  #   seeds = ["コロナ", "タケシ", "ネックレス", "結婚"]
  #   seeds.sample
  # end

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
          # ユーザーが打ったメッセージの取得
          messages = event["message"]["text"]
          #api_keyの取得
          api_key= Rails.application.credentials[:API_KEY]
          #レストラン検索のURL
          url ='https://api.gnavi.co.jp/RestSearchAPI/v3/?keyid='
          #テイクアウト可
          takeout = "&takeout=1"
          #名前検索
          name = "&freeword=#{messages}"

          #検索するURL
          search_url = url<<api_key<<takeout<<name

          search_url = URI.encode(search_url) #エスケープ
          search_uri = URI.parse(search_url)
          json = Net::HTTP.get(search_uri)
          result = JSON.parse(json)
          #配列の形で検索結果が@restsに格納される
          @rests=result["rest"]
          # @restaurant = @rests[0]
          # @restaurant = @rests.sample
          @restaurant = @rests.take(3) 

          # colums = []

          # while colums.size <= 10
          #配列を一つ一つ展開していく
        # @restaurant.each do |rest|
          # if colums.size <= 2
            # #お店の画像のURLの取得
            # imageurl = "#{rest["image_url"]["shop_image1"]}"
            # #お店のタイトルの取得
            # title    = "#{rest["name"]}"
            # #お店のPR文の取得
            # pr     = "#{rest["pr"]["pr_short"]}"
            # #お店の検索URLの取得
            # uri      = "#{rest["url_mobile"]}"
            # #お店の地図を取得
            # shopmap      = "#{rest["address"]}"
            # #電話番号の取得
            # tel      = "https://line.me/R/call/81/#{rest["tel"]}"
            
            # rest_detail = {
            #   "thumbnailImageUrl": imageurl,
            #   "imageBackgroundColor": "#FFFFFF",
            #   "title": title,
            #   "text": pr,
            #   "defaultAction": {
            #       "type": "uri",
            #       "label": "View detail",
            #       "uri": uri
            #   },
            #   "actions": [
            #       {
            #           "type": "uri",
            #           "label": "地図を見る",
            #           "uri": shopmap
            #       },
            #       {
            #           "type": "uri",
            #           "label": "電話する",
            #           "uri": tel
            #       },
            #       {
            #           "type": "uri",
            #           "label": "詳しく見る",
            #           "uri": pr
            #       }
            #   ]
            # }
            # colums<<rest_detail
            # search_rest(ImageURL, title, pr, uri, shopmap, tel)
          # else
          #   return colums
          # end
        # end

            message = [{
              "type": "template",
              "altText": "this is a carousel template",
              "template": {
                  "type": "carousel",
                  "columns": [
                    {
                      "thumbnailImageUrl": "#{@restaurant[0]["image_url"]["shop_image1"]}",
                      "imageBackgroundColor": "#FFFFFF",
                      "title": "#{@restaurant[0]["name"]}",
                      "text": "#{@restaurant[0]["pr"]["pr_short"]}",
                      "defaultAction": {
                          "type": "uri",
                          "label": "View detail",
                          "uri": "#{@restaurant[0]["url_mobile"]}"
                      },
                      "actions": [
                          {
                              "type": "postback",
                              "label": "Buy",
                              "data": "#{@restaurant[0]["address"]}"
                          },
                          {
                              "type": "postback",
                              "label": "Add to cart",
                              "data": "https://line.me/R/call/81/#{@restaurant[0]["tel"]}"
                          },
                          {
                              "type": "uri",
                              "label": "View detail",
                              "uri": "#{@restaurant[0]["url_mobile"]}"
                          }
                      ]
                    },
                    {
                      "thumbnailImageUrl": "#{@restaurant[1]["image_url"]["shop_image1"]}",
                      "imageBackgroundColor": "#FFFFFF",
                      "title": "#{@restaurant[1]["name"]}",
                      "text": "#{@restaurant[1]["pr"]["pr_short"]}",
                      "defaultAction": {
                          "type": "uri",
                          "label": "View detail",
                          "uri": "#{@restaurant[1]["url_mobile"]}"
                      },
                      "actions": [
                          {
                              "type": "postback",
                              "label": "Buy",
                              "data": "#{@restaurant[1]["address"]}"
                          },
                          {
                              "type": "postback",
                              "label": "Add to cart",
                              "data": "https://line.me/R/call/81/#{@restaurant[1]["tel"]}"
                          },
                          {
                              "type": "uri",
                              "label": "View detail",
                              "uri": "#{@restaurant[1]["url_mobile"]}"
                          }
                      ]
                    }
                ],
                  "imageAspectRatio": "rectangle",
                  "imageSize": "cover"
              }
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

  # def search_rest(ImageURL, title, text, uri, map, tel)
  #   rest_detail = {
  #     "thumbnailImageUrl": ImageURL,
      # "imageBackgroundColor": "#FFFFFF",
  #     "title": title,
  #     "text": text,
  #     "defaultAction": {
  #         "type": "uri",
  #         "label": "View detail",
  #         "uri": uri
  #     },
  #     "actions": [
  #         {
  #             "type": "uri",
  #             "label": "地図を見る",
  #             "uri": map
  #         },
  #         {
  #             "type": "uri",
  #             "label": "電話する",
  #             "uri": tel
  #         },
  #         {
  #             "type": "uri",
  #             "label": "詳しく見る",
  #             "uri": uri
  #         }
  #     ]
  #   }
  #   colums << rest_detail
  # end

end