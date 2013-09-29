#encoding: UTF-8
require 'optparse'

require './form.rb'
require './parser.rb'

require 'thread'


def get_conf(file)
  p '读取策略文件'
  strategy_hash = {}
  set_re = /([^=^\s]*)\s*=\s*([^=^\s*]*)/

  begin
    File.open(file,'r') do |f|
      lines = f.readlines()
      f.close

      strategy = count = 0
      set_flag = false
      lines.each do |line|
        line = line.sub(/\n/,'')
        if line[0] != '#' # not comment line
          if line.include?'[strategy]'
            strategy = count
            count += 1
            set_flag = false
            strategy_hash[strategy] = {}
          elsif line.include?'[set]'
            strategy_hash[strategy]['set'] = {}
            set_flag = true
          else
            key_value = set_re.match(line)
            if key_value
              if set_flag
                strategy_hash[strategy]['set'][key_value[1]] = key_value[2]
              else
                k = key_value[1]
                v = key_value[2]
                strategy_hash[strategy][k] = v
              end
            end
          end
        end
      end
      return strategy_hash
    end
  rescue  Exception => e
    puts e.message
    puts e.backtrace.inspect
    return {}
  end
end


# 根据配置文件中的ip_list，生成一个ip_array
# =@param [String] ip_list 配置文件中的ip列表，如'192.168.1.8,192.168.2.1-100,192.168.3-10.2-10'
def generate_ip_array(ip_list)
  ip_array = []

  if ip_list
    begin
      ip_range_list = ip_list.split(/,/)
      ip_range_list.each do |ip_range|
        if ip_range.include?'-'
          # a.b.c.d 类似ip地址。注意：不支持a或b中包含'-'
          a,b,c,d = ip_range.split(/\./)
          if c.include?'-'
            c_min,c_max = c.split(/-/)
            c_min = Integer c_min
            c_max = Integer c_max
            (c_min..c_max).each do |c|
              c = String c
              if d.include?'-'
                d_min,d_max = d.split(/-/)
                d_min = Integer d_min
                d_max = Integer d_max
                (d_min..d_max).each do |d|
                  d = String d
                  ip_array.push a+'.'+b+'.'+c+'.'+d
                end
              else
                ip_array.push a+'.'+b+'.'+c+'.'+d
              end
            end
          else
            if d.include?'-'
              d_min,d_max = d.split(/-/)
              d_min = Integer d_min
              d_max = Integer d_max
              (d_min..d_max).each do |d|
                d = String d
                ip_array.push a+'.'+b+'.'+c+'.'+d
              end
            else
              ip_array.push a+'.'+b+'.'+c+'.'+d
            end
          end
        else
          ip_array.push ip_range
        end

      end
    rescue Exception => e
      p e.message
      p e.backtrace.inspect
    end
  end

  return ip_array
end


# 获取以ip为key的hash，得到每个ip的strategy
# =@param [Hash] strategy_hash get_conf()函数的返回值
# ==@return {ip1:{},ip2:{},...}
def generate_ip_conf(strategy_hash)
  p 'func generate_ip_conf'
  ip_strategy_hash = {}

  if strategy_hash
    strategy_hash.each { |k,v|
      begin
        ip_array = generate_ip_array(v['ip_list'])
        v.delete('ip_list')
        ip_array.each do |ip|
          ip_strategy_hash[ip] = v
        end
      rescue Exception => e
        p e.message
        p e.backtrace.inspect
      end
    }
  end

  return ip_strategy_hash
end


def store_result(ip_info_hash)
  p 'func store_result'

  column_array = %w[time, total_mhs, received, accepted, per_minute, efficiency, up_time,
                ip, mask, gateway, web_port, primary_dns, secondary_dns, ports,
                server_addresses, userpass]

  if ip_info_hash
    # @Todo:parsed result should be stored some where
    begin
      t = Time.new.strftime('%Y-%m-%d %H:%M:%S')
      f = File.open('data.csv','a+')

      # write table header
      column_array.each do |column|
        f.write(column)
      end
      f.write('\n')

      # write table content
      ip_info_hash.each {
        |ip,v1|
        column_array.each do |column|
          p column
          p v1
          f.write(v1[column])
        end
        f.write('\n')
      }
      f.close
    rescue Exception => e
      p e.message
      p e.backtrace.inspect
    end
  end
end


