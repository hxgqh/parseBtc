require 'net/http'

current_dir = File.dirname(__FILE__)
ENV['PATH'] = ENV['PATH']+':'+current_dir

require './main.rb'
require './parser.rb'
require './form.rb'


class Test
  def test_env
    puts ENV['PATH']
  end

  def test_parser_get_data_watir
    t1 = Time.new()

    psr = Parser.new('data')
    psr.open

    url = 'http://www.baidu.com'
    #url = '../Configuration.htm'
    n = 10

    t2 = Time.new()
    while n > 0
      psr.get_data_watir(url)
      n -= 1
    end

    t3 = Time.new()

    psr.close

    puts t2.to_f - t1.to_f
    puts t3.to_f - t2.to_f
  end

  def test_parser_mp_get_data_watir
    psr = Parser.new()
    #url_list = %w[http://www.baidu.com http://www.google.com]
    url_list = ['http://www.baidu.com','http://www.google.com']
    psr.mp_get_data_watir(url_list)
  end

  def test_parser_get_data_uri
    res = nil

    psr = Parser.new()
    url = 'http://www.baidu.com'
    n = 10
    t1 = Time.new
    while n > 0
      res = psr.get_data_uri(url)
      n -= 1
    end
    t2 = Time.new

    p t2.to_f - t1.to_f

    return res
  end

  def test_parser_parse_nokogiri
    res = nil
    psr = Parser.new()
    #url = 'http://www.baidu.com'
    #res = psr.get_data_uri(url)
    f = File.open('../Configuration.htm','r')
    res = f.read()
    f.close()

    n = 10
    t1 = Time.new
    while n > 0
      psr.parse_nokogiri(res)
      n -= 1
    end
    t2 = Time.new

    p t2.to_f - t1.to_f
  end

  def test_post
    data = 'JMIP=192.168.1.254&JMSK=255.255.255.0&JGTW=192.168.1.1&WPRT=8000&PDNS=192.168.1.1&SDNS=114.114.114.114&MPRT=8332%2C8333&MURL=199.180.254.117%2C199.180.254.117&USPA=coco8652.1254%3A123%2Ccoco8652.1254%3A123&update=Update%2FRestart'
    my_connection = Net::HTTP.new('192.168.1.253', 8000)
    response = my_connection.post('/', data)
    p response.body
  end

  def test_post1
    url = URI.parse('http://192.168.1.253:8000/Upload_Data')
    response = Net::HTTP.post_form(url,{
        'JMIP' => '192.168.1.254',
        'JMSK' => '255.255.255.0',
        'JGTW' => '192.168.1.1',
        'WPRT' => '8000',
        'PDNS' => '192.168.1.1',
        'SDNS' => '114.114.114.114',
        'MPRT' => '8332,8333',
        'MURL' => '199.180.254.117,199.180.254.117',
        'USPA' => 'coco8652.1254:123,coco8652.1254:123',
        'update' => 'Update/Restart'
    })
    puts response.body
  end

  def test_post2
    url = URI.parse('http://192.168.1.253:8000/Upload_Data')
    Net::HTTP.start(url.host, url.port) do |http|
      req = Net::HTTP::Post.new(url.path)
      req.set_form_data({
                            'JMIP' => '192.168.1.254',
                            'JMSK' => '255.255.255.0',
                            'JGTW' => '192.168.1.1',
                            'WPRT' => '8000',
                            'PDNS' => '192.168.1.1',
                            'SDNS' => '114.114.114.114',
                            'MPRT' => '8332,8333',
                            'MURL' => '199.180.254.117,199.180.254.117',
                            'USPA' => 'coco8652.1254:123,coco8652.1254:123',
                            'update' => 'Update/Restart'
                        })
      req['content-type'] = 'application/x-www-form-urlencoded'
      req['Accept'] = 'text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8'
      req['Accept-Encoding'] = 'gzip,deflate,sdch'
      req['Accept-Language'] = 'zh-CN,zh;q=0.8,en-US;q=0.6,en;q=0.4'
      #req['Cache-Control'] = 'max-age=0'
      #req['Connection'] = 'keep-alive'
      #req['User-Agent'] = 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_8_4) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/29.0.1547.65 Safari/537.36'
      #req['Host'] = '192.168.1.253:8000'
      #req['Origin'] = 'http://192.168.1.253:8000'
      #req['Referer'] = 'http://192.168.1.253:8000/'
      puts http.request(req).body
    end
  end

  def test_post_url
    data = 'JMIP=192.168.1.254&JMSK=255.255.255.0&JGTW=192.168.1.1&WPRT=8000&PDNS=192.168.1.1&SDNS=114.114.114.114&MPRT=8332%2C8333&MURL=199.180.254.117%2C199.180.254.117&USPA=coco8652.1254%3A123%2Ccoco8652.1254%3A123&update=Update%2FRestart'
    dst = 'http://192.168.1.253:8000/Upload_Data'
    cmd = 'curl -d "'+data+'" '+'"'+dst+'"'
    system(cmd)
  end

  def test_generate_ip_array
    ip_list = '192.168.2.1-10'
    p generate_ip_array(ip_list)
  end
end


if __FILE__ == $0
  p 'start'

  begin

    t = Test.new()
    #t.test_parser_mp_get_data_watir

    #t.test_parser_get_data_uri

    #t.test_parser_get_data_watir

    #t.test_parser_parse_nokogiri
    #t.test_post2
    #t.test_post_url
    t.test_generate_ip_array
  rescue Exception => e
    puts e.message
    puts e.backtrace.inspect
  end

  p 'end'
end