#require 'parsedate'
require 'date'

# require 'util'

start_time = ARGV.shift
end_time = ARGV.shift

# str = '202.238.95.113 - - [19/Feb/2011:03:00:02 +0900] "GET /antlers/javascripts/AC_RunActiveContent.js?1297843844 HTTP/1.1" 200 8321 "http://www.so-net.ne.jp/antlers/fanzone/freaks/latest.html" "Mozilla/4.0 (compatible; MSIE 7.0; Windows NT 6.0; SLCC1; .NET CLR 2.0.50727; Media Center PC 5.0; .NET CLR 3.5.30729; .NET CLR 3.0.30618; AskTbSPC2/5.9.1.14019)" 120 scweb.so-net.ne.jp 1136 8629 +'

# # puts str

# str =~ /(.*?) (.*?) (.*?) \[(.*)\] "(.*?) (.*?) (.*?)" ([0-9]{3}) (.*?) "(.*?)" "(.*?)" (.*?) (.*?) (.*?) (.*?) (.*?)$/
# host = $1
# client_identifier = $2
# authentication_user_name = $3
# request_time = DateTime.strptime($4, '%d/%b/%Y:%T %z')
# method = $5
# request_path = $6
# request_protocol = $7
# status_code = $8
# transfer_bype = $9
# referer = $10
# user_agent = $11
# request_processing_time = $12
# request_handle_server = $13
# receiving_bytes = $14
# sending_bytes = $15
# connection_status = $16

if start_time.nil?
  puts 'Usage: ruby tm_filter.rb start_time end_time < apache_logfile'
  puts 'ex1: ruby tm_filter.rb "19/Feb/2011:03:25:00 +0900" < apache_logfile'
  puts 'ex2: ruby tm_filter.rb "19/Feb/2011:03:30:00 +0900" "19/Feb/2011:03:40:00 +0900" < apache_logfile'
  exit 1
end

#puts "start_time: #{start_time}"
#puts "end_time: #{end_time}"

start_time = DateTime.strptime(start_time, '%d/%b/%Y:%T %z')
if end_time.nil?
  end_time = start_time + 3600
else
  end_time = DateTime.strptime(end_time, '%d/%b/%Y:%T %z')
end

#start = Time.now
while line = gets

  if /^([^\s]*) ([^\s]*) ([^\s]*) \[(.*?)\] "([^\s]*) ([^\s]*) ([^\s]*)" ([^\s]*) ([^\s]*) "([^"]*)" "([^"]*)" ([^\s]*) ([^\s]*) ([^\s]*) ([^\s]*) ([^\s]*)/ =~ line
    request_time = DateTime.strptime($4, '%d/%b/%Y:%T %z')
     if request_time >= start_time && request_time <= end_time
       print line
     end
  end
end
#puts "processing time: #{Time.now - start}s"
