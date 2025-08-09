Set objShell = CreateObject("Wscript.Shell")
objShell.Run "powershell -NoProfile -ExecutionPolicy Bypass -File """ & WScript.ScriptFullName & "\..\scripts\LinkUp.ps1""", 0, False