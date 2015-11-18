if Rails.env.eql?("development")
  Sidekiq.configure_server do |config|
    config.redis = { :url => 'redis://localhost:6379/9', :namespace => 'sidekiq-dev' }
  end

  Sidekiq.configure_client do |config|
    config.redis = { :url => 'redis://localhost:6379/9', :namespace => 'sidekiq-dev' }
  end
elsif Rails.env.eql?("production")
  Sidekiq.configure_server do |config|
    config.redis = { :url => 'redis://localhost:6379/12', :namespace => 'sidekiq' }
  end

  Sidekiq.configure_client do |config|
    config.redis = { :url => 'redis://localhost:6379/12', :namespace => 'sidekiq' }
  end
end


require 'sidekiq/web'

Sidekiq::Web.use Rack::Auth::Basic do |username, password|
  username == '41studio' && password == '415tud10'
end 