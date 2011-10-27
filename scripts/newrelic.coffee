# Allows Hubot to get performance stats from New Relic
#
# stats for <app_name> -

module.exports = (robot) ->
  robot.respond /(stats)( for)? (.*)/i, (msg) ->
    api_key       = process.env.HUBOT_NEWRELIC_API_KEY
    account_id    = process.env.HUBOT_NEWRELIC_ACCOUNT_ID
    app_id_map    = JSON.parse(process.env.HUBOT_NEWRELIC_APP_ID_MAP)
    app_name      = "#{msg.match[3]}"
    app_id        = app_id_map[app_name]
    threshold_url = "https://rpm.newrelic.com/accounts/#{account_id}/applications/#{app_id}/threshold_values.xml"

    if not app_id?
      valid_names = (k for k,v of app_id_map)
      msg.send "I've never heard of \"#{app_name}\". Try one of these: #{valid_names}"
    else
      fetchAndPrint(msg, threshold_url, api_key)

fetchAndPrint = (msg, threshold_url, api_key) ->
  msg.http(threshold_url)
    .header('x-api-key', api_key)
    .get() (err, res, body) ->
      if err?
        msg.send "Error: #{err}"
      else
        parseAndPrint(msg, body)

parseAndPrint = (msg, body) ->
  parser = require 'xml2json'
  data = JSON.parse(parser.toJson(body));
  stat_lines = []
  stat_lines = (for threshold_value in data['threshold-values']['threshold_value']
    switch threshold_value['name']
      when 'Apdex'              then "Apdex            : #{threshold_value['formatted_metric_value']}"
      when 'Application Busy'   then "Application Busy : #{threshold_value['formatted_metric_value']}"
      when 'Error Rate'         then "Error Rate       : #{threshold_value['formatted_metric_value']}"
      when 'Throughput'         then "Throughput       : #{threshold_value['formatted_metric_value']}"
      when 'CPU'                then "CPU              : #{threshold_value['formatted_metric_value']}"
      when 'Response Time'      then "Response Time    : #{threshold_value['formatted_metric_value']}"
      when 'Errors'             then "Errors           : #{threshold_value['formatted_metric_value']}"
      when 'Memory'             then "Memory           : #{threshold_value['formatted_metric_value']}"
      when 'DB'                 then "DB               : #{threshold_value['formatted_metric_value']}"
  )
  msg.send "<pre>#{stat_lines.join('<br/>')}</pre>"

# Example XML Response:
#
# <?xml version="1.0" encoding="UTF-8"?>
# <threshold-values type="array">
#   <threshold_value threshold_value="2" end_time="2011-10-27 03:09:37" name="Apdex" metric_value="0.83" formatted_metric_value="0.83 [1.0]" begin_time="2011-10-27 03:06:37"/>
#   <threshold_value threshold_value="1" end_time="2011-10-27 03:09:37" name="Application Busy" metric_value="5.5" formatted_metric_value="5.5%" begin_time="2011-10-27 03:06:37"/>
#   <threshold_value threshold_value="1" end_time="2011-10-27 03:09:37" name="Error Rate" metric_value="0.52" formatted_metric_value="0.52%" begin_time="2011-10-27 03:06:37"/>
#   <threshold_value threshold_value="1" end_time="2011-10-27 03:09:37" name="Throughput" metric_value="322" formatted_metric_value="322 rpm" begin_time="2011-10-27 03:06:37"/>
#   <threshold_value threshold_value="1" end_time="2011-10-27 03:09:37" name="CPU" metric_value="11.7" formatted_metric_value="11.7%" begin_time="2011-10-27 03:06:37"/>
#   <threshold_value threshold_value="1" end_time="2011-10-27 03:09:37" name="Response Time" metric_value="832" formatted_metric_value="832 ms" begin_time="2011-10-27 03:06:37"/>
#   <threshold_value threshold_value="1" end_time="2011-10-27 03:09:37" name="Errors" metric_value="1.7" formatted_metric_value="1.7 epm" begin_time="2011-10-27 03:06:37"/>
#   <threshold_value threshold_value="1" end_time="2011-10-27 03:09:37" name="Memory" metric_value="11499" formatted_metric_value="11,499 MB" begin_time="2011-10-27 03:06:37"/>
#   <threshold_value threshold_value="1" end_time="2011-10-27 03:09:37" name="DB" metric_value="0.0" formatted_metric_value="0%" begin_time="2011-10-27 03:06:37"/>
# </threshold-values>


