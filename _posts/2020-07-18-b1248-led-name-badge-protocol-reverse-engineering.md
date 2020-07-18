---
layout: post
title: B1248 LED name badge protocol reverse engineering
thumbnail: "{% asset_image_path 2020-07-18-B1248-website-121.jpg %}"
tags:
- LED
- Reverse engineering
- Gadget
date: '2020-07-18T21:17:33+09:00'
---

## General informations

* VID:PID - 0483:5750
* Product ID: `STMicroelectronics LED badge -- mini LED display -- 11x44`
* uses HID Protocol
* 64 byte packet size

### Appearance

<figure>
{% asset_image_tag 2020-07-18-B1248_and_package.jpg %}
<figcaption>B1248 and its package</figcaption>
</figure>

<figure>
{% asset_image_tag 2020-07-18-B1248-back.jpg %}
<figcaption>B1248 backview (without magnet)</figcaption>
</figure>

<figure>
{% asset_image_tag 2020-07-18-B1248-website-121.jpg %}
<figcaption>B1248 Usecase (captured from the manufactor material)</figcaption>
</figure>

* Name: MINI LED DISPLAY / LED NAME BADGE
* Model: B1248
* Manufactor: (would be...) [Shenzhen TBD Optoelectric Technology Co., Ltd (深圳市特邦达光电科技有限公司)](http://tbdled.com/Product/detail/l/cn/id/36.html)
* Size: 93x20x6 (mm)
* Pixels: 11x44

## The Protocol

Report size: 64 byte (rep_num+data[64])

### Header (first report to send):

```
id[5]: "Hello"
padding[59]: all 0x00
```

### Second report:

```
0000   00 00 10 22 33 44 55 66 77 00 08 00 00 03 08 03
          ^^ -------------------------------------------- 1st message Frame/Speed/Blink/Effect
             ^^ ----------------------------------------- 2nd message Frame/Speed/Blink/Effect
                    ...
                               ^^ ----------------------- 8th message Frame/Speed/Blink/Effect
                                     ^^^^^^^^^^^ -------- message offset/length 1st
                                                 ^^^^^ -- message offset/length 2nd

0010   00 00 08 03 00 00 08 03 00 00 08 03 00 00 08 03
       ^^^^^ -------------------------------------------- message offset/length 2nd
              ...
0020   00 00 08 03 00 00 08 03 00 00 00 00 00 00 00 00
                ...
                         ^^^^^^^^^^^ -------------------- message offset/length 8th

0030   00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
```

Frame/Speed/Blink/Effect coding:
```
0bFSSSBEEE
  ^ -------- 0: no frame, 1: frame
   ^^^ ----- Scrolling speed [0..7]
      ^ ---- 0: no blink, 1: blink
       ^^^ - Effect number [0..7]
```

Message offset/length coding:
```
08 00 00 01
^^ ---------- Fix number to indicate the coding
   ^^ ------- Offset to starting message data (set a proper value even if the message length is zero)
      ^^ ---- ? (should be set to zero)
         ^^ - Message length (0 indicats "disabled")
```

### Data frames/messages(3rd-15th reports):

Each report corresponds to each line.
The last report is dummy and ignored. Because the LED is not 12-line but 11-line.

The 1st bit (MSB) of the 1st byte corresponds to most left pixel, and
The 2nd bit corresponds to 2nd left pixel, and so on.

For example, when 1st message length is set to 1 and 2nd message offset is set to 1 and 2nd message length is set to 2:

```
1st line (3rd report)
  11 22 33 00 00 ...
  ^^ --------------- 1st line (top), 1st message
     ^^^^^ --------- 1st line (top), 2nd message

2nd line (4th report)
  11 22 33 00 00 ...
  ^^ --------------- 2nd line, 1st message
     ^^^^^ --------- 2nd line, 2nd message

...

11th line (14th report)
  11 22 33 00 00 ...
  ^^ --------------- 11th line, 1st message
     ^^^^^ --------- 11th line, 2nd message

dummy line (15th report)
  00 00 00 ...
  ^^^^^^^^ --- ignored
```

The case that total sum of message length is larger than 64 is FFS.

## See also

* B1248 is very similar looking to another LED name badge products but the protocol is very different than others.
  * [XANES X1 Programmable LED light badge protocoll reverse engineering](XANES X1 Programmable LED light badge protocoll reverse engineering)
  * [IoT - Reverse engineering a Bluetooth LED name badge](http://nilhcem.com/iot/reverse-engineering-bluetooth-led-name-badge)
* [cat-in-136/led-name-badge: USB LED name badge control tool](https://github.com/cat-in-136/led-name-badge)
