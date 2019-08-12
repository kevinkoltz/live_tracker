/*jshint esversion: 6 */

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

let socket = new Socket("/tone");
socket.connect();

let channel = socket.channel("tracker:playback", {});

channel.join()
  .receive("ok", resp => {
    console.log("Joined successfully", resp);
  })
  .receive("error", resp => {
    console.log("Unable to join", resp);
  });

channel.on("play_note", msg => {
  instruments[msg.track].triggerAttackRelease(msg.note, msg.duration);
});

export default socket;