Требования: Reapi + Rechecker, Reunion установленные выше amxmodx в metamod/plugins.ini

 
Настройки находятся по пути cstrike\addons\amxmodx\configs\plugins\unreal_nosteam_blocker.cfg.ini
(конфиг создается автоматически при первом запуске)

```
[general]
; Бан игроков которые зашли с фейковым нонстимом
ban_fake_nosteam = true
ban_fake_nosteam_string = amx_ban #[userid] 1000 'SteamID Changer detected'
; Выбросить игроков которые зашли с фейковым нон-стимом
drop_fake_nosteam = true
drop_fake_nosteam_string = Please remove SteamID Changer and use original Steam cs 1.6 client
; Предупредить всех о том что игрок зашел с фейковым нонстимом
hello_fake_nosteam = true
hello_fake_nosteam_string = User '[username]' join with SteamID Changer
; Банить игроков которые зашли с эмулятором реального Steam
; такое могут делать читы, а так же клиенты подхватывающие Steam (gsclient, nextclient, ...)
ban_fake_steam = false
ban_fake_steam_string = amx_ban #[userid] 1000 'Fake Steam client emulator detected'
; Выбросить игроков которые эмулируют реальный Steam
drop_fake_steam = false
drop_fake_steam_string = Please close Steam or use original Steam cs 1.6 client
; Предупредить о том что игрок с эмулятором реального Steam заходит на сервер
hello_fake_steam = true
hello_fake_steam_string = User '[username]' join with FakeSteam client
```
