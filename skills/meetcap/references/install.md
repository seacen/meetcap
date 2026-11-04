# Installing MeetCap

Check first with `meetcap --version`. What exists depends on the platform:

| Platform | What there is |
|---|---|
| Mac with Apple silicon or Intel, macOS 14.2 or later | Menu bar app plus the `meetcap` command line. |
| Windows | Tray app plus the `meetcap` command line. There is no installer for it yet. |
| iPhone | App only. There is no command line, so an agent cannot drive it; point the user to the app. |

How to install it here is under Installing in this computer's platform file ([mac.md](mac.md) or [windows.md](windows.md)). Then comes the first setup, in the app or by command: read "First setup" in [setup.md](setup.md).

## Showing the user around

After installing, tell them in a few sentences:

- Where MeetCap's icon is, in the words of the platform file. Before a meeting, click it and press Start (a title is optional).
- During the meeting, clicking the icon shows live captions and a running summary; click a speaker number to name them.
- After the meeting the minutes and transcript appear on their own, in the meeting window and in the meeting folder.

They never need a terminal for any of this; you are only needed when they would rather ask you.

## Updating

When the user asks whether there is a newer MeetCap, run `meetcap update check`: it only looks, downloads nothing, and its last line says which version they have and, when there is a newer one, where to get it. When they want it, install it again the way the platform file says. If the check cannot reach the download sites, say so and leave it; MeetCap checks again on its own.

## Uninstalling

When the user wants MeetCap gone, run `meetcap uninstall` first: it changes nothing and lists what would go. Pass that on, and say plainly that the recordings on this computer go to the trash with MeetCap's data, while the meeting library stays. Run `meetcap uninstall --confirm` only after they agree, then relay its last lines: where the library is, and how to remove the app itself. If it refuses because the app is open or a meeting is still recording or being processed, tell them and leave it; quitting the app or stopping a meeting is their call.
