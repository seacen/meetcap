#!/bin/bash
# Install MeetCap on this Mac:
#
#     curl -fsSL https://meetcap.seacen.dev/install.sh | bash
#
# It downloads the latest release's disk image for this Mac — MeetCap.dmg on
# Apple silicon, MeetCap-Intel.dmg on an Intel Mac (decisions 10-14) — puts
# MeetCap.app in Applications, and has
# the app's own `meetcap` put itself in place (`meetcap _place`, the same the
# app does at every launch): one link to it in ~/.local/bin, and the MeetCap
# skill for each agent installed on this Mac (meetcap/src/place.rs says where
# and why). Running it again first reads the release's VERSION: when MeetCap
# here is already that version, or a newer one, nothing is downloaded or
# replaced, unless that MeetCap is the other kind of Mac's build. Otherwise
# it replaces the app with the latest release; on a Mac
# where MeetCap was already there and set up, it then says which version it
# updated to. Only a Mac that is not set up is told how to finish setting up.
# Either way `_place` replaces the link and every copy of the skill.
#
# Two download points hold the same files (scripts/publish.sh puts them
# there; decisions 10-12): GitHub's latest release first, then the copy on
# meetcap.seacen.dev. VERSION and SHA256SUMS are read from the first that
# answers. The disk image comes from GitHub unless GitHub is too slow: under
# START_RATE in its first START_SECONDS, or under STALL_RATE for STALL_SECONDS
# at any point (curl's own --speed-limit), and then from the second point,
# on from the bytes already here when its SHA256SUMS gives the disk image the
# same sum. The disk image is checked against SHA256SUMS before it is opened,
# and the app on it is checked to be ours before it is copied (`ours`, below).
#
# Overridable, for testing and for a release that is not the latest:
#   MEETCAP_RELEASE_URL   the first point (default: GitHub's latest release)
#   MEETCAP_MIRROR_URL    the second (default: meetcap.seacen.dev's latest)
#   MEETCAP_APPLICATIONS  the folder the app goes into (default: /Applications,
#                         or ~/Applications when that cannot be written)
#   MEETCAP_START_SECONDS, MEETCAP_START_RATE, MEETCAP_STALL_SECONDS,
#   MEETCAP_STALL_RATE    when to leave the first point (default 5 s under
#                         50 KB/s at the start, 20 s under 50 KB/s mid-way;
#                         rates in bytes a second, seconds whole)
#
# macOS's own bash is 3.2: no associative arrays here.
set -euo pipefail

RELEASE_URL="${MEETCAP_RELEASE_URL:-https://github.com/seacen/meetcap/releases/latest/download}"
MIRROR_URL="${MEETCAP_MIRROR_URL:-https://meetcap.seacen.dev/download/latest}"
START_SECONDS="${MEETCAP_START_SECONDS:-5}"
START_RATE="${MEETCAP_START_RATE:-50000}"
STALL_SECONDS="${MEETCAP_STALL_SECONDS:-20}"
STALL_RATE="${MEETCAP_STALL_RATE:-50000}"

# The language MeetCap's command line speaks before there is a library
# (meetcap/src/strings/mod.rs `system_with`): LC_ALL, LC_MESSAGES, LANG, then the
# first preferred language, then the region. Chinese, or English.
lang=""
for value in "${LC_ALL:-}" "${LC_MESSAGES:-}" "${LANG:-}"; do
	[ -n "$value" ] || continue
	language="${value%%[.@]*}"
	case "$language" in
	zh*) lang=zh ;;
	"" | C | c | POSIX | posix) continue ;;
	*) lang=en ;;
	esac
	break
done
if [ -z "$lang" ]; then
	first="$(defaults read -g AppleLanguages 2>/dev/null | tr -d '(),"' | awk 'NF { print $1; exit }')" || first=""
	[ -n "$first" ] || first="$(defaults read -g AppleLocale 2>/dev/null)" || first=""
	case "$first" in zh*) lang=zh ;; *) lang=en ;; esac
fi

