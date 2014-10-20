Set ws = CreateObject("Wscript.Shell")
For i = 1 to 10
	ws.run "cmd /c test_ws.bat"
Next