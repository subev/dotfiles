# Speaking Claude Code's summaries

Reads Claude Code's end-of-turn summary aloud, on demand, through the local Kokoro
voice — the same server and the same `af_heart` ("Heart") voice that Spotter uses.
Nothing speaks on its own.

## Keys

| Key | Where | What |
| --- | --- | --- |
| `<leader>tS` | any buffer, and a pane you have left with `<C-q>` | speak the last summary |
| `<C-]>` | while typing in an agent pane | speak that pane's last summary |
| `<leader>ts` | any buffer | stop playback |

`<leader>tS` works in Terminal-Normal mode because that is Normal mode as far as
mappings are concerned, so one key covers a code buffer and an agent pane alike.

## How it works

```
Claude Code Stop hook ──> ~/.cache/claude-speak/<project>/<slot>.json
                                        latest.json
                                              │
                    <leader>tS ─── reads the record ──> tts.nvim ──curl──> Kokoro
```

- **Capture.** A `Stop` hook runs `~/.local/bin/claude-speak-hook` at the end of each
  turn. It writes the CLI's own `last_assistant_message` — never the transcript, which
  the docs warn may not include the final message yet when a Stop hook fires. The hook
  only writes a file: no synthesis, no network, so it is cheap on every turn.
- **Routing.** Each pane's slot name travels in `CLAUDE_SLOT`, exported by `bin/claude-slot`,
  which `nvim/lua/plugins/ai.lua` wraps every agent slot in. Records are keyed by
  **project directory and slot**, which
  is what makes ten Neovims safe from each other: `free_slot` hands out distinct slot
  names within a project, and different projects get different directories. It is
  deliberately *not* keyed by Neovim's pid — a zellij pane keeps the environment it was
  created with, so a pid captured at pane creation goes stale on the next Neovim restart
  and the record lands in a directory nothing will ever read.
- **Playback.** `nvim/lua/config/claude_speak.lua` reads the record and hands the text to
  `tts.nvim`, which strips the markdown, splits it into sentences, prefetches the next
  segment while the current one plays, and caches audio. Code fences are skipped.
  Synthesis stays at Kokoro's natural pace and afplay plays it back at 1.5x, which
  preserves pitch where raising Kokoro's own `speed` does not.
- **Which record.** A pane reads **its own** record or nothing. It deliberately does not
  fall back to the project's `latest.json`, because several agents run side by side and
  that file is simply whichever finished last — reading a sibling's reply aloud is the
  confusion the slot exists to prevent. The fallback applies only with no pane to scope
  to: a code buffer, or `claude` started outside sidekick.

## Setup

```bash
./install.sh --only bin,launchd
```

That links the hook onto `PATH` and loads the agent — the `launchd` component runs
`launchctl bootstrap` for you, and says `already loaded` if it is. It is deliberately not
part of `--all`: on a machine with no Kokoro checkout the job could only sit idle.

**One manual step**, because this repo does not track `~/.claude/settings.json` and
`install.sh --check` therefore cannot detect drift in it. Add, under `hooks`:

```json
"Stop": [
  { "hooks": [
    { "type": "command", "command": "$HOME/.local/bin/claude-speak-hook", "async": true }
  ] }
]
```

Then restart the agent panes so they pick up `CLAUDE_SLOT`, and check from inside one:

```bash
ps eww -p $$ | tr ' ' '\n' | grep CLAUDE_SLOT
```

## A new machine

Three things have to exist before any of this does anything, and none of them are in this
repo:

| Needs | Where it comes from |
| --- | --- |
| `~/repos/kokoro-tts` — the venv **and** `kokoro-v1.0.onnx` + `voices-v1.0.bin` (~350 MB) | spotter's README lists the Python requirements; the model files are a separate download |
| `~/repos/spotter` — the server script the agent runs | clone it. The agent runs whatever is checked out, so keep that checkout current |
| The `Stop` hook above | hand edit; nothing detects it going missing |

Until those exist the agent *loads and exits quietly* rather than failing loudly — the
plist guards `exit 0` on a missing venv, model, or server script, because `KeepAlive`
treats any non-zero exit as a crash and would otherwise retry every 30 seconds forever
over a checkout that is not there. `./install.sh --only launchd` prints a note when the
checkouts are missing.

One gotcha worth recording: `launchctl bootstrap` must be given the plist from
`~/Library/LaunchAgents/`, not from this repo. The repo path fails with a bare
`Input/output error`, and a `bootout` before it leaves the port unserved.

## The server

One `kokoro_server.py`, kept running by the `com.petur.kokoro-tts` LaunchAgent on
**8741**, shared by every Neovim and by Spotter.

Spotter needs no changes for this: `AppController.startServerIfNeeded()` probes
`/health` first and returns early when something answers, and `stopServer()` only kills a
process it started. It finds this server and reuses it, which is the point — one resident
model rather than one per app.

The trade that buys: the server holds roughly a gigabyte, always, including while Spotter
is off, and Spotter's "turning shortcuts off releases the memory" no longer holds for TTS.

```bash
launchctl kickstart -k gui/$UID/com.petur.kokoro-tts   # restart after editing the server
launchctl bootout gui/$UID/com.petur.kokoro-tts        # stop until next login
```

Two servers cannot share the port. If Spotter started first it holds 8741 until it quits,
and this agent logs `cannot bind ... Address already in use` every 30s until then — it
binds within 30s of Spotter releasing it. The bind happens *before* the model loads, so
losing that race costs milliseconds rather than a gigabyte.

## Voices

Kokoro is not OpenAI, so `:TTSVoices` lists names this server does not have. The real
list is:

```bash
curl 127.0.0.1:8741/voices
```

`:TTSSetVoice af_bella` works for the session. To make it stick, change `openai.voice` in
`nvim/lua/plugins/misc.lua` — the server falls back to `af_heart` for any name it does not
recognise, including OpenAI's `alloy`, rather than failing.

## Troubleshooting

| Symptom | Cause |
| --- | --- |
| "the Kokoro server is not answering" | agent down: `launchctl kickstart -k gui/$UID/com.petur.kokoro-tts` |
| "nothing recorded for the X pane yet" | that pane has not finished a turn since it started. Panes opened before the hook or `CLAUDE_SLOT` existed have no record; let one finish a turn |
| "nothing recorded for this project yet" | pressed outside a pane, and no CLI has run here — the Stop hook may not be wired up, see the manual step above |
| "Claude's last turn had nothing to say" | the turn ended in a tool call, with no summary to read |
| Nothing at all, in a pane | the mapping is registered by sidekick, so it needs a pane sidekick started. `<C-q>` then `<leader>tS` reaches any buffer and any pane |

## Limits

- **An interrupt is not a turn.** `Stop` does not fire when you press Esc, so the record
  still holds the previous turn and the button will replay it. The age is shown in the
  notification when the answer comes from the project fallback rather than the pane.
- `Stop` also does not fire while a permission prompt is waiting.
- Two Neovims pressing speak at once overlap; there is no shared playback lock.
- `~/.cache/claude-speak/` grows one directory per project, with no cleanup.
