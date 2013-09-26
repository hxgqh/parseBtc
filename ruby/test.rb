
current_dir = File.dirname(__FILE__)
ENV['PATH'] = ENV['PATH']+':'+current_dir

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

    psr.parse_nokogiri(res)
  end
end


if __FILE__ == $0
  t = Test.new()
  #t.test_parser_mp_get_data_watir

  #t.test_parser_get_data_uri

  #t.test_parser_get_data_watir

  t.test_parser_parse_nokogiri
end