#
# Makes anything web-scale
#
# make <anything> web scale
#

module.exports = (robot) ->
  robot.respond /make (.*)( web)? scale/i, (msg) ->
    thing_to_scale = "#{msg.match[1]}"
    if thing_to_scale.match /mongo/i
    	msg.send "Mongo DB is already web scale: http://www.mongodb-is-web-scale.com/"
    else if thing_to_scale.match /me/i
    	msg.send "No problem! Piping #{thing_to_scale} to /dev/null ..."
    else
	    msg.send "No problem! Piping #{thing_to_scale} to /dev/null ..."
