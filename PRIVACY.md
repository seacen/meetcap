# MeetCap Privacy Notice

Last updated: October 18, 2026

Effective: October 18, 2026

## Summary

- **Your meeting content stays with you.** Recordings are kept only on the device that made them. Transcripts, minutes and voiceprints are kept in a location you choose. We cannot access any of it.
- **MeetCap sends us information only when you send a problem report.** There is no account to create, no analytics or advertising, and crashes are never reported automatically.
- **Only text is sent to an AI service, and you choose which one.** To produce summaries and minutes, MeetCap sends the transcript text directly from your device to the AI service you choose. Recordings and voiceprints are not sent. If you use a local model, nothing is sent.
- **Tell people before you save their voiceprint.** Voiceprints are sensitive personal information. See Section 5.

The full notice follows.

## 1. Who we are

MeetCap is developed and provided by Seacen Zhao, an individual developer ("we", "us"). If you have any questions about this notice, contact us as described in Section 12.

## 2. Scope

This notice applies to the MeetCap app, the command-line tool and the accompanying agent skill (together, "MeetCap") on every platform MeetCap supports. It also applies to the MeetCap website, meetcap.seacen.dev.

If we later launch an online service that we operate (for example, minutes generated on our servers), we will add a separate notice for it. See Section 11.

## 3. Information processed on your device

To record, transcribe and produce minutes, MeetCap processes the following information on your device. This happens only when you start it, and only on your device. Nothing is sent to us unless you send a problem report (see Section 4).

| Information | Purpose | Where it is kept | How long it is kept |
|---|---|---|---|
| Meeting recordings | Transcription, telling speakers apart, playback | Only on the device that recorded them | You decide; see Section 8 |
| Transcripts, summaries and minutes | For you to read, search and share | The meeting library location you choose | Until you delete them |
| Voiceprints and the audio clips used to create them | Recognizing people you've named when they speak in later meetings | The meeting library location you choose | Until you delete them; see Section 5 |
| Meeting titles, attendees and glossaries | Making transcripts and minutes more accurate | The meeting library location you choose | Until you delete them |
| Settings | Remembering your preferences | Your device | Until you uninstall MeetCap |
| API keys | Calling the AI service you choose | The credential store provided by your device's operating system | Until you delete them or uninstall MeetCap |
| Activity logs (no meeting content) | Investigating problems | Your device | Older entries are deleted automatically; logs are capped at about 26 MB in total |

Your meeting library can be kept locally on your device or in your own cloud storage service (such as iCloud Drive or OneDrive). If it is in a cloud storage service, that service stores and syncs the files under its own privacy policy.

## 4. Information we receive

We receive information only in these cases:

- **You send a problem report from MeetCap.** MeetCap sends the report to us only when you click Send, or when you run the `meetcap feedback` command with `--confirm`. We receive what you write, your contact details if you give them, and diagnostics if you choose to include them. Diagnostics contain the last 14 days of activity logs, records of when MeetCap stopped responding or quit unexpectedly, the results of MeetCap's built-in checks, the MeetCap and system versions, your device's chip, memory, free space and language, a summary of your settings, and how up to 5 recent meetings were recorded and processed (events, counts and error codes only). They never contain recordings, transcripts, summaries, minutes, meeting titles, names, voiceprints, keys or your computer's user name. You can review every item before you send, or leave diagnostics out. We use this information only to investigate and fix problems, and we delete it after 90 days. We also keep a copy of what you write and your contact details in our private issue tracker on GitHub, and delete that copy after 90 days as well. After that, the issue tracker keeps only the reference number, the time, and technical details such as the MeetCap and system versions. To have your report deleted sooner, email us the reference number MeetCap shows after you send the report. We don't store your IP address.
- **You contact us.** If you contact us by email or through GitHub, we receive the information you provide (such as your email address and what you write) and use it only to reply to you. You can ask us to delete it at any time.
- **You visit our website.** To see how the website is used, we count visits and downloads on our own server. We record the pages you visit, the site that sent you here, and your browser, device, language and approximate location. Visit statistics don't use cookies or store your IP address. The website sets one cookie only when you switch languages, to remember the language you chose; it isn't used for statistics. Download records are deleted after 30 days, and visit statistics are kept for 25 months.

## 5. Voiceprints

A voiceprint is data derived from the characteristics of a person's voice. It is biometric information and is treated as sensitive personal information in many countries and regions.

