class CounterUpdateScheduler
    include Sidekiq::Job
    def perform
        applications = Application.all
        applications.each do |application|
            token = application.token
            chat_count = $redis.get("#{token}_chat_count")
            application.with_lock do
                application.update(chat_count: chat_count)
            end
            chats = application.chats.all
            chats.each do |chat|
                chat_number = chat.chat_number
                message_count = $redis.get("#{token}_#{chat_number}_message_count")
                chat.with_lock do
                    chat.update(message_count: message_count)
                end
            end
        end
    end
end