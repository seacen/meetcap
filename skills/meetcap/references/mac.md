# MeetCap on a Mac

What only a Mac has: how MeetCap is installed, where to suggest keeping meetings, what macOS asks, and what things on screen are called. The rest of this skill holds on a Mac as written.

## Installing

Install by command — it is quicker for the user and you can do it for them. If the user has already asked you to install MeetCap, say in one sentence what the script does and that it is public at https://github.com/seacen/meetcap/blob/main/install.sh, then run it. If they have not (they only asked what MeetCap is, or you are the one who decided it should be installed), say the same and ask first; run it only after they say yes:

```bash
curl -fsSL https://meetcap.seacen.dev/install.sh | bash
```

It puts MeetCap in the Applications folder, links the `meetcap` command into `~/.local/bin`, and adds this skill to the agents installed on this Mac. If MeetCap is open, it asks for it to be quit first. If `~/.local/bin` is not on the user's PATH, it adds a line for it to `~/.zshenv` (`~/.bash_profile` for bash), so a new terminal window, and a shell you start, finds `meetcap`; for any other shell it prints the line to add. A shell that was already open does not see the change: run `~/.local/bin/meetcap` by its full path there. Running it again updates MeetCap and the skill.

Without a terminal, the user can download `MeetCap.dmg` (`MeetCap-Intel.dmg` on an Intel Mac) from https://meetcap.seacen.dev/download and drag MeetCap to Applications. The first time MeetCap is opened, it adds the `meetcap` command and this skill itself, as the script does.

## Setting up

- **Where to keep meetings**: suggest a MeetCap folder in Obsidian's iCloud folder if this Mac has one, otherwise in iCloud Drive, otherwise in Documents.
- **The library's folder**: when `library.asks` is true, macOS asks in the name of the app you run commands in, not MeetCap's; the user clicks Allow.
- **Recording**: `permissions ask` puts macOS's questions for the microphone and for system audio on screen, and the user answers both.
- **The folders an agent MeetCap starts may read**: the user's Documents and cloud drives; macOS asks once for each, in MeetCap's name.

## Names on screen

| In this skill | On a Mac |
|---|---|
| MeetCap's icon | in the menu bar at the top right of the screen (「屏幕右上角的菜单栏」) |
| the trash | the Trash (「废纸篓」) |
