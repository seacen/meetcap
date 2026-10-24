# Installing MeetCap

Check first with `meetcap --version`. What exists depends on the platform:

| Platform | What there is |
|---|---|
| Mac with Apple silicon or Intel, macOS 14.2 or later | Menu bar app plus the `meetcap` command line. |
| Windows | Not available yet. Say so plainly; there is nothing to install. |
| iPhone | App only. There is no command line, so an agent cannot drive it; point the user to the app. |

## Mac

Install by command — it is quicker for the user and you can do it for them. If the user has already asked you to install MeetCap, say in one sentence what the script does and that it is public at https://github.com/seacen/meetcap/blob/main/install.sh, then run it. If they have not (they only asked what MeetCap is, or you are the one who decided it should be installed), say the same and ask first; run it only after they say yes:

```bash
curl -fsSL https://meetcap.seacen.dev/install.sh | bash
```

It puts MeetCap in the Applications folder, links the `meetcap` command into `~/.local/bin`, and adds this skill to the agents installed on this Mac. If MeetCap is open, it asks for it to be quit first. If `~/.local/bin` is not on the user's PATH, it adds a line for it to `~/.zshenv` (`~/.bash_profile` for bash), so a new terminal window, and a shell you start, finds `meetcap`; for any other shell it prints the line to add. A shell that was already open does not see the change: run `~/.local/bin/meetcap` by its full path there. Running it again updates MeetCap and the skill.

Without a terminal, the user can download `MeetCap.dmg` (`MeetCap-Intel.dmg` on an Intel Mac) from https://meetcap.seacen.dev/download and drag MeetCap to Applications. The first time MeetCap is opened, it adds the `meetcap` command and this skill itself, as the script does.

Then comes the first setup, in the app or by command: read "First setup" in [setup.md](setup.md).

## Showing the user around

After installing, tell them in a few sentences:

- The MeetCap icon is in the menu bar. Before a meeting, click it and press Start (a title is optional).
- During the meeting the same menu shows live captions and a running summary; click a speaker number to name them.
- After the meeting the minutes and transcript appear on their own, in the meeting window and in the meeting folder.

They never need a terminal for any of this; you are only needed when they would rather ask you.

## Updating

When the user asks whether there is a newer MeetCap, run `meetcap update check`: it only looks, downloads nothing, and its last line says which version they have and, when there is a newer one, where to get it. When they want it, run the install command above again; it updates MeetCap and this skill. If the check cannot reach the download sites, say so and leave it; MeetCap checks again on its own.

## Uninstalling

When the user wants MeetCap gone, run `meetcap uninstall` first: it changes nothing and lists what would go. Pass that on, and say plainly that the recordings on this computer go to the Trash with MeetCap's data, while the meeting library stays. Run `meetcap uninstall --confirm` only after they agree, then relay its last lines: where the library is, and dragging MeetCap to the Trash. If it refuses because the app is open or a meeting is still recording or being processed, tell them and leave it; quitting the app or stopping a meeting is their call.