# On a terminal the run is drawn (steps/07 §8, the look the user approved
# 10-06; the sentences stay 06-copy §21's): the mark, the version, a progress bar redrawn in place, a check mark
# before each thing done, every line indented two spaces. Anywhere else —
# piped, redirected, read by an agent — it is the table's sentences and
# nothing else. NO_COLOR (no-color.org) drops the colour, not the drawing.
fancy=""
if [ -t 1 ] && [ "${TERM:-dumb}" != dumb ]; then fancy=yes; fi
red=""
reset=""
if [ -n "$fancy" ] && [ -z "${NO_COLOR:-}" ]; then
	# The icon's red, #FF3B30 (AppIcon.icon), as near as the terminal can.
	case "${COLORTERM:-}" in
	truecolor | 24bit) red=$'\e[38;2;255;59;48m' ;;
	*) case "${TERM:-}" in *256color*) red=$'\e[38;5;203m' ;; *) red=$'\e[31m' ;; esac ;;
	esac
	reset=$'\e[0m'
fi
indent=""
[ -z "$fancy" ] || indent="  "

lead="" # what `ticked` puts before the next sentence
say() { # say <zh> <en>
	local text="$2"
	[ "$lang" != zh ] || text="$1"
	printf '%s%s%s\n' "$indent" "${fancy:+$lead}" "$text"
}
ticked() { # ticked say <zh> <en>: a thing that is now done, with its check mark
	lead="✓ "
	"$@"
	lead=""
}
stop() {
	[ -t 2 ] || indent=""
	say "$1" "$2" >&2
	exit 1
}

# The mark, the app icon's: three red bars tall, short, tall, and three lines
# long, short, long. Then the name; the version joins it once the app is in
# (below), read from the app's own `meetcap --version`, the app that is here
# when the script ends: a download point's VERSION may be missing.
if [ -n "$fancy" ]; then
	printf '\n  %s█   █%s   ━━━━━━\n' "$red" "$reset"
	printf '  %s█ █ █%s   ━━━━\n' "$red" "$reset"
	printf '  %s█ █ █%s   ━━━━━━\n\n' "$red" "$reset"
	printf '  MeetCap\n\n'
fi

# Which Mac this is, and so which disk image: Apple silicon or Intel. In a
# terminal opened with Rosetta on Apple silicon, `uname -m` says x86_64, as
# everything translated does; sysctl.proc_translated says 1 there (0 natively,
# and an Intel Mac has no such entry), and that Mac still gets the Apple
# silicon build.
case "$(uname -m)" in
arm64) image=MeetCap.dmg ;;
x86_64)
	if [ "$(sysctl -n sysctl.proc_translated 2>/dev/null)" = 1 ]; then image=MeetCap.dmg; else image=MeetCap-Intel.dmg; fi ;;
*) image="" ;;
esac
# The build that disk image holds, as a Mac program names its kind.
case "$image" in MeetCap.dmg) chip=arm64 ;; *) chip=x86_64 ;; esac
# macOS 14.2, as the app and the command line require (spec/mac 3).
os="$(sw_vers -productVersion 2>/dev/null || echo 0)"
major="${os%%.*}"
rest="${os#*.}"
minor="${rest%%.*}"
[ "$rest" != "$os" ] || minor=0
if [ "$(uname -s)" != Darwin ] || [ -z "$image" ] ||
	[ "$major" -lt 14 ] || { [ "$major" -eq 14 ] && [ "$minor" -lt 2 ]; }; then
	stop "MeetCap 需要 macOS 14.2 或更高版本的 Mac。" \
		"MeetCap requires a Mac with macOS 14.2 or later."
fi

if [ -n "${MEETCAP_APPLICATIONS:-}" ]; then
	applications="$MEETCAP_APPLICATIONS"
elif [ -w /Applications ]; then
	applications=/Applications
else
	applications="$HOME/Applications"
fi
app="$applications/MeetCap.app"
meetcap="$app/Contents/Helpers/meetcap"

