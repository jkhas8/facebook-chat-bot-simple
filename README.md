#The simple example of Facebook chat bot using Ruby on Rails

Now I will share you how to create a basic Facebook chat bot using RoR.
Following steps:

###Step 1

- Go to the manager page of your facebook web app and chose `Messenger`:

```
https://developers.facebook.com/apps/your-app-id/messenger/
```

- Chose a page which you want to test with this chat bot, and remember
  the token which using for the next step:

![chose the
page](https://i.gyazo.com/f41f3b22a55597249960be09d7383445.png)

- Chose the webhook events and add the chosed page to the subscribtion:

![pick webhook
events](https://i.gyazo.com/7c98333be1097c04ac049219a88c6126.png)

###Step 2

- Create a new Rails app

```cmd
rails new facebook-bot-chat-rails
```

- Create the `Messengers` controller with two actions: `index`, `create`

```cmd
rails generate controller Messengers index create
```

```ruby
#app/controllers/messengers_controller.rb
class MessengersController < ApplicationController
  skip_before_action :verify_authenticity_token, only: [:create]
  def index
    render :json => params["hub.challenge"]
  end
end

#config/routes.rb
resources :messengers, only: [:index, :create]
```

###Step 3

You can use the `ngrok` to test the app from local.

- Go to the `Webhooks` tab on the menu of Facebook app manager page

- Add the callback url `https://8d206053.ngrok.io/messengers` with the
  token which you saved at step 2:

![add url
callback](https://i.gyazo.com/4c0a683594a00e2fba3bd7ff1aaba608.png)

###Step 4

- Back to the Rails app, and add the action `create` to recieve the
  message from Facebook webhook.

```ruby
class MessengersController < ApplicationController
  ...
  def create
    messaging_events = params[:entry][0][:messaging]
    messaging_events.each_with_index do |messaging_event, index|
      event = params[:entry][0][:messaging][index]
      sender = event[:sender][:id]
      if event[:message] && event[:message][:text]
        text = event[:message][:text]
        send_text_message sender, text
      end
    end
    render :json => "ok"
  end

  private
  def send_text_message sender, text
    puts sender
    messageData = { text: text }
    token = "your-token"
    uri = URI.parse("https://graph.facebook.com/v2.6/me/messages?access_token=" + token)
    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = true
    param = { recipient: { id: sender }, message: messageData }

    header = {"Content-Type" =>"application/json"}
    resp = http.post(uri.request_uri, param.to_json, header)
    resp
  end
end

```

**Ok, now your app is ready! Good luck.**
