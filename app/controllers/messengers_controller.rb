class MessengersController < ApplicationController
  skip_before_action :verify_authenticity_token, only: [:create]
  def index
    render :json => params["hub.challenge"]
  end

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
    token = "EAALZBuhDKCksBAJ9ABX9fxLdRr56PxSK8cqJZBrJZCOXSBB8kvTidDudU9ZCiHrdrVMqEpOGuqP7X9tNQDL0vMLNKwZBO61foqTzYJHkMbO5dZBcCQ8nFFggQecrniHksEPUVLQAazZCMhylLDeEN38IfsWvsUQG6hZCoziVaQUV6AZDZD"
    uri = URI.parse("https://graph.facebook.com/v2.6/me/messages?access_token=" + token)
    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = true
    param = { recipient: { id: sender }, message: messageData }

    header = {"Content-Type" =>"application/json"}
    resp = http.post(uri.request_uri, param.to_json, header)
    resp
  end
end
