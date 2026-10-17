# What is known about a meeting

Two things tell MeetCap what it cannot hear. Both help the summaries and the minutes, the correction of names and terms among them. The glossary also steers the speech recognition, which favours its spellings; the meeting's context does not.

| | The meeting's context | The glossary |
|---|---|---|
| What | This meeting's working notes: who is in the room, the agenda, terms likely to come up, what was decided last time | The library's dictionary of names and terms, kept across meetings |
| Read and write | `meetcap context <meeting>` shows it; `meetcap context <meeting> --set -` replaces it with the JSON you pipe in | `meetcap glossary` lists it; `meetcap glossary add "<spelling>" --alias "<misheard 1>,<misheard 2>" --note "<note>"` adds a term; `meetcap glossary remove "<spelling>"` removes one; to change one, edit the table in `glossary.md` at the top of the library — MeetCap keeps that file as people write it |
| When | Right after `start` or `transcribe`, with what you actually found | As soon as you know a name or term a meeting will use, or the user teaches you one: before `transcribe`, and before a meeting ends at the latest, since its final transcript is recognised after it. The minutes add the terms each meeting settled by themselves |

## The context

Every field is optional; the title is set with `meetcap start --title`, not here.

```json
{
  "attendees": ["Alex Chen (product lead)", "Sam Li"],
  "agenda": "Q4 launch plan: channels, budget, dates",
  "terms": [{"spelling": "Aurora", "aliases": ["a roller"], "note": "the product being launched"}],
  "previous": "Last week: launch moved to 12 Nov; Sam Li to confirm the budget.",
  "notes": "External guest from the agency joins for the first half."
}
```

Each summary and the minutes may add what they found; nothing already there is overwritten.

## Where to get it

Use the connectors, skills and tools you have in this conversation — calendar, mail, documents, chat, a people directory, a knowledge base, files on this computer — before a meeting or once its transcript is there, to get names, terms and background right. Look until you understand what the meeting is mainly about, not until every word is explained: some words in a transcript were misheard, and no search will find them. Two or three rounds of lookups are usually enough; stop when a round turns up nothing new, and leave a word you cannot place after one try. What you cannot reach, leave out; the minutes are still complete, just with less background.

| For | Look in |
|---|---|
| Attendees and agenda | the calendar invitation; a people directory for full names and roles; otherwise ask the user, or use how they described the meeting |
| Terms and background | mail, documents and chats found by the meeting's title and attendees; the glossary |
| Earlier meetings | the minutes of the last meeting in the same series — in this MeetCap library (a meeting folder with a similar title) or wherever the user keeps them (e.g. Microsoft 365, a knowledge base) — and documents shared for it |
| Real names of speakers | the meeting platform's own transcript with names (e.g. a Teams transcript): save it as `.meetcap/transcript.teams.jsonl` in the meeting folder, match its speakers to MeetCap's numbers by time, and `meetcap label` each one you are sure of, passing on what `label` says about a remembered voice ([meetings.md](meetings.md), Name a speaker) |
