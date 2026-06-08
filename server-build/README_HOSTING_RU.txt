ИНСТРУКЦИЯ ПО ЗАПУСКУ СЕРВЕРА
-----------------------------

* загрузить все файлы из этого архива в корень сервера hosting-minecraft.eu;
* в панели хостинга выбрать запуск через server.jar;
* если есть выбор версии Java, выбрать Java 21;
* если хостинг запускает Java 25, попробовать Java 21, потому что Minecraft 1.21.1/NeoForge стабильнее на Java 21;
* проверить, что путь libraries/net/neoforged/neoforge/21.1.230/unix_args.txt существует;
* если ошибка "Unable to access jarfile server.jar", значит server.jar не загружен в корень сервера;
* если ошибка "could not open libraries/net/neoforged/neoforge/21.1.230/unix_args.txt", значит папка libraries загружена не полностью или не была установлена через installer;
* этот сервер работает на NeoForge, это не Paper!
