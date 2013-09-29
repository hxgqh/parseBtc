#encoding: UTF-8
require 'optparse'

require './form.rb'
require './parser.rb'


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


def set_devices(strategy_hash)
  p '设置设备参数'

  p '设置结束'
end

def get_info(strategy_hash)
  p '轮询设备'

  p '轮询结束'
end

if __FILE__ ==  $0
  # Deal with command line options
  options = {}
  option_parser = OptionParser.new do |opts|
    # 这里是这个命令行工具的帮助信息
    opts.banner = '命令行帮助'

    # Option 作为switch，不带argument，用于将switch设置成true或false
    options[:switch] = false

    strategy_hash = nil
    ip_strategy_hash = nil

    # 指定配置文件
    opts.on('-c NAME', '--config Name', '策略文件') do |value|
      options[:name] = value
      strategy_hash = get_conf(value)
      ip_strategy_hash = generate_ip_conf(strategy_hash)
      p ip_strategy_hash
      #p 'strategy_hash:'
      #p strategy_hash
    end

    # 运行状态为设置设备参数
    opts.on('-s', '--set', '设置设备参数') do
      # 这个部分就是使用这个Option后执行的代码
      options[:switch] = true
      set_devices(ip_strategy_hash)
    end

    # 运行状态为轮训设备的状态参数
    opts.on('-g', '--get', Array, '获取设备信息') do |value|
      options[:array] = value
      get_info(ip_strategy_hash)
    end
  end.parse!
end