# The version the download point has, its VERSION (the version alone), beside
# the one already here (decisions 10-07). That version or a newer one already
# here: nothing is downloaded and nothing replaced — an older release never
# replaces a newer one — and the command and the skill are placed all the
# same, which is what running the command again after installing an agent is
# for. No MeetCap here, or either version unreadable or not a version: the
# download and the replacement, as always.
is_version() { # is_version <text>: numbers joined by dots, and nothing else
	case "$1" in "" | .* | *. | *..* | *[!0-9.]*) return 1 ;; esac
}
order() { # order <here> <available>: newer, same or older, number by number (1.10 is after 1.9; 1.0 is 1.0.0)
	local a="$1." b="$2." x y
	while [ -n "$a$b" ]; do
		x="${a%%.*}" y="${b%%.*}"
		a="${a#*.}" b="${b#*.}"
		x=$((10#${x:-0})) y=$((10#${y:-0}))
		if [ "$x" -gt "$y" ]; then echo newer; return; fi
		if [ "$x" -lt "$y" ]; then echo older; return; fi
	done
	echo same
}
work="$(mktemp -d)"
# Where the disk image is mounted, read-only.
volume="$work/volume"
fetching=""

# Whether a volume is mounted at <folder>: the folder is on another device
# than the folder it is in. Read from the file system, not remembered, so an
# attach cut short or a detach that answered busy cannot be lost track of.
mounted_at() { # mounted_at <folder>
	local here up
	here="$(stat -f %d "$1" 2>/dev/null)" || return 1
	up="$(stat -f %d "$1/.." 2>/dev/null)" || return 1
	[ "$here" != "$up" ]
}
# Takes the volume at <folder> off: 0 once nothing is mounted there. A volume
# just mounted is often still being read by the system for a moment (Spotlight
# among others), and `hdiutil detach` then answers that it is busy: it is asked
# again for about five seconds, then forced. Forcing loses nothing: the volume
# is read-only, and this script is done reading it.
detach() { # detach <folder>
	local tries=0
	while mounted_at "$1"; do
		if [ "$tries" -ge 10 ]; then
			hdiutil detach -quiet -force "$1" >/dev/null 2>&1 || true
			! mounted_at "$1"
			return
		fi
		hdiutil detach -quiet "$1" >/dev/null 2>&1 || sleep 0.5
		tries=$((tries + 1))
	done
}
# On the way out, whatever the way: never a reason to fail of its own (under
# `set -e` a command failing here would end an install that worked with 1),
# and nothing removed through a volume still mounted (each of its files would
# fail, read-only): one that will not come off keeps the work folder, in the
# system's temporary folder.
cleanup() {
	# A download in the background is the script's to stop (Ctrl-C included:
	# a non-interactive shell's background jobs ignore it).
	if [ -n "$fetching" ]; then { kill "$fetching" && wait "$fetching"; } 2>/dev/null || true; fi
	if detach "$volume"; then rm -rf "$work" 2>/dev/null || true; fi
}
trap cleanup EXIT

# A small file from a download point, into <into>, given the start window to
# answer in: curl's exit status. The first point not reached is down, and is
# not asked again; one that answered that it has no such file (22 over HTTP,
# 37 for a file: URL) is not.
first_down=""
small() { # small <point> <file> <into>
	local code=0
	curl -fsSL --connect-timeout "$START_SECONDS" --max-time $((START_SECONDS * 2)) \
		-o "$3" "$1/$2" 2>>"$work/curl.err" || code=$?
	case "$code" in 0 | 22 | 37) ;; *) [ "$1" != "$RELEASE_URL" ] || first_down=yes ;; esac
	return "$code"
}
# <file> from the first point that has it, into <into>.
either() { # either <file> <into>
	if [ -z "$first_down" ] && small "$RELEASE_URL" "$1" "$2"; then return 0; fi
	small "$MIRROR_URL" "$1" "$2"
}

installed=""
available=""
compared=""
if [ -x "$meetcap" ]; then
	installed="$("$meetcap" --version 2>/dev/null | awk 'NR == 1 { print $2 }')" || installed=""
fi
if is_version "$installed"; then
	if either VERSION "$work/VERSION"; then available="$(cat "$work/VERSION")"; fi
	if is_version "$available"; then compared="$(order "$installed" "$available")"; fi
