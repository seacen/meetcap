# MeetCap on Windows

What only Windows has: how to call `meetcap` without losing Chinese text or arguments, that nothing installs it yet, where to suggest keeping meetings, and what things on screen are called. The rest of this skill holds on Windows as written.

## Calling `meetcap`

Call it as `meetcap` in PowerShell, cmd or Git Bash, the way this skill writes it. What needs care is the shell between you and `meetcap`: Windows PowerShell 5.1 and cmd change text on its way in and out and lose or merge arguments, without an error. Chinese then comes back as `?` or garbled characters, `submit` rejects an answer, or a title, a name or a path lands wrong. `meetcap` itself reads and writes UTF-8 and takes each argument as it arrives, so the remedies are all on your side of the call.

### In PowerShell, set UTF-8 in every call

Begin every PowerShell call with this line:

```powershell
$OutputEncoding = [Console]::InputEncoding = [Console]::OutputEncoding = New-Object System.Text.UTF8Encoding $false;
```

Without it, Windows PowerShell 5.1 (the `powershell` that comes with Windows) reads what `meetcap` prints in the console's legacy code page as soon as it goes into a variable or through `ConvertFrom-Json`, and sends whatever you pipe into a command with each Chinese character as `?`. Each tool call starts a new PowerShell, so a setting from the previous call is gone. Claude Code's PowerShell tool uses UTF-8 already; since you often cannot tell which PowerShell you are in, set it there too.

### Hand text over in files

Let `meetcap` read and write the files itself — `prompt --out <file>`, `submit <meeting> <job> <file>`, `context <meeting> --set <file>` — rather than `>` or a pipe. Windows PowerShell 5.1 saves `>` and `Out-File` as UTF-16 and `Set-Content` in the legacy code page, and cmd pipes text in the console's code page; `meetcap` reads UTF-8 only.

- Write files with your own file tool. Without one, use `Set-Content -Encoding UTF8` in PowerShell: UTF-8 with a byte order mark, which `meetcap` accepts.
- Read MeetCap's files with your own file tool too. Windows PowerShell 5.1 reads a file in the legacy code page unless you write `Get-Content -Encoding UTF8`.

### Arguments

Chinese and spaces in an argument arrive intact. Three things do not:

- An empty argument (`''` or `""`) is dropped in Windows PowerShell 5.1, and the next one takes its place. To give an option no value, leave the option out.
- A path with a space that ends in `\` runs into the next argument, in Windows PowerShell 5.1 and in cmd. Write a folder without the `\` at the end.
- A straight double quote inside a value is lost in Windows PowerShell 5.1. Write the curly “ ” the text would have in print instead, or hand the text over in a file where the command takes one.

In PowerShell, put a value with a space, `$` or a backtick in single quotes, which it takes as written; inside double quotes it reads `$name` and the backtick as its own syntax. In cmd, use double quotes.

## Installing

Nothing installs MeetCap on Windows yet, so there is nothing for you or the user to run: when `meetcap --version` finds nothing, say so plainly.

## Setting up

- **Where to keep meetings**: suggest a MeetCap folder in Documents. Take the path of Documents from `[Environment]::GetFolderPath('MyDocuments')` in PowerShell rather than writing it out: on a company computer it may have been moved into OneDrive.

## Names on screen

| In this skill | On Windows |
|---|---|
| MeetCap's icon | in the system tray at the bottom right of the taskbar (「任务栏右下角」); a new icon starts out hidden, and the user clicks the ^ beside the tray icons to see it |
| the trash | the Recycle Bin (「回收站」) |
