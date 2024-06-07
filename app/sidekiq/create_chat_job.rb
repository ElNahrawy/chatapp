class CreateChatJob
  include Sidekiq::Job

  def perform(token, chat_number, chat_count)
    @application = Application.find_by(token: token)
    @chat = @application.chats.new(chat_number: chat_number, message_count:0)

    if @chat.save
      $redis.set("#{token}_#{chat_number}_message_count", 0)
      $redis.set("#{token}_#{chat_number}_message_number", 0)
      # @application.with_lock do
      #   @application.update(chat_count: chat_count)
      # end
    else
      $lock_manager.lock("#{token}_chat_creation_lock", 2000) do |locked|
        if locked
          $redis.decr("#{token}_chat_count")
          $redis.decr("#{token}_chat_number")
        end
      end
    end
  end
end
