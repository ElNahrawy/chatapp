class CreateApplicationJob
  include Sidekiq::Job

  def perform(application_name, token)
    @application = Application.new(name: application_name, token:token, chat_count:0)
    @application.save
    if @application.save
      $redis.set("#{token}_chat_count", 0)
      $redis.set("#{token}_chat_number", 0)   
    end
  end
end
