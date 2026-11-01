# Summaries, minutes, translations, names

The model work on a meeting is four jobs:

| Job | What it is | When you do it |
|---|---|---|
| `summary` | A few lines on the stretch since the last summary, with background on what was said there that a listener may not know, while the meeting is on | Every few minutes while it records ([recording.md](recording.md)), and whenever the user asks ("总结一下") |
| `minutes` | The minutes; the corrections of misheard names and terms come with them | After the meeting stops, when `pending` lists it, or when the user asks |
| `translate` | The minutes in the other language | When `pending` lists it, or when the user asks for the minutes in the other language |
| `names` | Who the speakers without a name may be, guessed from what was said | When `pending` lists it, after the meeting and before the minutes |

When MeetCap is set to leave the work to you, `meetcap minutes <meeting>` or `meetcap summarize <meeting>` only puts the job in `pending`; do it as below.

To redo minutes the user is not happy with, run `meetcap minutes <meeting>` again: when the work is left to you it queues the job and you do it as below; otherwise MeetCap writes them itself. Either way the old minutes stay until the new ones pass `submit`, and minutes in the other language are translated again from the new ones (a `translate` in `pending` when the work is yours).

## How to do one job

Every job is the same four steps:

1. `meetcap prompt <meeting> <job> --out <file> --json` — add `--lang zh|en` for minutes or a translation in a given language. The file is the complete task: what to write, the rules, the transcript and the context. It is the same text MeetCap sends to a model when it does the job itself. The answer's `task` is the job in the file: once the meeting has minutes, minutes asked for in the other language are a translation of them. For `summary`, the answer carries the stretch as `range`; if it says `empty`, nobody spoke since the last summary and there is nothing to do.
2. Read the whole file and do what it says. A two-hour meeting is about 30,000 characters; if your tools read files in parts, read every part — minutes written from half a transcript are wrong. The task says what you may look up with your tools — for a summary's background, the web and earlier meetings too — and what a search may carry; look, but change nothing. A summary has to be in before the next one is due, so its lookups are a few quick ones.
3. Write your answer, and only your answer, to a file: the one JSON object the task asks for.
4. `meetcap submit <meeting> <job> <file>` with the same `--lang`, and for `summary` the `--range` from step 1. Nothing is written until the answer passes, with one exception: in a `minutes` answer's `context` or `glossary`, or a `summary` answer's `context` or `background`, a field of the `context` or an entry of the others that fails is left out on its own and the rest is saved; `submit --json` then lists each under `dropped`. A `minutes` answer's `echoes` takes only lines the task marks `echo?`; any other id in it is left out on its own. The minutes need nothing more. A `glossary` entry with no misheard form in `aliases` is dropped on purpose: the recognition already writes that word right, so leave it out. If another dropped entry matters, add it with `meetcap glossary add <spelling> --alias <how it was misheard>`.

A `names` answer is a set of guesses, not names: nothing shows them until someone confirms. After submitting it, `meetcap status <meeting> --json` lists them under `guesses`. Show the user each one with the lines it rests on (`refs`) and ask; `meetcap label <meeting> <speaker> "<name>"` only for the ones the user confirms.

If `submit` exits 2, its `which` points at the first thing it rejected. Fix that and submit again. For `minutes`, if the corrections keep failing, submit `"corrections": []` — the minutes matter more than the corrections.

`<meeting>` is the meeting's folder name or its path. Do not write `minutes.*.json`, `summaries.jsonl`, `transcript.jsonl` or `context.json` yourself: `submit` checks every sentence id and speaker before anything lands, and a file written around it does not count.

## Showing minutes to someone

In anything the user reads — chat, a summary you report, an email draft — write an unnamed speaker as MeetCap shows them ("Speaker 2"; "说话人 2" in a Chinese library) and ask who it is; `S2` and `{S2}` are for programs. Do not use a name you only heard in the conversation — someone saying "Mr Sha" is not proof of who `S1` is, and a wrong name in minutes sent to the whole meeting is worse than a number. Once the user tells you, `meetcap label` puts the name everywhere ([meetings.md](meetings.md)).
