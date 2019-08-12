# LiveTracker

```text
.___    .___ .___     .____________._.______  .______  ._______ .____/\ ._______.______
|   |   : __||   |___ : .____/\__ _:|: __   \ :      \ :_.  ___\:   /  \: .____/: __   \
|   |   | : ||   |   || : _/\   |  :||  \____||   .   ||  : |/\ |.  ___/| : _/\ |  \____|
|   |/\ |   ||   :   ||   /  \  |   ||   :  \ |   :   ||    /  \|     \ |   /  \|   :  \
|   /  \|   | \      ||_.: __/  |   ||   |___\|___|   ||. _____/|      \|_.: __/|   |___\
|______/|___|  \____/    :/     |___||___|        |___| :/      |___\  /   :/   |___|
                                                        :            \/             v.3030
```

Entry for [Phoenix Phrenzy](https://phoenixphrenzy.com) contest.

First there was Amiga [ProTracker](https://en.wikipedia.org/wiki/ProTracker),
then DOS [FastTracker](https://en.wikipedia.org/wiki/FastTracker_2),
and now [LiveView](https://github.com/phoenixframework/phoenix_live_view) **LiveTracker**.

![LiveTracker preview](assets/static/images/preview.gif "LiveTracker")

## Overview

LiveTracker is a fun attempt to capture the quirkyness of early [music
trackers](https://en.wikipedia.org/wiki/Music_tracker). It uses LiveView for the
user interface, music scheduling and recording. LiveTracker uses a separate
websocket connection `/tone` to send one-way messages to Tone.js on the client
side to generate sound in realtime (or close to it). Future support may include
loading of MOD files as parsing them is currently a work-in-progress
([lib/mod.ex](lib/mod.ex)).

## How to play

Notes can be played using built-in keyboard mappings:

- Play white notes `C4`-`C5` with keyboard keys `a`-`k` starting at the 4th octave.
- Black keys are `w` (`Cb4`), `e` (`Db4`), `t` (`Fb4`), `y` (`Gb4`), and `u` (`Ab4`).
- Octave can be shifted up or down using `z` and `x`, respectively.
- Select a track (instrument) using the `left` or `right` arrow keys.

## Font and Sample Credits

- [Commodore 64 Pixelized Free Font by Devin Cook](https://www.stockio.com/free-font/commodore-64-pixelized)
- [Pack of Free 8 Bit, Chippy, Glitchy, Lo-fi Sounds](https://woolyss.com/chipmusic-samples.php?s=THE+FREESOUND+PROJECT+-+Pack+of+Free+8+Bit,+Chippy,+Glitchy,+Lo-fi+Sounds)

## Wishlist

- Multiple users using [Phoenix.Presence](https://hexdocs.pm/phoenix/Phoenix.Presence.html)
  - Ability to record notes from multiple computers simultaneously
- Support for patterns (series of notes) and song edit (arrangement of patterns)
- Ability to save sequences (maybe .mods too for export)
- Support uploading and parsing of MOD files
  - [The Amiga MOD Format](https://www.ocf.berkeley.edu/~eek/index.html/tiny_examples/ptmod/ap12.html)
  - [MOD Music File Format](https://www.fileformat.info/format/mod/corion.htm)

## Phrenzy Instructions

Fork this repo and start build an application! See [Phoenix Phrenzy](https://phoenixphrenzy.com) for details.

Note: for development, you'll need Elixir, Erlang and Node.js. If you use the [asdf version manager](https://github.com/asdf-vm/asdf) and install the [relevant plugins](https://asdf-vm.com/#/plugins-all?id=plugin-list), you can install the versions specified in `.tool-versions` with `asdf install`.

## Deployment

How you deploy your app is up to you. A couple of the easiest options are:

- Heroku ([instructions](https://hexdocs.pm/phoenix/heroku.html))
- [Gigalixir](https://gigalixir.com/) (doesn't limit number of connections)

## The Usual README Content

To start your Phoenix server:

- Install dependencies with `mix deps.get`
- Create and migrate your database with `mix ecto.setup`
- Install Node.js dependencies with `cd assets && npm install`
- Start Phoenix endpoint with `mix phx.server`

Now you can visit [`localhost:4440`](http://localhost:4440) from your browser.

Ready to run in production? Please [check our deployment guides](https://hexdocs.pm/phoenix/deployment.html).

## Learn more

- Official website: http://www.phoenixframework.org/
- Guides: https://hexdocs.pm/phoenix/overview.html
- Docs: https://hexdocs.pm/phoenix
- Mailing list: http://groups.google.com/group/phoenix-talk
- Source: https://github.com/phoenixframework/phoenix
