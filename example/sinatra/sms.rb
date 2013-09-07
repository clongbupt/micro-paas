require 'sinatra/base'

class SmsService < Sinatra::Base 

  get '/' do
    erb :env, :format=>:html
 end
end
