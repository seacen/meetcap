# MeetCap on Windows

What only Windows has: how to call `meetcap` without losing Chinese text or arguments, how MeetCap is installed, what differs when setting it up, and what things on screen are called. The rest of this skill holds on Windows as written.

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

MeetCap for Windows comes from the Microsoft Store and nowhere else, so whether this computer can have it comes down to whether it reaches MeetCap in the Store. Find out first, with a check that installs nothing:

```powershell
winget show --id 9NVWHW0WJXNM --source msstore --accept-source-agreements --disable-interactivity
```

Its answer leaves one way to go. If the user has already asked you to install MeetCap, take it; if they have not (they only asked what MeetCap is, or you are the one who decided it should be installed), tell them which way it is and ask first.

- **It answers with MeetCap's details** (`Found MeetCap [...]`): install it from the Store, for this user, with no administrator and no window:

  ```powershell
  winget install --id 9NVWHW0WJXNM --source msstore --silent --accept-package-agreements --accept-source-agreements --disable-interactivity
  ```

  The `--accept-…` options agree to the Store's terms and MeetCap's for the user who asked; without them winget waits for a yes that nobody can type.
- **`winget` is not there, or it fails to reach the Store** (an error rather than an answer about MeetCap): install the package the Store signed for MeetCap, which the download page carries too. Download it with `curl.exe` (in Windows PowerShell 5.1 a bare `curl` is `Invoke-WebRequest`, many times slower on a file this size), then install it for this user; Windows checks the Store's signature, and no administrator is needed:

  ```powershell
  curl.exe -fL -o "$env:USERPROFILE\Downloads\MeetCap.msixbundle" https://github.com/seacen/meetcap/releases/latest/download/MeetCap.msixbundle
  Add-AppxPackage -Path "$env:USERPROFILE\Downloads\MeetCap.msixbundle"
  ```

  When GitHub cannot be reached, the same file is at https://meetcap.seacen.dev/download/latest/MeetCap.msixbundle.
- **The Store has no such package** (`No package found matching input criteria.`), **or the download is not there** (404): MeetCap is not in the Store yet, so nothing can install it on Windows yet. Say so plainly, give the download page, https://meetcap.seacen.dev/download, to check back later, and stop: there is no other way to install it.

Once it is installed, `meetcap` answers in every shell, one already open included.

## Setting up

- **Where to keep meetings**: suggest a MeetCap folder in Documents. Take the path of Documents from `[Environment]::GetFolderPath('MyDocuments')` in PowerShell rather than writing it out: on a company computer it may have been moved into OneDrive.
- **「在这台电脑上生成」** ("This computer", `local`): on Windows it writes no summaries during a meeting; the minutes come after it as usual. Say so when the user chooses it, and leave the running summary out when you show them around.

## Names on screen

| In this skill | On Windows |
|---|---|
| MeetCap's icon | in the system tray at the bottom right of the taskbar (「任务栏右下角」); a new icon starts out hidden, and the user clicks the ^ beside the tray icons to see it |
| the trash | the Recycle Bin (「回收站」) |
