$redis = Redis.new(url: ENV["REDIS_URL"] || "redis://localhost:6379/1")
$lock_manager = Redlock::Client.new([ENV["REDIS_URL"] || "redis://localhost:6379/1"])