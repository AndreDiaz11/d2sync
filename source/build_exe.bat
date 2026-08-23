@echo off
"C:\Windows\Microsoft.NET\Framework64\v4.0.30319\csc.exe" /target:winexe "/out:E:\DESCARGAS\PROYECTOS VS\_.D2Sync\D2Sync_v1.1.0.exe" "/win32icon:E:\DESCARGAS\PROYECTOS VS\_.D2Sync\source\launcher\app_icon.ico" /reference:System.IO.Compression.dll /reference:System.IO.Compression.FileSystem.dll /reference:System.Windows.Forms.dll "/resource:E:\DESCARGAS\PROYECTOS VS\_.D2Sync\source\app_new.zip,app.zip" "E:\DESCARGAS\PROYECTOS VS\_.D2Sync\source\launcher\PortableLauncher.cs"
echo DONE %ERRORLEVEL%
