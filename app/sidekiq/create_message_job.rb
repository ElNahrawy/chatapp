class CreateMessageJob
  include Sidekiq::Job

  def perform(token, chat_number, message_number, message_count, message_body)
    @application = Application.find_by(token: token)
    @chat = @application.chats.find_by(chat_number: chat_number) if @application
    @message = @chat.messages.new(message_body: message_body,  message_number: message_number)
    if @message.save
      @chat.with_lock do
        @chat.update(message_count: message_count)
      end
    else
      $lock_manager.lock("#{token}_#{chat_number}_message_creation_lock", 2000) do |locked|
        if locked
          $redis.decr("#{token}_#{chat_number}_message_count")
          $redis.decr("#{token}_#{chat_number}_message_number")
        end
      end
    end
  end
end