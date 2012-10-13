if Rails.env == 'production'
  CopycopterClient.configure do |config|
    config.api_key = '07a51a87c20d43b4d0e19ea683cc6f58'
    config.host = 'evening-water-7414.herokuapp.com'
  end
end
