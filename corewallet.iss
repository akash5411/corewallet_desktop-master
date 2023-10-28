; Script generated by the Inno Setup Script Wizard.
; SEE THE DOCUMENTATION FOR DETAILS ON CREATING INNO SETUP SCRIPT FILES!

#define MyAppName "corewalletdesktop"
#define MyAppVersion "1.5"
#define MyAppPublisher "My Company, Inc."
#define MyAppURL "https://www.example.com/"
#define MyAppExeName "corewallet_desktop.exe"

[Setup]
; NOTE: The value of AppId uniquely identifies this application. Do not use the same AppId value in installers for other applications.
; (To generate a new GUID, click Tools | Generate GUID inside the IDE.)
AppId={{35ADFA62-289A-448F-A508-A48EE3DE6D15}
AppName={#MyAppName}
AppVersion={#MyAppVersion}
;AppVerName={#MyAppName} {#MyAppVersion}
AppPublisher={#MyAppPublisher}
AppPublisherURL={#MyAppURL}
AppSupportURL={#MyAppURL}
AppUpdatesURL={#MyAppURL}
DefaultDirName={autopf}\{#MyAppName}
DisableProgramGroupPage=yes
; Uncomment the following line to run in non administrative install mode (install for current user only.)
;PrivilegesRequired=lowest
OutputDir=D:\corewallet_desktop\New folder
OutputBaseFilename=corewalletsetup
SetupIconFile=C:\Users\admin\Downloads\logo3 (1).ico
Compression=lzma
SolidCompression=yes
WizardStyle=modern

[Languages]
Name: "english"; MessagesFile: "compiler:Default.isl"

[Tasks]
Name: "desktopicon"; Description: "{cm:CreateDesktopIcon}"; GroupDescription: "{cm:AdditionalIcons}"; Flags: unchecked

[Files]
Source: "D:\corewallet_desktop\build\windows\runner\Debug\{#MyAppExeName}"; DestDir: "{app}"; Flags: ignoreversion
Source: "D:\corewallet_desktop\build\windows\runner\Debug\flutter_windows.dll"; DestDir: "{app}"; Flags: ignoreversion
Source: "D:\corewallet_desktop\build\windows\runner\Debug\msvcp140d.dll"; DestDir: "{app}"; Flags: ignoreversion
Source: "D:\corewallet_desktop\build\windows\runner\Debug\screen_retriever_plugin.dll"; DestDir: "{app}"; Flags: ignoreversion
Source: "D:\corewallet_desktop\build\windows\runner\Debug\ucrtbased.dll"; DestDir: "{app}"; Flags: ignoreversion
Source: "D:\corewallet_desktop\build\windows\runner\Debug\vcruntime140.dll"; DestDir: "{app}"; Flags: ignoreversion
Source: "D:\corewallet_desktop\build\windows\runner\Debug\vcruntime140_1d.dll"; DestDir: "{app}"; Flags: ignoreversion
Source: "D:\corewallet_desktop\build\windows\runner\Debug\vcruntime140d.dll"; DestDir: "{app}"; Flags: ignoreversion
Source: "D:\corewallet_desktop\build\windows\runner\Debug\window_manager_plugin.dll"; DestDir: "{app}"; Flags: ignoreversion
Source: "D:\corewallet_desktop\build\windows\runner\Debug\data\*"; DestDir: "{app}\data"; Flags: ignoreversion recursesubdirs createallsubdirs
; NOTE: Don't use "Flags: ignoreversion" on any shared system files

[Icons]
Name: "{autoprograms}\{#MyAppName}"; Filename: "{app}\{#MyAppExeName}"
Name: "{autodesktop}\{#MyAppName}"; Filename: "{app}\{#MyAppExeName}"; Tasks: desktopicon

[Run]
Filename: "{app}\{#MyAppExeName}"; Description: "{cm:LaunchProgram,{#StringChange(MyAppName, '&', '&&')}}"; Flags: nowait postinstall skipifsilent
