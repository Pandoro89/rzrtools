module ApplicationHelper
  
  def timeago(time, options = {})
    options[:class] ||= "timeago"
    content_tag(:abbr, time.to_s, options.merge(:title => time.getutc.iso8601)) if time
  end
  
  def request_trust(trust_url = nil, *args)# "http://#{request.host}"+((request.port!=80)?":#{request.port}":"")+"/", *args)
    # trust_url = root_url
    if trust_url.kind_of?(Hash)
      trust_url = url_for(trust_url.merge(:only_path => false)) 
    else
      trust_url = root_url + "*"
    end
    javascript_tag "CCPEVE.requestTrust(#{trust_url.inspect});", *args
  end
  
end
