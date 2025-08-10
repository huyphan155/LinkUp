Set WshShell = CreateObject("WScript.Shell")
Set fso = CreateObject("Scripting.FileSystemObject")

' Get the folder of this script
ScriptDir = fso.GetParentFolderName(WScript.ScriptFullName)

' Project root = 3 levels up from script location
ProjectRoot = fso.GetParentFolderName( _
                 fso.GetParentFolderName( _
                     fso.GetParentFolderName(ScriptDir) _
                 ) _
              )

' Get Desktop path
DesktopPath = WshShell.SpecialFolders("Desktop")

' Create shortcut
Set Shortcut = WshShell.CreateShortcut(DesktopPath & "\LinkUp.lnk")

' Target: LinkUp.vbs in project root
Shortcut.TargetPath = ProjectRoot & "\LinkUp.vbs"

' Working directory: project root
Shortcut.WorkingDirectory = ProjectRoot

' Icon: blue.ico in current script folder
Shortcut.IconLocation = ScriptDir & "\blue.ico"

' Save shortcut
Shortcut.Save