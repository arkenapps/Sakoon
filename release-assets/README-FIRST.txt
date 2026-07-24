SAKOON v2.0.0  -  Azaan Audio Guard for Windows
ArkenApps  |  Designed by Arkenstone
===============================================================

WHAT THIS IS

Sakoon mutes your PC audio just before each azaan, holds the silence
through the window you configure, and restores exactly the state it
found afterwards. It never moves your volume slider.


HOW TO RUN IT

1. Extract Sakoon.exe from this zip to any folder you like, for
   example  C:\Users\<you>\Apps\Sakoon\
2. Double-click Sakoon.exe.
3. Windows will show a blue "Windows protected your PC" screen the
   first time. Click  More info  ->  Run anyway.  See below for why.
4. The Sakoon window opens and a tray icon appears. Pick your region
   and, when you have one, upload your authority's official monthly
   timing table.

Closing the window hides Sakoon to the system tray and it keeps
guarding your audio. Use Quit in the tray menu to exit completely -
that also restores your audio on the way out.

Sakoon creates a normal, visible shortcut in your Startup folder on
first run so it starts with Windows. You can turn that off in
Settings at any time. No administrator rights are needed, ever.


WHY WINDOWS WARNS YOU

Sakoon is not code-signed. A code-signing certificate is an annual
cost this project has not taken on. Windows SmartScreen therefore
flags any application it has not seen before, regardless of what the
application actually does. The warning is about reputation, not about
anything detected inside the file.

If you want to verify the file before trusting it, every release
publishes SHA256SUMS.txt. Check it in PowerShell:

    Get-FileHash Sakoon.exe

and compare the result with the published hash. Only ever download
Sakoon from:

    https://github.com/arkenapps/Sakoon/releases


WHERE YOUR DATA LIVES

    %LOCALAPPDATA%\Sakoon

Settings, uploaded timing tables and logs. Plain files, readable and
deletable by you. Nothing is sent anywhere - Sakoon opens no network
ports at all.


IMPORTANT

Sakoon is not a religious authority and cannot certify a prayer time.
Your local awqaf publication and your local mosque always take
precedence. Never rely on Sakoon as your only prayer reminder.


LICENCE

Free for personal, non-commercial use under the ArkenApps Personal
Use Licence. See LICENSE.txt in this zip.

Requires Windows 10 or 11. The app window uses Microsoft Edge
WebView2, which ships with Windows 11 and current Windows 10.

If Sakoon brings a little stillness to your day, a du'a for those who
built it is more than enough.
