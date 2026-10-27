# Setup, health, disk space

## First setup

A computer without a meeting library needs a first setup: the language, the user's agreement to the Terms of Use, where to keep meetings, how summaries and minutes are made, the speech recognition download and the permissions to record.

Ask the user whether they will do it in the app or want you to do it by command. In the app, the first time MeetCap opens, a window asks for these in turn. Its first screen has an "Agree and continue" button (「同意并继续」) on a computer that has not agreed to the terms; a MeetCap account is not available yet, so the user chooses "Set it up yourself" (「自己配置」). Downloads continue in the background, and the menu bar icon shows their progress. By command:

1. Ask for what the user has not told you: the language; where to keep meetings (suggest a MeetCap folder in Obsidian's iCloud folder if this Mac has one, otherwise in iCloud Drive, otherwise in Documents); how summaries and minutes are made (see below).
2. Run `meetcap setup --library <folder> --lang zh|en --mode <mode>`. On a Mac, first run `meetcap permissions --library <folder> --json`: when `library.asks` is true (the folder is in Documents, Desktop, Downloads, iCloud Drive, another cloud drive or on an external disk), macOS asks the first time the folder is read, in the name of the app you run commands in, and `setup` waits for that answer — so tell the user a question is coming and to click Allow. On a computer that has not agreed to MeetCap's Terms of Use, `meetcap setup` stops with `terms_not_accepted` and sets nothing. Tell the user that MeetCap needs them to read and agree to its Terms of Use and Privacy Notice, give both links in their language, and add `--accept-terms` only after they say yes themselves: it records their agreement, and you cannot agree on their behalf. In Chinese the links are https://meetcap.seacen.dev/zh-cn/terms/ and https://meetcap.seacen.dev/zh-cn/privacy/; in English, https://meetcap.seacen.dev/terms/ and https://meetcap.seacen.dev/privacy/. One agreement covers the app and the command line on this computer. The next steps wait until `meetcap setup` succeeds.
3. Run `meetcap models get` to download speech recognition, and with `--mode local` also `meetcap models get --local`. The user can record before the downloads finish; MeetCap transcribes the recording when speech recognition is ready.
4. Run `meetcap permissions ask`. macOS asks for the microphone and for system audio, and the user answers.

Either way, finish with `meetcap doctor` and relay its `fix`. After a first setup by command, the app opens without the first-run window.

## Read the settings

`meetcap config` lists the settings in plain words, each with how to change it; `meetcap config get <key> --json` reads one, such as `summary_interval_min` (minutes between summaries) or `intelligence.mode` (how summaries and minutes are made), and `meetcap config --json` gives them all with where each comes from. Change the tags, the summary interval, minutes in both languages and how long recordings are kept with `meetcap config set <key> <value>`; the library, its language and how minutes are made with `meetcap setup`. Never edit the files.

To move the library to another folder, run `meetcap setup --move-library <new folder>`: it says what it would do, and `--confirm` does it. A move takes only the library's own files — the meetings, its settings, the voices it knows and the glossary. Anything else in that folder, such as the notes of an Obsidian vault, stays where it is, and so do the recordings, which are kept on this computer. When that folder is already a meeting library, or there is no library here to move, nothing moves: MeetCap uses that folder as its library from then on, and the meetings of the current library stay where they are. Tell the user which of the two it would do before they agree.

## How summaries and minutes are made

`meetcap setup` sets it; `meetcap setup --help` lists the ways and says which are not open yet. Offer the person only the ways they can pick now, under the names MeetCap's screens give them, word for word, below the question 「小结和纪要怎么生成」 ("Write summaries and minutes with"). The `--mode` value is for the command; the person has never seen it, so leave it out of what you tell them.

- 「自己的 API 密钥」 ("Your own API key"): `byok`.
- 「由 MeetCap 启动的智能体」 ("Your agent, run by MeetCap"): `harness`, an agent on this computer that MeetCap starts by itself whenever there is work, with nobody in the conversation. Name it with `--agent` and, if the user chose them, `--model` and `--effort`. On a Mac the agent may read the user's Documents and cloud drives, and macOS asks once for each in MeetCap's name; until those questions are answered, `meetcap agents` lists names only (`folders_answered: false`) and starts no agent. Tell the user before you run `meetcap permissions ask --folders`, `setup --mode harness` or `agents --try`, which ask them first; refusing does not stop the minutes. `meetcap agents --fresh` lists the ones found here, with the models and effort levels each offers now. One listed with `needs_login: true` cannot work until the person signs in to it: `meetcap agents --login <id>` opens its sign-in page in their browser and waits until they finish there, so tell them before you run it. When none is listed, most people have only a desktop app and have never used a terminal, so point them to the install page rather than explaining commands yourself: it says, app by app, what works as is, what needs that one sign-in, and what to install — https://meetcap.seacen.dev/docs/how-to/install-an-agent/ (Chinese: https://meetcap.seacen.dev/zh-cn/docs/how-to/install-an-agent/).
- 「与智能体对话」 ("Your agent, when you ask it"): `skill`, the agent the user is talking to — you — doing the jobs ([jobs.md](jobs.md)).
- 「在这台电脑上生成」 ("This computer"): `local`, a model that runs on this computer, so the text never leaves it. It needs the local model, about 5 GB, which `meetcap models get --local` downloads; until it is here, summaries and minutes wait for it.

MeetCap's own service (「MeetCap 账号」, `hosted`) is not open yet, and `setup --mode hosted` is refused: do not offer it. If the person asks for it, say it is not open yet (「暂未开放」) and offer these four. A user who wants an agent on this computer to write the minutes on its own wants `harness`, even when that agent is you.

Sending the meeting's text to a service needs the user's consent. Ask them and pass their answer on; never agree on their behalf.

## Recording on a schedule

`meetcap schedule add <when>` — read `meetcap schedule add --help` for the format first; add it only after the user agrees. `meetcap schedule list` shows the ones on this computer, `meetcap schedule remove <id>` takes one away, `meetcap schedule off` all of them. When `add` or `list` gives `background.why: denied`, the schedules will not start until the user turns MeetCap on in Login Items: relay the sentence it prints.

## Something seems wrong

`meetcap doctor` checks permissions, models, the meeting folder and disk space, and says how to fix what is off. Relay its `fix`. It also clears recordings older than the retention the user chose — that is expected. `meetcap permissions` reads the permissions alone, without asking for them; `meetcap models get` downloads models that are missing.

A permission macOS refused comes with `next`, the step to give the user, and the `fix` or sentence says it: `ask_again` — `meetcap permissions ask --again mic|system|library|folders` makes macOS ask again; `open_settings` — the switch in System Settings; `full_disk_access` — `meetcap permissions ask --full-disk-access` puts MeetCap in that list, then the user turns it on; `ask_it` — MeetCap has done what it can, and the user asks their IT or picks another folder for the library. Run `--again` or `--full-disk-access` only when the user asks for it: they change MeetCap's own records, and the user answers what macOS asks. `library_no_access` from a command you ran is about the app you run commands in, not MeetCap: relay its `fix`, which says where to turn that app on.

## Report a problem to MeetCap's developers

When something is wrong that `doctor` does not fix, or the user wants to tell the developers about it, `meetcap feedback --message <the user's words>` (or `--message -` to read them from standard input) sends what the user wrote, with their contact if they give one (`--contact`) and a diagnostics package: activity logs, check results, versions and settings, never recordings, transcripts, minutes, titles or names. Without `--confirm` it sends nothing and lists what would go; show the user that, and run it with `--confirm` only when they say to send it. That is the only way anything of theirs leaves the computer for the developers, so the decision is theirs every time, and it is not retried behind their back. `--no-diagnostics` sends the words alone. It answers with an id; the user quotes it to have the report deleted. When it cannot reach the server it saves the report as a file and says where: pass on that path and the website's feedback page, so they can email it.

`meetcap diagnose` lists what a diagnostics package holds; `--confirm` saves one for the user to send themselves.

## Free up disk space

`meetcap audio clear` removes recordings; transcripts and minutes stay. `meetcap models remove --local` says how much deleting the local model would free, and `--confirm` deletes it; it refuses while the library is set to `local`. `meetcap audio gc` moves to the Trash what meetings left behind on this computer: the recordings of meetings deleted on another device or by hand, and pieces of a recording that broke off and could not be repaired.