- **Why MeetCap needs it:** MeetCap uses voiceprints to recognize speakers automatically in later meetings, so you don't have to name them again in every meeting.
- **When it is created:** MeetCap saves a person's voiceprint, along with a few audio clips used to create it, only after you name that speaker. MeetCap does not save voiceprints of speakers you have not named.
- **Where it is kept:** With your meeting records, in the meeting library location you choose. It is not sent to us or to any AI service.
- **How to delete it:** When you tell MeetCap to stop recognizing someone, that person's voiceprint and those clips are deleted right away. Names already in past meeting records stay as they are. Deleting your whole meeting library also deletes all voiceprints.
- **Risks:** A voiceprint can be used to identify a specific person in a recording. If your meeting library is in a cloud storage service, anyone who can access that location can also access the voiceprints. Keep your meeting library secure and share it only with people you trust.

**Before you save someone else's voiceprint, you need to tell them that MeetCap will save it, where it will be kept and how it can be deleted, and get their consent as required by the laws where you are.** If they ask you to delete it, please do so promptly. See Section 5 of the [Terms of Use](./TERMS.md).

## 6. Third-party services you choose

MeetCap sends information over the network only in these cases, and only when you choose or start them:

1. **AI services.** To produce summaries, minutes and translations, MeetCap sends the transcript text, background information about the meeting, and your glossary directly from your device to the AI service you choose: either an AI provider whose API key you add, or an agent installed on your device (such as Claude Code or Codex). If you choose to use a provider with an API key, MeetCap first tells you where the text will go and turns that provider on only after you agree. That provider's terms and privacy policy govern how it handles this information. We do not receive it and cannot access it. You can also have MeetCap install and run a local model on your device, in which case the text does not leave your device.
2. **Downloading models and installation files.** When you install MeetCap, or download a speech recognition model or a local AI model for minutes, MeetCap downloads files from GitHub, Hugging Face, ModelScope and our website. GitHub, Hugging Face and ModelScope may log routine network information such as your IP address, under their own privacy policies. What our website records is described in Section 4. None of your meeting content is sent during these downloads.
3. **Agents reading your meeting library.** When you use the MeetCap agent skill in an agent, the agent can read the content of your meeting library. How the agent handles that content is governed by its provider's terms.
4. **Cloud storage services.** If your meeting library is in a cloud storage service, that service syncs the files under its own terms and privacy policy.

We do not sell or rent your information, or share it with anyone.

## 7. International transfers

Apart from problem reports and the website statistics described in Section 4, we do not transfer your information across borders. The AI service or cloud storage service you choose may be located outside your country or region. Any transfer that results is your choice and is governed by your agreement with that service.

## 8. Retention and deletion

Your information is kept on your device and in the locations you choose, and you decide how long it is kept:

- **Recordings:** Kept indefinitely by default. You can choose to keep only the last 1, 3 or 6 months of recordings, and older recordings are then deleted automatically. You can also clear them out manually at any time.
- **Meetings:** When you delete a meeting, its recording, transcript and minutes are moved to your system's Trash or Recycle Bin.
- **Voiceprints:** See Section 5.
- **Everything:** Uninstalling MeetCap and deleting your meeting library deletes all information MeetCap has stored.

Text that has already been sent to an AI service is kept and deleted under that service's policies. Problem reports and website statistics are kept on our server for the periods described in Section 4.

## 9. Your rights

All of your information in MeetCap is kept on your device and in the locations you choose, so you can view, copy, change and delete it directly at any time, without going through us. For information you have sent us in a problem report, by email or by other means, you can ask us to give you access to it, correct it or delete it, and we will respond within 15 business days.

## 10. Children and security

MeetCap is not intended for children under 14.

The security of your information depends on the security measures of your device and of the storage services you use. API keys are kept in your device's system credential store and are not written in plain text to settings files. We recommend that you set a password on your device and turn on two-factor authentication for your cloud storage account.

## 11. Changes to this notice

We may update this notice. We will publish the updated version on our website, showing the date it was last updated and the date it takes effect. We will publish material changes at least seven days before they take effect.

Before we add a feature to MeetCap that collects information, we will update this notice to say what it collects and why, and ask for your consent before you use it. Before we launch an online service that we operate, we will publish a separate notice for it (see Section 2). We will not reduce your rights under this notice without your explicit consent.

## 12. Contact us

- Email: mail@seacen.dev
- Website: https://meetcap.seacen.dev
