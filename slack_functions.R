#slack Ghost writer
library('slackr')
slack_webhook <- paste(readLines("slack_webhook.txt"), collapse=" ")
slack_token <- paste(readLines("slack_token.txt"), collapse=" ")
slack_username <- 'TT_Ghost'
slack_channel <- '#ghost_writer'

#payload <- {"text": "This is a line of text in a channel.\nAnd this is another line of text."}

slack_ghost <- function(text){
  text <- paste("@channel ", text)
  
  slackr_setup(channel=slack_channel, 
              incoming_webhook_url=slack_webhook,
              api_token = slack_token,
              username = slack_username)
  
  text_slackr(text = text,
              icon_emoji = ":ghost:")
  
  #There are different options for posting, but they aren't all working correctly. I'll keep this for now.
  # slackr_bot(text,
  #            channel = slack_channel,
  #            incoming_webhook_url=slack_webhook,
  #            username = slack_username)
  # text_slackr(text = text,
  #             channel = slack_channel,
  #             incoming_webhook_url=slack_webhook
  #             # api_token = slack_token,
  #             # username = slack_username
  #             )
  #for some reason username and webhook aren't working
  # slackr_msg(text = text,
  #             channel = slack_channel,
  #             # api_token = slack_token,
  #             username = slack_username
  # )
}
