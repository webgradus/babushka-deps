require 'cuba'
require 'json'

Eye::Http::ExtendedRouter = Cuba.new do
  def json(result)
    res.headers['Content-Type'] = 'application/json; charset=utf-8'
    res.write({ result: result }.to_json)
  end

  on root do
    res.write Eye::ABOUT
  end

  on get,"api/disk_space" do
   res.headers['Content-Type'] = 'application/json; charset=utf-8'
   data = `df -mT ~`.split("\n")[1].split(" ")
   res.write({
     result:
     {
       space:
       {
         total: data[2],
         used: data[3],
         free: data[4],
         used_in_percents: data[5]
       }
     }
   }.to_json)
  end

  [:info_data, :short_data, :debug_data, :history_data].each do |act|
    on "api/#{act.to_s.gsub(/_data$/, '')}", param("filter") do |filter|
      json Eye::Control.command(act, filter)
    end
  end

  [:start, :stop, :restart, :delete, :unmonitor, :monitor].each do |act|
    on put, "api/#{act}", param("filter") do |filter|
      json Eye::Control.command(act, filter)
    end
  end
end
