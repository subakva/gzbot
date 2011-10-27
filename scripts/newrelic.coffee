# Allows Hubot to get performance stats from New Relic
#
# stats for <app_name> -

module.exports = (robot) ->
  robot.respond /(stats)( for)? (.*)/i, (msg) ->
    api_key     = process.env.HUBOT_NEWRELIC_API_KEY
    account_id  = process.env.HUBOT_NEWRELIC_ACCOUNT_ID
    app_id_map  = JSON.parse(process.env.HUBOT_NEWRELIC_APP_ID_MAP)

    app_name    = "\"#{msg.match[3]}\""
    app_id = app_id_map[app_name]
    threshold_url = "https://rpm.newrelic.com/accounts/#{account_id}/applications/#{app_id}/threshold_values.json"

    msg.http(threshold_url)
      .header('x-api-key', api_key)
      .get() (err, res, body) ->
        data   = JSON.parse(body)
        msg.send "#{data}"
