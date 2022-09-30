# HAQQ-alarm-

1. Create a bot here BotFather `https://telegram.me/botfather`. Send the command `/newbot`. Give the bot a name, any name, at the end of bot. 

2. Write the access token of the bot. 

3. Create a private chat on telegram

4. Record bot ID

5. Add bot to administrators of created chat. With rights to send messages, disable everything else

6. Load scripts `cmd-check-and-send.sh` `cmd-send-message.sh` on the server. Fix in them `CHANNEL_ID = ` in the chat ID and ` BOT_TOKEN = ` in the access token of the bot.

7. Add cmd-check-and-send.sh script to cron, call it once a minute
`*/1 * * * * * haqq /home/haqq/tg-bot/cmd-check-and-send.sh`.

8. Glad we don't have to stare at the logs all the time

![haqq  False alarm! 1](https://user-images.githubusercontent.com/76874974/190489346-95289dea-9607-48f1-97ac-3fd523c53042.png)
![haqq  False alarm! 2](https://user-images.githubusercontent.com/76874974/190489347-d1c19afc-685b-4525-9cd6-2109b336ef78.png)

