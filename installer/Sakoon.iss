; ============================================================
;  Sakoon - standalone Inno Setup installer
;  ArkenApps | Designed by Arkenstone
;
;  Self-contained: this folder carries its own icon and wizard art
;  under assets\, so it does not depend on the app source tree.
;
;  Per-user install (no admin, no UAC). The ONLY thing that ever touches
;  Windows startup is THIS installer, and only when the user ticks the
;  (unchecked-by-default) "Start with Windows" task. Sakoon.exe (v2.0.1+)
;  writes nothing to the Startup folder itself.
;
;  BUILD STEPS
;    1. Install Inno Setup 6:   winget install JRSoftware.InnoSetup
;    2. Build Sakoon.exe:       (in the app source)  build.bat
;    3. Copy the built Sakoon.exe into THIS folder, next to Sakoon.iss.
;       Optionally copy README-FIRST.txt and LICENSE.txt here too.
;    4. Compile:                iscc Sakoon.iss
;       Output:                 output\Sakoon-Setup-2.0.1.exe
;
;  HONEST LIMITATION: an installer does NOT fix Microsoft Defender /
;  SmartScreen by itself. The same unsigned Sakoon.exe sits inside it and
;  Setup.exe is itself unsigned. Sign both and/or submit them to Microsoft
;  to actually clear the warnings. This installer only makes install,
;  uninstall and optional-startup clean and conventional.
; ============================================================

#define MyAppName "Sakoon"
#define MyAppVersion "2.0.1"
#define MyAppPublisher "ArkenApps"
#define MyAppURL "https://arkenapps.com/azaan-audio-guard.html"
#define MyAppExeName "Sakoon.exe"

[Setup]
; Stable AppId links upgrades and uninstall across versions. Keep it.
AppId={{CA7F062D-B0C3-47D8-B939-39FB253A01B8}
AppName={#MyAppName}
AppVersion={#MyAppVersion}
AppVerName={#MyAppName} {#MyAppVersion}
AppPublisher={#MyAppPublisher}
AppPublisherURL={#MyAppURL}
AppSupportURL={#MyAppURL}
AppUpdatesURL={#MyAppURL}
DefaultDirName={localappdata}\Programs\Sakoon
DefaultGroupName=Sakoon
DisableProgramGroupPage=yes
; Per-user: no administrator password, no UAC elevation.
PrivilegesRequired=lowest
PrivilegesRequiredOverridesAllowed=dialog
WizardStyle=modern
SetupIconFile=assets\Sakoon.ico
WizardImageFile=assets\WizardImage.bmp
WizardSmallImageFile=assets\WizardSmallImage.bmp
UninstallDisplayIcon={app}\Sakoon.exe
UninstallDisplayName=Sakoon - azaan audio guard
OutputDir=output
OutputBaseFilename=Sakoon-Setup
Compression=lzma2
SolidCompression=yes
; If Sakoon is running, close it before replacing the exe; don't try to
; auto-restart it afterwards.
CloseApplications=yes
RestartApplications=no
Uninstallable=yes
ArchitecturesInstallIn64BitMode=x64compatible

[Languages]
Name: "english"; MessagesFile: "compiler:Default.isl"

[Tasks]
; Both unchecked by default - the user opts in deliberately.
Name: "startup"; \
  Description: "Start Sakoon automatically when I sign in to Windows"; \
  GroupDescription: "Windows startup:"
Name: "desktopicon"; \
  Description: "Create a desktop shortcut"; \
  GroupDescription: "Additional shortcuts:"; \
  Flags: unchecked

[Files]
; Sakoon.exe must sit beside this script at compile time.
Source: "Sakoon.exe"; DestDir: "{app}"; Flags: ignoreversion
; Optional extras - included only if present, never fatal if missing.
Source: "README-FIRST.txt"; DestDir: "{app}"; Flags: ignoreversion skipifsourcedoesntexist
Source: "LICENSE.txt"; DestDir: "{app}"; Flags: ignoreversion skipifsourcedoesntexist
; Keep a copy of the icon with the install so shortcuts always resolve it.
Source: "assets\Sakoon.ico"; DestDir: "{app}"; Flags: ignoreversion

[Icons]
Name: "{group}\Sakoon"; Filename: "{app}\Sakoon.exe"; WorkingDir: "{app}"; IconFilename: "{app}\Sakoon.ico"
Name: "{group}\Uninstall Sakoon"; Filename: "{uninstallexe}"
Name: "{userdesktop}\Sakoon"; Filename: "{app}\Sakoon.exe"; WorkingDir: "{app}"; IconFilename: "{app}\Sakoon.ico"; Tasks: desktopicon
; Startup shortcut created by the INSTALLER only, and only when the
; "startup" task is ticked. Windows then lets the user disable it later
; under Settings > Apps > Startup.
Name: "{userstartup}\Sakoon"; Filename: "{app}\Sakoon.exe"; WorkingDir: "{app}"; \
  IconFilename: "{app}\Sakoon.ico"; Comment: "Sakoon - azaan audio guard"; Tasks: startup

[Run]
Filename: "{app}\Sakoon.exe"; Description: "Launch Sakoon"; \
  WorkingDir: "{app}"; Flags: postinstall nowait skipifsilent

[UninstallDelete]
; Leave user data (%LOCALAPPDATA%\Sakoon) in place on uninstall so a
; reinstall keeps settings and tables. Remove the program dir if empty.
Type: dirifempty; Name: "{app}"
