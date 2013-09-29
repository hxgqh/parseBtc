require 'URI'
# 将字符串转成uri格式
URI.escape('/?search=a b', Regexp.new("[^#{URI::PATTERN::UNRESERVED}]"))