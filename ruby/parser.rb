require 'rubygems'
require 'watir'
require 'net/http'
require 'json'
require 'nokogiri'
require 'Hpricot'

class Parser
  # This class is written by hxgqh@126.com
  def initialize(data = nil)
    current_dir = File.dirname(__FILE__)
    ENV['PATH'] = ENV['PATH']+':'+current_dir

    if data
      @data = data
      puts @data
    end

    @res_hash = {
      'total_mhs' => '',
      'received' => '',
      'accepted' => '',
      'per_minute' => '',
      'efficiency' => '',
      'up_time' => '',
      'ip' => '',
      'mask' => '',
      'gateway' => '',
      'web_port' => '',
      'primary_dns' => '',
      'secondary_dns' => '',
      'ports' => '',
      'server_addresses' => '',
      'userpass' => ''
    }
  end

  def open
    @br = Watir::Browser.new :chrome
  end

  def get_data_uri(url)
    uri = URI(url)
    res = Net::HTTP.get(uri)
    #p res

    return res
  end

  def get_data_watir(url)
    res = nil

    begin
      @br.goto(url)
      #p @br.url
      p @br.html
      res = @br.html
    rescue => ex
      p ex.message
    end

    return res
  end

  def mp_get_data_watir(url_list)
    begin
      for url in url_list do
        p url
        #@br.goto(url)
      end
    rescue => ex
      p ex.message
    end
  end

  def close
    if @br
      @br.close
    end
  end

  def parse_nokogiri(html)
    # Do parse here using nokogiri
    nok = Nokogiri::HTML(html)
    #p nok

    nok.css('tr').each do |tr|
      #p 1
      count = 0
      key = nil
      tr.children.each do |td|
        count += 1
        if count == 2
          count == 0

          #p td
          value = td.content
          if td.children[0].name == 'input'
            value = td.children[0].attributes['value'].value
          end

          if key
            @res_hash[key] = value
          end

          key = nil
        elsif count == 1
          key = td.content.sub(':','').sub(' ','_').downcase
          #p key
        end
      end
    end

    #p @res_hash

    return @res_hash
  end

  def parse_watir
    # Do parse here using watir
  end
end