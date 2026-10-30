Option Explicit
' Read-only inspection. Collect-Vista.cmd captures this output in a local file.
Dim fs, sh, win, wmi, devices, dev, drivers, drv, name, p, v, key, driverKey
Dim os, systems, found, errText
Set fs = CreateObject("Scripting.FileSystemObject")
Set sh = CreateObject("WScript.Shell")
win = sh.ExpandEnvironmentStrings("%SystemRoot%")
WScript.Echo "Vista adapter installation report -- read-only"
WScript.Echo "Target: USB\VID_2357&PID_0116"
WScript.Echo "No installation or service/security change is performed."
On Error Resume Next
Set wmi = GetObject("winmgmts:{impersonationLevel=impersonate}!\\.\root\cimv2")
If Err.Number <> 0 Then
    WScript.Echo "WMI unavailable: " & Err.Description
    Err.Clear
Else
    Set systems = wmi.ExecQuery("SELECT Caption, Version, OSArchitecture, ServicePackMajorVersion FROM Win32_OperatingSystem")
    For Each os In systems
        WScript.Echo "OS: " & Txt(os.Caption) & "; " & Txt(os.Version) & "; " & Txt(os.OSArchitecture) & "; SP " & Txt(os.ServicePackMajorVersion)
    Next
    WScript.Echo vbCrLf & "=== Matching adapter and selected driver ==="
    found = 0
    Set devices = wmi.ExecQuery("SELECT Name, DeviceID, ConfigManagerErrorCode, Status FROM Win32_PnPEntity")
    For Each dev In devices
        If InStr(1, Txt(dev.DeviceID), "USB\VID_2357&PID_0116", vbTextCompare) = 1 Then
            found = found + 1
            WScript.Echo "Name: " & Txt(dev.Name)
            WScript.Echo "Device ID: " & Txt(dev.DeviceID)
            WScript.Echo "Device Manager code: " & Txt(dev.ConfigManagerErrorCode)
            WScript.Echo "Status: " & Txt(dev.Status)
            key = "HKLM\SYSTEM\CurrentControlSet\Enum\" & dev.DeviceID & "\"
            WScript.Echo "Bound service: " & ReadReg(key & "Service")
            driverKey = ReadReg(key & "Driver")
            WScript.Echo "Driver key: " & driverKey
            If Left(driverKey, 1) = "{" Then
                key = "HKLM\SYSTEM\CurrentControlSet\Control\Class\" & driverKey & "\"
                For Each name In Array("InfPath", "InfSection", "DriverVersion", "MatchingDeviceId", "ProviderName")
                    WScript.Echo name & ": " & ReadReg(key & name)
                Next
            End If
        End If
    Next
    If found = 0 Then WScript.Echo "Exact adapter was not found. Connect it and repeat."
    WScript.Echo vbCrLf & "=== Relevant registered drivers ==="
    Set drivers = wmi.ExecQuery("SELECT Name, State, PathName FROM Win32_SystemDriver WHERE Name='RtlWlanuVista' OR Name='RtlWlanu'")
    For Each drv In drivers
        WScript.Echo "Service: " & Txt(drv.Name) & "; state: " & Txt(drv.State)
        WScript.Echo "Path: " & Txt(drv.PathName)
    Next
End If
Err.Clear
WScript.Echo vbCrLf & "=== Installed file versions and sizes ==="
For Each name In Array("Wdf01000.sys", "WdfLdr.sys", "rtwlanu_vista.sys", "rtwlanu.sys")
    p = fs.BuildPath(win, "System32\drivers\" & name)
    If fs.FileExists(p) Then
        WScript.Echo name & ": version " & fs.GetFileVersion(p) & "; bytes " & fs.GetFile(p).Size
    Else
        WScript.Echo name & ": file absent"
    End If
Next
WScript.Echo vbCrLf & "=== Recent matching SetupAPI installation sections ==="
ShowSetupSections fs.BuildPath(win, "inf\setupapi.dev.log")
On Error GoTo 0
WScript.Echo vbCrLf & "End of report. No driver or Windows settings were changed."

Function Txt(value)
    If IsNull(value) Or IsEmpty(value) Then
        Txt = "(not reported)"
    Else
        Txt = CStr(value)
    End If
End Function

Function ReadReg(regPath)
    Dim value
    On Error Resume Next
    Err.Clear
    value = sh.RegRead(regPath)
    If Err.Number <> 0 Then
        ReadReg = "(not present or not readable)"
        Err.Clear
    Else
        ReadReg = Txt(value)
    End If
    On Error GoTo 0
End Function

Sub ShowSetupSections(logPath)
    Dim stream, probe, head, encoding, line, block, hit, older, middle, newest
    On Error Resume Next
    If Not fs.FileExists(logPath) Then
        WScript.Echo "SetupAPI.dev.log was not found."
        Exit Sub
    End If
    Err.Clear
    encoding = 0
    Set probe = fs.OpenTextFile(logPath, 1, False, 0)
    If Err.Number <> 0 Then
        WScript.Echo "Cannot read installation log: " & Err.Description
        Err.Clear
        Exit Sub
    End If
    head = probe.Read(2)
    probe.Close
    If Len(head) = 2 Then
        If Asc(Left(head, 1)) = 255 And Asc(Right(head, 1)) = 254 Then encoding = -1
    End If
    Set stream = fs.OpenTextFile(logPath, 1, False, encoding)
    block = ""
    hit = False
    older = ""
    middle = ""
    newest = ""
    Do Until stream.AtEndOfStream
        line = stream.ReadLine
        If Left(line, 3) = ">>>" And InStr(line, "[") > 0 Then
            If hit Then
                older = middle
                middle = newest
                newest = block
            End If
            block = ""
            hit = False
        End If
        If InStr(1, line, "VID_2357&PID_0116", vbTextCompare) > 0 Or InStr(1, line, "rtwlanu", vbTextCompare) > 0 Then hit = True
        block = block & line & vbCrLf
        If Len(block) > 262144 Then block = "[earlier lines truncated]" & vbCrLf & Right(block, 131072)
        If Err.Number <> 0 Then
            WScript.Echo "Installation log read error: " & Err.Description
            Err.Clear
            Exit Do
        End If
    Loop
    stream.Close
    If hit Then
        older = middle
        middle = newest
        newest = block
    End If
    If Len(newest) = 0 Then
        WScript.Echo "No matching installation section was found."
    Else
        If Len(older) > 0 Then WScript.Echo older
        If Len(middle) > 0 Then WScript.Echo middle
        WScript.Echo newest
    End If
    On Error GoTo 0
End Sub