fi
# A MeetCap here built for the other kind of Mac is replaced whatever its
# version (steps/08 item 94 ②): the Apple silicon build does not run on an
# Intel Mac, and the Intel build runs on Apple silicon only under Rosetta.
# Read with `file`, which is part of macOS; `lipo` is one of the developer
# tools' stand-ins (man xcode-select, FILES), which on a Mac without the
# developer tools does not run. `arm64` also matches the `arm64e` of a
# universal program. A file that is not a Mac program says nothing either way.
for_this_mac() { # for_this_mac <program>: false only for a Mac program without this Mac's build in it
	local kinds
	kinds="$(file -bL "$1" 2>/dev/null)" || return 0
	case "$kinds" in *Mach-O*) ;; *) return 0 ;; esac
	case "$kinds" in *"$chip"*) return 0 ;; esac
	return 1
}
case "$compared" in same | newer)
	if ! for_this_mac "$meetcap" || ! for_this_mac "$app/Contents/MacOS/MeetCap"; then compared=""; fi ;;
esac
kept=""
case "$compared" in same | newer) kept=yes ;; esac
updated=""
# Whether this computer is set up: `meetcap config` finds the library it names.
# A Mac that is not is told how to finish setting up (06-copy install.next),
# whatever else this run did.
set_up() {
	local library
	library="$("$meetcap" --json config 2>/dev/null | plutil -extract files.library raw -o - - 2>/dev/null)" || library=""
	[ -n "$library" ]
}
settled=""

# Replacing the app needs it closed, and is asked before anything is
# downloaded; keeping it does not.
if [ -z "$kept" ] && pgrep -fx "$app/Contents/MacOS/MeetCap" >/dev/null 2>&1; then
	stop "MeetCap 正在运行。请先退出 MeetCap，再运行一次安装命令。" \
		"MeetCap is open. Quit MeetCap, then run the install command again."
fi

# The progress line: a bar of heavy and light lines as wide as the terminal
# allows (at most 36), the percentage, and how many MB of how many.
# 1 MB = 1,000,000 bytes, as Finder counts; under 10 MB in all, to a tenth.
mb() { # mb <bytes> <bytes in all>
	if [ "$2" -lt 10000000 ]; then
		printf '%d.%d' "$(($1 / 1000000))" "$(($1 % 1000000 / 100000))"
	else
		printf '%d' "$((($1 + 500000) / 1000000))"
	fi
}
bar() { # bar <bytes so far> <bytes in all, or empty>
	local got="$1" all="$2" width cols filled i line=""
	if [ -z "$all" ] || [ "$all" -le 0 ]; then
		printf '\r  %s MB\e[K' "$(mb "$got" "$got")"
		return
	fi
	[ "$got" -le "$all" ] || got="$all"
	# The terminal's width, asked of the terminal itself (fd 4: this
	# function's output); stdin is the pipe `curl | bash` reads the script from.
	{ cols="$(stty size <&4 2>/dev/null | awk '{ print $2 }')"; } 4>&1 || cols=""
	case "$cols" in "" | 0 | *[!0-9]*) cols=80 ;; esac
	width=$((cols - 26))
	[ "$width" -le 36 ] || width=36
	if [ "$width" -ge 10 ]; then
		filled=$((got * width / all))
		i=0
		while [ "$i" -lt "$width" ]; do
			if [ "$i" -lt "$filled" ]; then line="${line}━"; else line="${line}─"; fi
			i=$((i + 1))
		done
		line="${line}  "
	fi
	printf '\r  %s%d%%   %s / %s MB\e[K' "$line" "$((got * 100 / all))" "$(mb "$got" "$all")" "$(mb "$all" "$all")"
}

size_of() { stat -f %z "$1" 2>/dev/null || echo 0; }

# The sum a point's SHA256SUMS gives this Mac's disk image, in $sum; non-zero
# when it has none.
sum=""
sum_at() { # sum_at <point>
	sum=""
	small "$1" SHA256SUMS "$work/SHA256SUMS" || return 1
	sum="$(awk -v name="$image" '$2 == name || $2 == "*" name { print $1; exit }' "$work/SHA256SUMS")"
	case "$sum" in *[!0-9a-f]*) sum="" ;; esac
	[ "${#sum}" -eq 64 ] || { sum=""; return 1; }
}

