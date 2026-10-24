# Recording and transcribing

## Record a meeting that is starting now

Before you start, read the two permissions with `meetcap permissions --json` (it never shows a prompt). If either says `not_asked`, run `meetcap permissions ask` before anything else: the system asks once for the microphone and once for the computer's sound, and a recording started before both are answered records nothing on the unanswered side. Tell the user to answer both prompts, and wait until the command returns.

`meetcap start --title "<title>"` — add `--until +90m` if the user said how long. It returns the meeting's `path`. Then:

- tell the user it is recording, from the microphone and the computer's sound (`meetcap status` says which), and where the meeting folder is;
- if they want the room left out — an open office, a call they only listen to — `meetcap start --source system` records the computer's sound alone, and `meetcap mic off` / `meetcap mic on` turns MeetCap's microphone off and on during the meeting. Only MeetCap stops listening: their meeting app keeps the microphone and the other side still hears them;
- a user who wants to watch the meeting in their own terminal can run `meetcap start --follow` instead: it prints each sentence as it settles and each summary, and returns only when the meeting ends (Ctrl-C stops the watching, not the recording). Do not run it yourself — it does not return;
- write what you know about the meeting straight away ([context.md](context.md)).

### Summaries while it records

Run `meetcap config get intelligence.mode --json`. Unless it says `skill`, MeetCap writes the summaries itself. In `skill` mode only you write them and nothing reminds you, so set them up before you reply; it is part of starting the recording:

1. Read the interval: `meetcap config get summary_interval_min --json`.
2. Schedule a recurring task at that interval with your own scheduler, whatever it is called where you run: scheduled task, automation, heartbeat, cron, loop, wake-up. Look through all your tools, including ones you must search for or load first, before you decide you have none. Each run: `meetcap status <meeting> --json`; while it records, do the `summary` job ([jobs.md](jobs.md)); once it has stopped, cancel the task and do what `pending` lists.
3. Tell the user it is set up and how often.

With no scheduler at all, keep them coming without ending your turn, since nothing of yours runs once it ends: tell the user so, how often, and that interrupting you stops the summaries, not the recording; then wait the full interval (`sleep 300` for 5 minutes), do one run as above, and repeat until the meeting stops.

Stop when the user says they do not want summaries. While it records, MeetCap also keeps one summary waiting in `pending`: when you see it, do it — it covers everything since the last summary.

## A meeting that starts later

Do not start now: `start` records from the moment you run it. If it recurs (a weekly meeting), offer `meetcap schedule add <when>` (read `meetcap schedule add --help` for the format first, and add it only after the user agrees). Otherwise ask them to tell you, or press Start in the menu bar, when it begins.

## Pause and resume

When the user wants a stretch left out ("暂停一下", "先别录"), run `meetcap pause`; when they want to carry on ("接着录"), `meetcap resume`. A pause keeps it one meeting: nothing is recorded or transcribed until it resumes, and the minutes still come after `stop`, which ends a paused meeting as any other. Resume only when the user says so, and do not stop a meeting they only asked to pause.

## Stop

`meetcap stop --wait` — waits until the recording is processed. Its answer lists what waits for you under `pending`: do it ([jobs.md](jobs.md)), then report back.

## Transcribe a file the user already has

`meetcap transcribe <file>` — works like a recording that has just stopped: write the context, then do what `pending` lists and report back. If the user changes their mind while it runs, `meetcap stop <meeting> --discard` stops it and moves that meeting to the Trash; their file is not touched.

If that file sits in a cloud drive, it may later be kept only in the cloud: `status --json` then gives the meeting `audio_where: "cloud"`. When the user wants that recording on this computer again, `meetcap audio fetch <meeting>` downloads it; it stops if nothing arrives for two minutes.

## Check progress

`meetcap status` for the meeting now recording, `meetcap status --all` for every meeting. Relay what it says; do not stop a meeting because it seems to be over.
`meetcap status --follow` shows a meeting sentence by sentence in the terminal — the one recording, until it ends, or all of an ended one (`--summaries` for the summaries alone). It is for the user to run; it does not return while the meeting goes on.

## A recording that broke off

When the recording stopped unexpectedly and the transcript covers only part of it, `meetcap retranscribe <meeting>` transcribes the whole recording again and returns when it is done. It needs the meeting ended and its recording on this computer. Afterwards a meeting with no minutes gets them the way the library is set to; minutes already written stay. Meetings recorded before the speech models were downloaded do not need it: they are filled in once the models are there.

## Report back after a meeting

In the user's language: the path of the note (`meeting.md` in the folder `status --json` gives as `path`), how many next steps there are, and how many speakers still have only a number — and offer to name them ([meetings.md](meetings.md)).
