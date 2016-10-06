#slack Ghost writer
library('slackr')
webhook <- 'https://hooks.slack.com/services/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'
token <- 'xoxp-4161618133-8454015014-88296352738-2b0e89fc50c2ce0d90b1b1ad2fcda34e'
username <- 'TT_Ghost'
channel <- '#ghost_writer'

#payload <- {"text": "This is a line of text in a channel.\nAnd this is another line of text."}

  
slackrSetup(channel=channel, 
            incoming_webhook_url=webhook,
            api_token = token)

slackr_bot('test',
       channel = channel,
       incoming_webhook_url=webhook,
       username = username)