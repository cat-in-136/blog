---
layout: post
title: 'Noted: Apply pitch filter to live microphone on linux'
tags:
- gstreamer
- linux
- pulseaudio
date: '2020-05-05T18:12:34+09:00'
---

### TL;DR

    % pacmd load-module module-null-sink sink_name=NullSink
    % gst-launch-1.0 pulsesrc device=... ! pitch pitch=2 ! pulsesink device=NullSink
    % pavucontrol

### Null sink as a loopback device

At first, create a *null sink* to output the pitch-shifted audio to.

    % pacmd load-module module-null-sink sink_name=NullSink

[As written in the document](https://www.freedesktop.org/wiki/Software/PulseAudio/Documentation/User/Modules/#module-null-sink),
a null sink have a monitor source.

> All sinks have a corresponding "monitor" source which makes the null sink a practical way to plumb output to input.

So, we can use it as a loopback device.
i.e. It means to output pitch-shifted audio to the null device and
use the monitor device as a recording device.


### Apply filter on GStreamer

To check the microphone device name, execute `pacmd list-sources | grep name`.

    % pacmd list-sources | grep name
            name: <alsa_output.usb-XXXX_USB_PnP_Audio_Device-XX.analog-stereo.monitor>
            name: <alsa_input.usb-XXXX_USB_PnP_Audio_Device-XX.mono-fallback>
            name: <alsa_output.pci-XXXX_XX_XX.X.analog-stereo.monitor>
            name: <alsa_input.pci-XXXX_XX_XX.X.analog-stereo>
            name: <NullSink.monitor>
            name: <alsa_output.pci-XXXX_XX_XX.X.hdmi-stereo-extraX.monitor>

Device names ending in `.monitor` means monitor devices, not actual microphones.
In this example, following devices are actual microphones:

 * `alsa_input.usb-XXXX_USB_PnP_Audio_Device-XX.mono-fallback`
 * `alsa_input.pci-XXXX_XX_XX.X.analog-stereo`

Here, let's apply a `pitch` filter to the first device (USB-connected microphone).

    % gst-launch-1.0 pulsesrc device=alsa_input.usb-XXXX_USB_PnP_Audio_Device-XX.mono-fallback ! \
        pitch pitch=2 ! \
        pulsesink device=NullSink

Of cause, replace `device=...` with microphone device name of your environment.

FYI: source device and sink device can be dynamically reconfigurable
by PulseAudio Volume Control as describe on the next section.

### Application-specific audio device

PulseAudio can control playback device and recording device per application.
Change the recording device to null sink for the app you want to use.
It can change dynamically!

For example, you can change the recording device for *Skype* app
by clicking the button (highlighted with red box) on PulseAudio Volume Control.

<figure>
{% asset_image_tag 2020-05-05-noted-apply-pitch-filter-to-live-microphone-pavucontrol.svg %}
<figcaption>Screenshot of PulseAudio Volume Control</figcaption>
</figure>

Choose the null sink, and then pitch-shifted voice will sent to Skype app.

### References

 * [Modules](https://www.freedesktop.org/wiki/Software/PulseAudio/Documentation/User/Modules/), PulseAudio Document
 * [pitch](https://gstreamer.freedesktop.org/documentation/soundtouch/pitch.html), GStreamer API References
 * [LinuxにおけるSkypeとPulseaudioを用いたスプリット/ミキシング - Chienomi](https://chienomi.org/archives/livewithlinux/1069)
