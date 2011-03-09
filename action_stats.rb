require 'date'

class ApacheLog
  attr_reader :total_request
  
  def initialize
    @total_request = 0
    @total_processing_time = 0.0
    @status_codes = {}
    @processing_time = {}
  end

  def add(status_code, request_processing_time)
    @total_request += 1
    @processing_time[status_code] ||= request_processing_time.to_i / 1000.0 # マイクロ秒をミリ秒単位に変換
    @processing_time[status_code] += request_processing_time.to_i / 1000.0
    @status_codes[status_code] ||= 0
    @status_codes[status_code] += 1
  end

  def total_processing_time
    sum = 0
    @processing_time.each_value {|x| sum += x }
    return sum
  end

  def request_by_status_code(code)
    return 0 if @status_codes[code].nil?
    return @status_codes[code]
  end

  def processing_time_by_status_code(code)
    return 0 if @status_codes[code].nil?
    return @processing_time[code]
  end
  
end

def read_logs
  paths = {}
  status_codes = []

  while line = gets
    if /^([^\s]*) ([^\s]*) ([^\s]*) \[(.*?)\] "([^\s]*) ([^\s]*) ([^\s]*)" ([^\s]*) ([^\s]*) "([^"]*)" "([^"]*)" ([^\s]*) ([^\s]*) ([^\s]*) ([^\s]*) ([^\s]*)/ =~ line
      host = $1
      client_identifier = $2
      authentication_user_name = $3
      request_time = DateTime.strptime($4, '%d/%b/%Y:%T %z')
      method = $5
      request_path = $6
      request_protocol = $7
      status_code = $8
      transfer_bype = $9
      referer = $10
      user_agent = $11
      request_processing_time = $12
      request_handle_server = $13
      receiving_bytes = $14
      sending_bytes = $15
      connection_status = $16
      request_path = request_path.sub(/\?.*$/, "")

      status_codes << status_code
      paths[request_path] ||= ApacheLog.new
      paths[request_path].add(status_code, request_processing_time)
    end
  end
  
  status_codes = status_codes.uniq.sort
  return paths, status_codes
end

def output_path_stats(paths, status_codes)
  #puts "Path,TR,TPT,#{status_codes.join(',')}"
  print "Path,"
  print "TR,"
  print "TPT[ms],"
  status_codes.each { |code| print "PT(#{code})[ms]," }
  status_codes.each { |code| print "R(#{code})," }
  print "\n"
    
  paths.each_pair do |path, log|
    request_count = []
    processing_time = []
    status_codes.each do |code|
      request_count << log.request_by_status_code(code)
      processing_time << log.processing_time_by_status_code(code)
    end
    puts [path, log.total_request, log.total_processing_time, processing_time, request_count].flatten.join(',')
  end
end

paths, status_codes = read_logs
output_path_stats(paths, status_codes)