# Whether the app at <app> is MeetCap as we release it (steps/08 item 121).
# SHA256SUMS comes from the same point as the disk image, so a point whose two
# files were both replaced passes the sum; and a file curl downloads carries no
# quarantine, so Gatekeeper never looks at this app. Here it is checked that:
# * the signature is whole and is MeetCap's (`codesign --verify --deep
#   --strict`, against the designated requirement our releases carry,
#   `codesign -d -r-`): a Developer ID Application certificate Apple issued
#   to team TEAM_ID, so a certificate made by anyone else, whatever team it
#   names, does not pass;
# * Apple notarized it (codesign's `notarized` requirement). The ticket is
#   stapled to the disk image, not to the app, so `--check-notarization` asks
#   Apple for it online (man codesign); the install is online anyway.
# Both are codesign's, part of macOS. Not `spctl -a`: its answer follows this
# Mac's Gatekeeper setting, and where the person allows apps from anywhere it
# no longer says whether the app is notarized. Not `stapler`: it is one of the
# developer tools' stand-ins (man xcode-select, FILES), which a Mac without
# them does not run, and the app has no ticket of its own for it to read.
TEAM_ID=9QGMD7XVWP           # scripts/release.py TEAM_ID
BUNDLE_ID=dev.seacen.MeetCap # scripts/release.py RELEASE_ID
ours() { # ours <app>
	codesign --verify --deep --strict -R="identifier \"$BUNDLE_ID\" and anchor apple generic and certificate 1[field.1.2.840.113635.100.6.2.6] exists and certificate leaf[field.1.2.840.113635.100.6.1.13] exists and certificate leaf[subject.OU] = \"$TEAM_ID\"" \
		"$1" >/dev/null 2>&1 || return 1
	codesign --verify --check-notarization -R=notarized "$1" >/dev/null 2>&1
}

# This Mac's disk image from a point into $dmg, on from the bytes already there, in the
# background while the bar follows it a few times a second (on a terminal):
# 0 once it is all here. Non-zero when the point fails, when it stays under
# STALL_RATE for STALL_SECONDS, and, with `watch`, when it has brought less
# than START_RATE a second in its first START_SECONDS.
size=""
pull() { # pull <point> <watch: yes or empty>
	local url="$1/$image" watch="$2" from ticks got status=0
	from="$(size_of "$dmg")"
	size=""
	if [ -n "$fancy" ]; then
		# The size (the last answer's, after any redirect).
		size="$(curl -fsSIL --connect-timeout "$START_SECONDS" --max-time $((START_SECONDS * 2)) "$url" 2>/dev/null |
			tr -d '\r' | awk 'tolower($1) == "content-length:" { n = $2 } END { print n }')" || size=""
		case "$size" in *[!0-9]*) size="" ;; esac
	fi
	curl -fsSL -C - --speed-limit "$STALL_RATE" --speed-time "$STALL_SECONDS" \
		-o "$dmg" "$url" 2>>"$work/curl.err" &
	fetching=$!
	# Fifths of a second slept since it began: at least that long has passed.
	ticks=0
	while kill -0 "$fetching" 2>/dev/null; do
		got="$(size_of "$dmg")"
		[ -z "$fancy" ] || bar "$got" "$size"
		if [ -n "$watch" ] && [ "$ticks" -ge $((START_SECONDS * 5)) ]; then
			watch=""
			if [ $((got - from)) -lt $((START_SECONDS * START_RATE)) ]; then
				{ kill "$fetching" && wait "$fetching"; } 2>/dev/null || true
				fetching=""
				return 1
			fi
		fi
		sleep 0.2
		ticks=$((ticks + 1))
	done
	wait "$fetching" || status=$?
	fetching=""
	return "$status"
}

