# Which meeting, its folder, names, sharing

## Which meeting the user means

Every command needs the meeting, and a wrong guess puts minutes or names on someone else's meeting. `meetcap status --all` lists every meeting with its title and start time, newest first.

- **Named** — a title (often copied from the app with its 『』 or quote marks, which are not part of the title), a date, "yesterday afternoon's": match it against that list.
- **Not named** ("this meeting", "the minutes"): the newest one. If it is still recording or wrapping up, say so and wait for it to finish.
- **More than one fits** (the same title on different days, two meetings that afternoon): list them with date and time and ask which. Do not pick one.


## What a meeting folder holds

`meetcap start`, `transcribe` and `status --json` give the folder's `path`; every command accepts that path as well as the folder name (a path brings its own library, so no `--library` is needed).

- `meeting.md` — the note a person reads, and where to point the user for the minutes: the whole minutes, or the running summaries until there are minutes; it stays current when names or minutes change. `meeting.<lang>.md` is the same note in the other language, when there are minutes in it. Whether there are minutes yet, and in which languages, is `minutes` in `meetcap status <meeting> --json`; `meetcap minutes` writes them again over what is there, so do not run it to find out.
- `transcript.md` — the full transcript for people.
- `summaries.md` — the summaries written during the meeting, each with its background; it stays after the minutes are written, when `meeting.md` no longer lists them. Only a meeting that had summaries has it.
- `.meetcap/` — everything else, hidden so the user sees only the notes. `.meetcap/transcript.jsonl` is the transcript for programs: one sentence per line with an `id` (like `u000123`), times, a speaker number (`S1`…) and the text; read it when you need exact times or ids. The rest — what processing is waiting for, speakers, minutes and context as data — you reach through `meetcap status`, `label`, `prompt` and `context`, not by reading the files.

## Rename or delete a meeting

`meetcap rename <meeting> "<title>"` changes the title the notes and the app show; the folder keeps its name. `meetcap delete <meeting>` moves the meeting and its recordings to the Trash.

## Name a speaker

`meetcap label <meeting> S2 "<name>"` — an unnamed speaker appears as "Speaker 2" ("说话人 2" in a Chinese library) in the transcript and minutes, and S2 is the number to give. The name replaces it there, and MeetCap recognises that voice in later meetings. Name only people the user identified. When `label` says it has remembered a voice, it also says where the voice is kept, how to delete it and that the person should know: pass that on to the user in your own words, leaving none of the three out.

`meetcap people list` lists the people MeetCap knows by voice; `meetcap people forget "<name>"` stops it recognising one, and the names already in past meetings stay. `meetcap people rename "<name>" "<new name>"` changes what a person is called, in the library and in every meeting; renamed to someone MeetCap already knows, the two become one person, which cannot be undone.

## Find what was said

In a meeting you already know, read `transcript.md`, or `.meetcap/transcript.jsonl` when you need exact times or sentence ids.

When the user does not say which meeting ("what did we decide about …?", "who said …, and when?"), search the library:

1. `meetcap status --all --json` lists every meeting with its title, start time and folder (`path`).
2. Search the meetings' `meeting.md` first: the minutes hold what was decided and who does what. Then search `transcript.md` for the exact words, and for what the minutes left out.
3. Nothing found? The transcript has the words as spoken and heard, not the user's: search again with other wordings — a synonym, the other language, a shorter key word.
4. Answer with the meeting's title and day (the local day: `started_at` is in UTC), so the user can open it; when the subject came up in more than one meeting, say what each said.

In a library on iCloud Drive, older files may be kept only in the cloud: reading one downloads it first, which can be slow. Search the minutes before the transcripts for that reason too.

## Hand a meeting to someone

`meetcap export <meeting> --to docx|pdf|md|vtt` makes a one-off copy for someone else: Word or PDF to send, `md` a folder with the notes, `vtt` subtitles for a video. `--lang zh|en` picks which minutes go into Word or PDF. It writes into the current directory unless `--out` says where, and your current directory is often a scratch folder the user never sees or that gets cleared, so give `--out` a folder the user can find: the one they named, otherwise their Downloads folder. It replies with the `path`; tell the user where the file is; Word or PDF of a meeting with summaries also writes them to a second file beside it, and `files` lists both. Export only when the user wants to send or share a meeting: the copy does not follow later changes, and reading the minutes needs only `meeting.md`.
