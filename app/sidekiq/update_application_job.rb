class UpdateApplicationJob
  include Sidekiq::Job

  def perform(application_name, token)
    @application = Application.find_by("token": token)
    @application.with_lock do
      @application.update(name: application_name)
    end
  end
end