if [ -z "$kept" ]; then
	say "正在下载 MeetCap。" "Downloading MeetCap."
	dmg="$work/$image"
	fetched=""
	# The first point's sum, then its disk image; the second's when the first
	# has no sum, cannot be reached or is too slow, its disk image on from the
	# bytes already here when it is the same file, from the start when not.
	expected=""
	if [ -z "$first_down" ] && sum_at "$RELEASE_URL"; then expected="$sum"; fi
	if [ -n "$expected" ] && pull "$RELEASE_URL" yes; then
		fetched=yes
	elif sum_at "$MIRROR_URL"; then
		[ "$sum" = "$expected" ] || rm -f "$dmg"
		expected="$sum"
		if pull "$MIRROR_URL" ""; then fetched=yes; fi
	fi
	if [ -n "$fancy" ]; then
		if [ -n "$fetched" ]; then
			got="$(size_of "$dmg")"
			bar "$got" "${size:-$got}"
			printf '\n\n'
		else
			printf '\r\e[K'
		fi
	fi
	if [ -z "$fetched" ]; then
		cat "$work/curl.err" >&2
		stop "无法下载 MeetCap。请检查网络连接，再运行一次安装命令。" \
			"Couldn't download MeetCap. Check your internet connection, then run the install command again."
	fi
	# Not the file SHA256SUMS names: as damaged as one that does not open.
	if [ "$(shasum -a 256 "$dmg" | awk '{ print $1 }')" != "$expected" ]; then
		stop "下载的 MeetCap 无法打开。请再运行一次安装命令。" \
			"The downloaded copy of MeetCap couldn't be opened. Run the install command again."
	fi
	mkdir "$volume"
	if ! hdiutil attach -quiet -nobrowse -readonly -noautoopen -mountpoint "$volume" "$dmg" >/dev/null; then
		stop "下载的 MeetCap 无法打开。请再运行一次安装命令。" \
			"The downloaded copy of MeetCap couldn't be opened. Run the install command again."
	fi
	# Not an app we signed and Apple notarized: as damaged as one that does
	# not open. Stopped before anything is copied or run; the way out takes
	# the volume off (cleanup).
	if ! ours "$volume/MeetCap.app"; then
		stop "下载的 MeetCap 无法打开。请再运行一次安装命令。" \
			"The downloaded copy of MeetCap couldn't be opened. Run the install command again."
	fi

	# Whether this run updates a MeetCap that was already here (06-copy
	# install.updated): asked before the old app goes.
	was_there=""
	[ -d "$app" ] && was_there=yes

	# The new app goes in beside the old one and takes its place in one rename, so
	# no moment has half of each. A recording in progress keeps the program it
	# started with.
	mkdir -p "$applications"
	rm -rf "$applications/.MeetCap.app.new"
	ditto "$volume/MeetCap.app" "$applications/.MeetCap.app.new"
	# One still mounted after that is tried again on the way out (cleanup).
	detach "$volume" || true
	rm -rf "$app"
	mv "$applications/.MeetCap.app.new" "$app"

	# An update, rather than an install: the app was already here, and this
	# computer is set up. Then what changed is the version, and there is
	# nothing left to set up.
	version="$("$meetcap" --version 2>/dev/null | awk 'NR == 1 { print $2 }')" || version=""
	if [ -n "$was_there" ] && [ -n "$version" ] && set_up; then updated=yes; settled=yes; fi
	shown="$version"
	# The title, a blank line, the download's sentence, its bar and a blank line.
	up=5
else
	# Nothing was downloaded: the title and a blank line. The version is the one
	# on this Mac.
	version="$available"
	shown="$installed"
	up=2
	if set_up; then settled=yes; fi
fi
# The version beside the name, $up lines up.
if [ -n "$fancy" ] && [ -n "$shown" ]; then
	printf '\e[%dA\r  MeetCap %s\e[K\e[%dB\r' "$up" "$shown" "$up"
fi
case "$compared" in
same)
	ticked say "MeetCap 已是最新版本（${version}）。" "MeetCap is already up to date ($version)." ;;
newer)
	ticked say "这台电脑上的 MeetCap（${installed}）比可下载的版本（${version}）还新，没有替换。" \
		"The MeetCap on this Mac ($installed) is newer than the one available ($version), so it was left as it is." ;;
*)
	if [ -n "$updated" ]; then
		ticked say "MeetCap 已更新到 ${version}。" "MeetCap is updated to $version."
	else
		ticked say "MeetCap 已安装到「应用程序」文件夹。" "MeetCap is installed in your Applications folder."
	fi
	;;
esac

# The command line and the skill. One JSON object, its answer or its error
# (meetcap/src/place.rs); macOS's own plutil reads it.
placed="$("$meetcap" --json _place)" && place_failed="" || place_failed=yes
field() { printf '%s' "$placed" | plutil -extract "$1" raw -o - - 2>/dev/null || true; }
if [ -n "$place_failed" ]; then
	# `cannot_write`: `which` is the file or folder it could not write.
	# `no_home` and `skill_missing` have no folder of the person's to name, and
	# neither comes of a release run from a terminal: what was said is passed on.
	path="$(field which)"
	if [ "$(field error)" = cannot_write ] && [ -n "$path" ]; then
		stop "MeetCap 已安装，但 meetcap 命令和 skill 没有装上。无法写入 ${path}。" \
			"MeetCap is installed, but the meetcap command and the skill aren't. $path can't be written to."
	fi
	printf '%s\n' "$placed" >&2
	exit 1