def set_devices_mt(ip_strategy_hash)
  p '设置设备参数'

  if ! ip_strategy_hash
    return -1
  end

  data_template = 'JMIP=%ip&JMSK=%mask&JGTW=%gateway&WPRT=%web_port&PDNS=%primary_dns&SDNS=%secondary_dns&MPRT=%ports
                  &MURL=server_addresses&USPA=userpass&update=Update%2FRestart'
  key_re_hash = {
      'ip' => /%ip/,
      'mask' => /%mask/,
      'gateway' => /%gateway/,
      'web_port' => /%web_port/,
      'primary_dns' => /%primary_dns/,
      'secondary_dns' => /%secondary_dns/,
      'ports' => /%ports/,
      'server_addresses' => /%server_addresses/,
      'userpass' => /%userpass/
  }
  max_thread_num = 5

  psr = Parser.new()
  ip_array = ip_strategy_hash.keys

  i = 0

  m = Mutex.new
  while i < max_thread_num
    p 'thread '+String(i)

    if ip_array == []
      break
    end

    Thread.new {
      $stdout.write 'thread '+String(i)

      ip = nil

      m.synchronize {
        ip = ip_array[0]
        ip_array.delete(ip)
        i+=1
      }

      while ip
        if ip_strategy_hash[ip].has_key?'set'
          data = data_template
          set_hash = ip_strategy_hash[ip]['set']
          set_hash.each {
            |k,v|
            data = data.sub(key_re_hash[k],v)
          }

          data = URI.escape(data, Regexp.new("[^#{URI::PATTERN::UNRESERVED}]"))

          url = 'http:'+ip+':'+ip_strategy_hash[ip]['port']+'/'+'Upload_Data'

          cmd = 'curl -d "'+data+'" '+'"'+url+'"'
          #system(cmd)
          p cmd

          m.synchronize{
            ip = ip_array[0]
            ip_array.delete(ip)
          }
        end
      end
    }
  end
  p '设置结束'
end

def get_info_mt(ip_strategy_hash)
  p '轮询设备'
  if !ip_strategy_hash
    p 'error: ip_strategy_hash is nil'
    return
  end

  ip_info_hash = {}

  max_thread_num = 5
  ip_num = ip_strategy_hash.length

  thread_num = max_thread_num
  if ip_num%max_thread_num == 0
    thread_num = ip_num/max_thread_num
  else
    thread_num = ip_num/max_thread_num+1
  end

  thread_per_num = ip_num/thread_num

  psr = Parser.new()
  ip_array = ip_strategy_hash.keys

  # Test code here
  f = File.open('../Configuration.htm','r')
  res = f.read()
  f.close()

  p thread_num

  i = 0

  m = Mutex.new
  while i < max_thread_num
    p 'thread '+String(i)

    if ip_array == []
      break
    end

    Thread.new {
      $stdout.write 'thread '+String(i)
      #my_ip_array = ip_array.slice(i*thread_per_num,max(ip_num,i*thread_per_num))

      ip = nil

      m.synchronize {
        ip = ip_array[0]
        ip_array.delete(ip)
        i+=1
        #p ip_array
      }

      while ip
        #res = nil
        #url = 'http:'+ip+':'+ip_strategy_hash[ip]['port']
        #res = psr.get_data_uri(url)
        parsed_result = psr.parse_nokogiri(res)

        #store_result(parsed_result)

        m.synchronize{
          ip_info_hash[ip] = parsed_result
          ip = ip_array[0]
          ip_array.delete(ip)
          #p ip_info_hash
        }
      end
    }
  end

  return ip_info_hash
  p '轮询结束'
end

if __FILE__ ==  $0
  # Deal with command line options
  options = {}
  strategy_hash = nil
  ip_strategy_hash = nil

  get_flag = false
  set_flag = false

  option_parser = OptionParser.new do |opts|
    # 这里是这个命令行工具的帮助信息
    opts.banner = '命令行帮助'

    # Option 作为switch，不带argument，用于将switch设置成true或false
    options[:switch] = false



    # 指定配置文件
    opts.on('-c NAME', '--config Name', '策略文件') do |value|
      options[:name] = value
      strategy_hash = get_conf(value)
      ip_strategy_hash = generate_ip_conf(strategy_hash)
      #p ip_strategy_hash
      #p 'strategy_hash:'
      #p strategy_hash
    end

    # 运行状态为设置设备参数
    opts.on('-s', '--set', '设置设备参数') do
      # 这个部分就是使用这个Option后执行的代码
      options[:switch] = true
      set_flag = true
    end

    # 运行状态为轮训设备的状态参数
    opts.on('-g', '--get', Array, '获取设备信息') do |value|
      options[:array] = value
      get_flag = true
    end
  end.parse!

  p ip_strategy_hash

  if set_flag
    set_devices_mt(ip_strategy_hash)
  end

  if get_flag
    ip_info_hash = get_info_mt(ip_strategy_hash)
    #p ip_info_hash
    store_result(ip_info_hash)
  end

end