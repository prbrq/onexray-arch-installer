# onexray-bin для Arch-подобных дистрибутивов

Пакет `onexray-bin` собирает официальный Linux-релиз [OneXray](https://onexray.com/)
(GitHub: [YuanDevTeam/OneXray](https://github.com/YuanDevTeam/OneXray)) в пакет
pacman для Arch, Manjaro, EndeavourOS, CachyOS, Garuda, Omarchy и т. п.

OneXray — клиент на Xray-core: TUN-режим, Smart Routing, импорт JSON
(outbound / Custom / Advanced / Raw), подписки Remnawave. Серверов и подписок
в поставке нет — их выдаёт провайдер.

## Что делает пакет

| Что | Куда |
| --- | --- |
| Приложение и ядро | `/opt/OneXray/` (как в официальном DEB) |
| Команда запуска | `/usr/bin/onexray -> /opt/OneXray/OneXray` |
| Меню и иконки | `/usr/share/applications/OneXray.desktop`, `hicolor/128x128`, `hicolor/256x256` |
| Обработчик `onexray://` | через `MimeType=x-scheme-handler/onexray` в .desktop |
| Capabilities ядра | pacman-хук `90-onexray-caps.hook`: `cap_net_admin,cap_net_raw+eip` на `OneXrayCore` |

Зависимости: `gtk3` (тянет весь GTK/Flutter-стек), `procps-ng` (`pgrep`/`pkill`
для контроля процесса ядра), `libcap` (`setcap`).

## Установка

```bash
sudo pacman -S --needed base-devel
./install.sh
```

`install.sh` вызывает `makepkg -si`: ставит зависимости, собирает пакет из
официального артефакта и устанавливает его. Вручную то же самое:

```bash
makepkg -si
```

Перед установкой закройте запущенный OneXray: после обновления файлов VPN-ядро
нужно перезапустить из приложения, иначе останется работать старая копия из
удалённого inode.

## Миграция с ручной установки DEB/ZIP

Если OneXray уже распакован вручную (как обычно и бывает: `/opt/OneXray`
принадлежит пользователю, `/usr/bin/OneXray` — самодельный симлинк), уберите
остатки, чтобы не осталось файлов, не принадлежащих пакету:

```bash
sudo rm -rf /opt/OneXray \
            /usr/bin/OneXray \
            /usr/share/applications/OneXray.desktop \
            /usr/share/icons/hicolor/128x128/apps/OneXray.png \
            /usr/share/icons/hicolor/256x256/apps/OneXray.png
```

Все эти пути при ручной распаковке никому не принадлежат, но pacman всё равно
отказывается их перезаписывать ("exists in filesystem"), поэтому удаление
обязательно. Данные пользователя (`~/.local/share/net.yuandev.onexray`,
настройки, серверы, подписки) этих команд не касаются; обновление
GeoSite/GeoIP, выбранное в приложении, продолжит работать.

## Обновление

```bash
./update.sh     # подтягивает последний релиз GitHub, обновляет pkgver и sha256, пересобирает .SRCINFO
./install.sh
```

Если `makepkg -si` после обновления падает с `exists in filesystem`, значит в
системе остались файлы от ручной установки — см. раздел о миграции выше.

`update.sh` работает только с официальными `.deb`-артефактами, поэтому
контрольные суммы совпадают с теми, что публикует GitHub.

## Удаление

```bash
sudo pacman -Rns onexray-bin
```

## Технические детали

- Пакет собирается из официального `OneXray-linux-x86_64.deb` /
  `OneXray-linux-aarch64.deb`: в нём готовый layout `/opt`, .desktop и иконки.
  Имена артефактов уже совпадают с `$CARCH`, поэтому `source_x86_64` и
  `source_aarch64` указывают на разные файлы с разными суммами.
- `!strip` и `!debug` обязательны: `libapp.so` — AOT-снимок Dart, его нельзя
  обрабатывать strip.
- Capabilities нельзя выставить в `package()` (fakeroot), и они теряются при
  каждой замене `OneXrayCore` пакетным менеджером. Поэтому вместо `.install`-
  скриптлета используется pacman-хук, который срабатывает после установки и
  обновления пакета.
- Кэш MIME и иконок обновляют штатные хуки `desktop-file-utils` и
  `gtk-update-icon-cache` (первый приходит зависимостью `gtk3`).
- Требования upstream: glibc 2.39+ и ядро 5.3+ (pidfd). На текущем Arch это
  выполняется всегда; `/dev/net/tun` даёт модуль `tun` штатного ядра.
- В трее приложение использует DBus StatusNotifierItem, отдельный
  `libayatana-appindicator` не линкуется. В GNOME для иконки в трее нужно
  расширение AppIndicator; в Hyprland/Waybar SNI поддерживается из коробки.

## Наблюдения по upstream-артефактам

- Официального AUR-пакета нет, Linux-сборки распространяются только как DEB и ZIP.
- DEB содержит `postinst`, который создаёт `/usr/bin/OneXray` и вызывает
  `setcap`; ровно это пакет делает штатными средствами pacman.
- В ZIP нет `.desktop` и иконок — поэтому источником выбран DEB.
- `libdartjni.so` линкован с `libjvm.so`, но на Linux не загружается (наследие
  Android-сборки); JVM в зависимости не нужна.
