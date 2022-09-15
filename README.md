# HAQQ---False-alarm-

1. Создаем телеграм бота здесь BotFather `https://telegram.me/botfather`. Посылаем команду `/newbot`. Придумываем боту имя , любое, в конце bot . 

2. Записываем access token бота. 

3. Создаем приватный чат в telegram

4. Записываем ID чата

5. Добавляем бота в админиcтраторы созданного чата. С правами на отправление сообщений, остальное выключаем

6. Загружаем на сервер скрипты `cmd-check-and-send.sh`  `cmd-send-message.sh`. Исправляем в них `CHANNEL_ID=` на ID чата  и `BOT_TOKEN=` на access token бота.

7. Добавляем скрипт cmd-check-and-send.sh в cron, вызываем 1 раз в минуту
`*/1 * * * *     haqq    /home/haqq/tg-bot/cmd-check-and-send.sh`

8. Радуемся, что не надо пялится в логи постоянно

![haqq  False alarm! 1](https://user-images.githubusercontent.com/76874974/190489346-95289dea-9607-48f1-97ac-3fd523c53042.png)
![haqq  False alarm! 2](https://user-images.githubusercontent.com/76874974/190489347-d1c19afc-685b-4525-9cd6-2109b336ef78.png)

