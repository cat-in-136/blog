---
layout: post
title: getUserMedia() Frequency Characteristic depending on audio parameters
date: '2020-10-04T16:15:35+09:00'
tags:
- getUserMedia
- audio
---
Sound quality is not so good when sharing video/music in some browser-based online conference system.
In my qualitative research on this issue, I found that the parameters of `getUserMedia()` audio affect the sound quality.
This post describes this relations.

## Experiment Setup

<figure> {% asset_image_object_tag 2020-10-04-gum-frequency-characteristic-exp-chart.svg %}
<figcaption>Method of the experiment</figcaption>
</figure>

At first, I crate white noise using LADSPA's "White Noise Source".
I played it and routed it to the browser as a source (like as a microphone source).

I made a HTML/JavaScript code that output/loopback from the source to the speaker output and draw the waveform and spectrum on the canvas of the input.

[https://gist.github.com/cat-in-136/efe21ea1567c4fdf2b26187cbb0d4a86](https://gist.github.com/cat-in-136/efe21ea1567c4fdf2b26187cbb0d4a86)

Press the Start button to executes `getUserMedia()` and browser starts receiving audio from the source (white noise).
It outputs it to the speaker, and then does time/frequency analysis in [`AnalyserNode`](https://developer.mozilla.org/en-US/docs/Web/API/AnalyserNode).

Note that if the microphone and the speaker are close to each other, you may hear feedback, so I added a 1 second delay for safety.

```javascript
const audioCtx = new AudioContext();
const audioSrc = audioCtx.createMediaStreamSource(stream);
const synthDelay = audioCtx.createDelay();
synthDelay.delayTime.setValueAtTime(1, audioCtx.currentTime); // add 1 sec delay for safety.
const analyser = audioCtx.createAnalyser();
audioSrc.connect(synthDelay);
synthDelay.connect(audioCtx.destination);
synthDelay.connect(analyser);
```

I confirmed that changing the parameter settings ([`MediaTrackConstraints`](https://developer.mozilla.org/en-US/docs/Web/API/MediaTrackConstraints)) affects the waveforms/frequency characteristics.

I used the PulseAudio monitor device and I didn't use a *real microphone*, so there is no audio noise.
Of couse, the reproducibility of the quantization noise is not guaranteed because the audio level is adjusted at each stage in PulseAudio.

## Results

Chronium/Electron:

<blockquote class="twitter-tweet" data-conversation="none" data-dnt="true" data-theme="light"><p lang="en" dir="ltr">Frequency characteristic of WebRTC audio seems to be depending on audio parameter. <a href="https://t.co/0w2FIdkgKE">pic.twitter.com/0w2FIdkgKE</a></p>&mdash; cat_in_136 (@cat_in_136) <a href="https://twitter.com/cat_in_136/status/1264489740738297857?ref_src=twsrc%5Etfw">May 24, 2020</a></blockquote> <script async="async" src="https://platform.twitter.com/widgets.js" charset="utf-8"></script>

There was a big difference. In particular, it is worth noting that setting both `echoCancellation` and `noiseSuppression` to `false` yields flat frequency characteristics.



Firefox:

<blockquote class="twitter-tweet" data-conversation="none" data-dnt="true"><p lang="en" dir="ltr">Almost same as Firefox, but echoCancellation seems to be kinda unstable. <a href="https://t.co/NOf4ksJApc">pic.twitter.com/NOf4ksJApc</a></p>&mdash; cat_in_136 (@cat_in_136) <a href="https://twitter.com/cat_in_136/status/1264558026343628800?ref_src=twsrc%5Etfw">May 24, 2020</a></blockquote> <script async="async" src="https://platform.twitter.com/widgets.js" charset="utf-8"></script>

Almost same as Chronium/Electron (sorry for typo in my tweet), but

 * No matter how I tried, gain of near the high frequencies was lower, and I couldn't get completely flat frequency charactestics.
 * `echoCancellation` behaves unstable.
 * [`MediaStreamTrack.applyConstraints()`](https://developer.mozilla.org/en-US/docs/Web/API/MediaStreamTrack/applyConstraints) allows parameters to be dynamically set. It was useful for testing.

## Conclusion

In the web conferencing system on browser, the sound quality may deteriorate because the signal is filtered by the `getUserMedia()` setting, especially `echoCancellation` and `noiseSuppression`.
It is not due to the opus encoding and so on, but is done in the preprocessing.

Therefore, when shareing video/music and you are concerned about the sound quality, you should check the settings and make sure that `echoCancellation` and `noiseSuppression` are set to `false`.
On the other hand, if you're just making a voice call with a *real microphone*, these settings are useful and should be left at default.
