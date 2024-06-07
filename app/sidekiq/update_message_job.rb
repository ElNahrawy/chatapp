class UpdateMessageJob
  include Sidekiq::Job

  def perform(token, chat_number, message_number, message_body)
    @application = Application.find_by(token: token)
    @chat = @application.chats.find_by(chat_number: chat_number) if @application
    @message = @chat.messages.find_by(message_number: message_number) if @chat
    @message.with_lock do
      @message.update(message_body: message_body)
    end
  end
end