fi

# A `meetcap` in ~/.local/bin that is not a link is somebody else's, and
# `_place` left it alone: the command there is not MeetCap's.
if [ "$(field link.state)" = not_a_link ]; then
	say "无法安装 meetcap 命令。请先移走 ~/.local/bin 里的同名文件，再运行一次安装命令。" \
		"Couldn't install the meetcap command. Move the file named meetcap out of ~/.local/bin, then run the install command again."
else
	link_dir="$(dirname "$(field link.path)")"
	# `_place` put ~/.local/bin on the login shell's PATH itself when it was not
	# there (`link.shell_file`, the file it added the lines to): a new window has it.
	profile="$(field link.shell_file)"
	case "$profile" in "$HOME"/*) profile="~${profile#"$HOME"}" ;; esac
	case ":$PATH:" in
	*":$link_dir:"*)
		ticked say "现在可以在终端里使用 meetcap 命令。" "You can now use the meetcap command in Terminal." ;;
	*) if [ -n "$profile" ]; then
		say "要在终端里使用 meetcap 命令，请打开一个新的终端窗口。MeetCap 已在 ${profile} 中添加一行，让终端能找到这个命令。" \
			"To use the meetcap command in Terminal, open a new Terminal window. MeetCap added a line to $profile so Terminal can find the command."
	else
		case "${SHELL:-}" in */bash) profile="~/.bash_profile" ;; *) profile="~/.zshrc" ;; esac
		say "要在终端里使用 meetcap 命令，请把下面这一行加到 ${profile}，再打开一个新的终端窗口：" \
			"To use the meetcap command in Terminal, add this line to $profile, then open a new Terminal window:"
		# shellcheck disable=SC2016 # printed for the person to paste, unexpanded
		printf '%s    export PATH="$HOME/.local/bin:$PATH"\n' "$indent"
	fi ;;
	esac
fi

# The agents the skill was added for, by name, in the agent table's order.
names=""
count="$(field agents)"
i=0
while [ "$i" -lt "${count:-0}" ]; do
	name="$(field "agents.$i.name")"
	if [ -z "$names" ]; then names="$name"; else names="$names|$name"; fi
	i=$((i + 1))
done
zeroclaw=""
if [ "$(field zeroclaw)" = true ]; then zeroclaw=yes; fi
skill="$(field skill)"

if [ -n "$names" ]; then
	list_zh="$(printf '%s' "$names" | sed 's/|/、/g')"
	list_en="$(printf '%s' "$names" | awk -F'|' '{
		if (NF == 1) print $1
		else if (NF == 2) print $1 " and " $2
		else { s = $1; for (i = 2; i < NF; i++) s = s ", " $i; print s ", and " $NF }
	}')"
	ticked say "已为 ${list_zh} 装好 MeetCap 的 skill。" "Added the MeetCap skill to $list_en."
elif [ -z "$zeroclaw" ]; then
	say "这台电脑上没有找到支持的智能体。装好智能体后再运行一次安装命令，就会为它装上 MeetCap 的 skill。" \
		"No supported agent was found on this Mac. After you install one, run the install command again to add the MeetCap skill to it."
fi
if [ -n "$zeroclaw" ]; then
	say "要在 ZeroClaw 里使用 MeetCap，请运行 zeroclaw skills install \"$skill\" --bundle meetcap，再在 ZeroClaw 的配置里把 meetcap 加进你的智能体的 skill_bundles。" \
		"To use MeetCap in ZeroClaw, run zeroclaw skills install \"$skill\" --bundle meetcap, then add meetcap to your agent's skill_bundles in ZeroClaw's settings."
fi
if [ -z "$settled" ]; then
	[ -z "$fancy" ] || printf '\n'
	say "打开 MeetCap 完成设置，或在终端里运行 meetcap setup。" \
		"To finish setting up, open MeetCap or run meetcap setup in Terminal."
fi
