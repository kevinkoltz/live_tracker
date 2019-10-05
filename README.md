# LiveTracker

```text
.___   .___ ___    .____________._._____ .______ ._______ .____/\._______._____
:   |  : __|:  |___: ._____\__ _:: __   \:   _  \:_.  ___\:   /  \ .____/ __   \
|   |  | : |   |   | : _/\   |  :|  \____|   .   |  : |/\ |.  ___/ : _/\|  \____|
|   |/\|   |   :   |   /  \  |   |   :  \|   :   |    /  \|     \|   /  \   :  \
|   /  \   |\      |_.: __/  |   |   |___\___|   |. _____/|      \_.: __/   |___\
|______/___| \____/   :/     |___|___|       |___|:/      |___\  /  :/  |___|
                                                  :            \/           v.3030
```

An entry for the [Phoenix Phrenzy](https://phoenixphrenzy.com) contest.

First there was Amiga
[Soundtracker](https://en.wikipedia.org/wiki/Ultimate_Soundtracker) and
[ProTracker](https://en.wikipedia.org/wiki/ProTracker). Then DOS
[FastTracker](https://en.wikipedia.org/wiki/FastTracker_2). Now
[LiveView](https://github.com/phoenixframework/phoenix_live_view)
**LiveTracker**.

![LiveTracker preview](assets/static/images/preview.gif "LiveTracker")

## Overview

LiveTracker is a fun attempt to capture the quirkyness of early [music
trackers](https://en.wikipedia.org/wiki/Music_tracker). It uses
[LiveView](https://github.com/phoenixframework/phoenix_live_view) for the
user interface to capture notes being played from a computer keyboard while
displaying the song sequence realtime. Unlike traditional trackers,
LiveTracker does not load samples from a [module
file](https://en.wikipedia.org/wiki/Module_file)
([yet?](https://github.com/kevinkoltz/live_tracker/blob/master/lib/mod.ex)).
Instead, it uses a separate websocket connection `/tone` to send one-way
messages to [Tone.js](https://tonejs.github.io/) on the client side to play
samples in realtime (or close to it).

Note: LiveTracker currently works with Chrome (but not Safari). Safari
requires user interaction before the Web Audio API can play sounds.

## How to play

A demo can be viewed at
[https://livetracker.kevinkoltz.com](https://livetracker.kevinkoltz.com).

Notes can be played using built-in keyboard mappings:

- Play white notes `C4`-`C5` with keyboard keys `a`-`k` starting at the 4th octave.
- Black keys are `w` (`Cb4`), `e` (`Db4`), `t` (`Fb4`), `y` (`Gb4`), and `u` (`Ab4`).
- Octave can be shifted up or down using `z` and `x`, respectively.
- Select a track (instrument) using the `left` or `right` arrow keys.
- Press `m` to clear notes in the selected track (while recording).

## Font and Sample Credits

- [Commodore 64 Pixelized Free Font by Devin Cook](https://www.stockio.com/free-font/commodore-64-pixelized)
- [Pack of Free 8 Bit, Chippy, Glitchy, Lo-fi Sounds](https://woolyss.com/chipmusic-samples.php?s=THE+FREESOUND+PROJECT+-+Pack+of+Free+8+Bit,+Chippy,+Glitchy,+Lo-fi+Sounds)

## Wishlist

- Multiple users using [Phoenix.Presence](https://hexdocs.pm/phoenix/Phoenix.Presence.html)
  - Ability to record notes from multiple computers simultaneously
- Support for patterns (series of notes) and song edit (arrangement of patterns)
- Scale selector (shifts played notes to nearest key in scale)
- Ability to save sequences (maybe .mods too for export), along with autosave
  (for when things crash)
- VU Meters
  - [Tone.FFT](https://tonejs.github.io/examples/analysis.html)
  - or, just use a CSS animation when notes are played
- Support uploading and parsing of MOD files
  - [The Amiga MOD Format](https://www.ocf.berkeley.edu/~eek/index.html/tiny_examples/ptmod/ap12.html)
  - [MOD Music File Format](https://www.fileformat.info/format/mod/corion.htm)
- Sample/Instrument edit (Tone.js has many [options](https://tonejs.github.io/docs/r13/Sampler))
- Update status when LiveView loses connection
- Safari support, see [https://github.com/Tonejs/Tone.js/issues/518](https://github.com/Tonejs/Tone.js/issues/518)

## Deployment

How you deploy your app is up to you. A couple of the easiest options are:

- Heroku ([instructions](https://hexdocs.pm/phoenix/heroku.html))
- [Gigalixir](https://gigalixir.com/) (doesn't limit number of connections)
- [Render](https://render.com)

## The Usual README Content

To start your Phoenix server:

- Install dependencies with `mix deps.get`
- Create and migrate your database with `mix ecto.setup`
- Install Node.js dependencies with `cd assets && npm install && cd -`
- Start Phoenix endpoint with `mix phx.server`

Now you can visit [`localhost:4440`](http://localhost:4440) from your browser.

## Learn more

- [Music Tracker Wiki](https://en.wikipedia.org/wiki/Music_tracker)
- [Tracker's Handbook](https://resources.openmpt.org/tracker_handbook/handbook.htm)
- [Tracker History Graphing Project](http://helllabs.org/tracker-history/)
