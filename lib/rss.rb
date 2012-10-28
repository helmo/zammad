module RSS
  def self.fetch(url, limit = 10)
    cache_key = 'rss::' + url
    items = Cache.get( cache_key )
    return items if items

    begin
      puts 'fetch rss...'
      response = Net::HTTP.get_response( URI.parse(url) )
      if response.code.to_s != '200'
        return
      end
      rss     = SimpleRSS.parse response.body
      items   = []
      fetched = 0
      rss.items.each { |item|
        record = {
          :id        => item.id,
          :title     => item.title,
          :summary   => item.summary,
          :link      => item.link,
          :published => item.published
        }
        items.push record
        fetched += 1
        break item if fetched == limit.to_i
      }
      Cache.write( cache_key, items, :expires_in => 4.hours )
    rescue Exception => e
      puts "can't fetch #{url}"
      puts e.inspect
    end

    return items
  end
end