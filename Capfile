# Using the Rails Asset Pipeline
load 'deploy/assets'
[ Proc.new{ |path| !%w(.js .css).include?(File.extname(path)) }, /application.(css|js)$/ ]

load 'deploy'
Dir['vendor/gems/*/recipes/*.rb','vendor/plugins/*/recipes/*.rb'].each { |plugin| load(plugin) }
load 'config/deploy' # remove this line to skip loading any of the default tasks