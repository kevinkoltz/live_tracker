/*jshint esversion: 6 */

/*

This file sets up the samples for Tone.js to play and listens on a separate socket
for incoming notes to play. Currently, they are a fixed set of samples.
Sample editing support is on the future wishlist, along with sample loading
from existing modules and/or uploading of samples.

It may make sense to use the new phx-hook feature for configuring Tone.js if
more features are added here:

https: //hexdocs.pm/phoenix_live_view/Phoenix.LiveView.html#module-js-interop-and-client-controlled-dom

*/

import {
  Socket
} from "phoenix";

let chip = new Tone.Sampler({
  "C4": "./samples/31872_HardPCM_Chip035.wav"
}).toMaster();

let meow = new Tone.Sampler({
  "C4": "./samples/69219_meowtek_bitline4A.wav"
}).toMaster();

let pause = new Tone.Sampler({
  "C4": "./samples/12910_sweet_trip_mm_clap_mid.wav"
}).toMaster();

let irrlicht = new Tone.Sampler({
  "C4": "./samples/42341_irrlicht_and.wav"
}).toMaster();


// TODO: set these when the channel is joined
let instruments = [
  chip,
  irrlicht,
  pause,
  meow,
];

// Web Audio playback is allowed when the user interacts with the page.
// https://github.com/Tonejs/Tone.js/#starting-audio
// https://developers.google.com/web/updates/2017/09/autoplay-policy-changes#webaudio
document.querySelector("body").addEventListener("click", function() {
  Tone.start();
});

let socket = new Socket("/tone");
socket.connect();

let url = new URL(window.location.href);
let songId = url.searchParams.get("song_id");

if (songId) {
  let channel = socket.channel(`tracker:${songId}`, {});

  channel.join()
    .receive("ok", resp => {
      console.log("Joined successfully", resp);
    })
    .receive("error", resp => {
      console.log("Unable to join", resp);
    });

  channel.on("play_note", msg => {
    instruments[msg.track].triggerAttackRelease(msg.note, msg.duration);
    // console.debug("play_note", msg)
  });
}

export default socket;