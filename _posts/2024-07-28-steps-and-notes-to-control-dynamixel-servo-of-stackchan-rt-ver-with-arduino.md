---
layout: post
title: Arduinoでｽﾀｯｸﾁｬﾝ アールティver.のDynamixelサーボを操作する手順と注意点
tags:
- ｽﾀｯｸﾁｬﾝ
- stackchan
- DYNAMIXEL
thumbnail: https://live.staticflickr.com/65535/53856188253_8a838ddec6_b.jpg
date: '2024-07-28T07:25:54+09:00'
---
**ｽﾀｯｸﾁｬﾝ アールティver.** は、株式会社アールティが開発・販売する手のひらサイズの小型ロボットで2024年6月上旬に発売された。
このロボットは、オリジナルのｽﾀｯｸﾁｬﾝ（通称ししかわ版）をベースに、さまざまな改良が加えられている。（β版は2023年に少量販売されたが仕様が異なる）

アールティver.の特徴として、DYNAMIXELサーボと M5Stack CoreS3 を採用していることが挙げられる。
資料がネット上にもそう多くなく自作コードに書き換えて動作させるときにたいへん苦労したのでここに記すものとする。

<figure>
<a data-flickr-embed="true" href="https://www.flickr.com/photos/27992339@N00/53856188253" title="Stack-chan and Hydrangea"><img src="https://live.staticflickr.com/65535/53856188253_84739caca3_k.jpg" width="2048" height="1365" alt="Stack-chan and Hydrangea"/></a><script async="async" src="https://embedr.flickr.com/assets/client-code.js" charset="utf-8"></script>
<figcaption>Stack-chan and Hydrangea</figcaption>
</figure>

## ピン配置

ｽﾀｯｸﾁｬﾝ アールティver. で使用される M5Stack CoreS3 のピン配置について、 M-BUS の 2x15 ピンの配列に合わせて記載すると下記のようになる。
ここでは M5Stack の回路図に従い、背面から覗く方向で左上を1番ピン、その右を2番ピンのように記載した。

<table>
    <caption>M5Stack CoreS3 Pin Assignment</caption>
	<thead><tr>
		<th>Note</th>
		<th>GPIO</th>
		<th>Analog</th>
		<th></th>
		<th></th>
		<th></th>
		<th></th>
		<th></th>
		<th></th>
		<th>Analog</th>
		<th>GPIO</th>
		<th>Note</th>
	</tr></thead>
	<tbody><tr>
		<td style="border-top: 1px solid #000000; border-bottom: 1px solid #000000; border-left: 1px solid #000000; border-right: 1px solid #000000"></td>
		<td style="border-top: 1px solid #000000; border-bottom: 1px solid #000000; border-left: 1px solid #000000; border-right: 1px solid #000000"></td>
		<td style="border-top: 1px solid #000000; border-bottom: 1px solid #000000; border-left: 1px solid #000000; border-right: 1px solid #000000"></td>
		<td style="border-top: 1px solid #000000; border-bottom: 1px solid #000000; border-left: 1px solid #000000; border-right: 1px solid #000000"></td>
		<td style="border-top: 1px solid #000000; border-bottom: 1px solid #000000; border-left: 1px solid #000000; border-right: 1px solid #000000; background-color: #000000; color: #FFFFFF">GND</td>
		<td style="border-top: 1px solid #000000; border-left: 1px solid #000000; background-color: #FFFFFF; color: #808080">1</td>
		<td style="border-top: 1px solid #000000; border-right: 1px solid #000000; background-color: #FFFFFF; color: #808080">2</td>
		<td style="border-top: 1px solid #000000; border-bottom: 1px solid #000000; border-left: 1px solid #000000; border-right: 1px solid #000000; background-color: #134F5C; color: #FFFFFF">ADC</td>
		<td style="border-top: 1px solid #000000; border-bottom: 1px solid #000000; border-left: 1px solid #000000; border-right: 1px solid #000000; background-color: #FFFFFF; color: #000000">G10</td>
		<td style="border-top: 1px solid #000000; border-bottom: 1px solid #000000; border-left: 1px solid #000000; border-right: 1px solid #000000; background-color: #FFFFFF; color: #000000">ADC1_CH9/T10</td>
		<td style="border-top: 1px solid #000000; border-bottom: 1px solid #000000; border-left: 1px solid #000000; border-right: 1px solid #000000; background-color: #FFFFFF; color: #000000">I/O/T</td>
		<td style="border-top: 1px solid #000000; border-bottom: 1px solid #000000; border-left: 1px solid #000000; border-right: 1px solid #000000"></td>
	</tr>
	<tr>
		<td style="border-top: 1px solid #000000; border-bottom: 1px solid #000000; border-left: 1px solid #000000; border-right: 1px solid #000000"></td>
		<td style="border-top: 1px solid #000000; border-bottom: 1px solid #000000; border-left: 1px solid #000000; border-right: 1px solid #000000"></td>
		<td style="border-top: 1px solid #000000; border-bottom: 1px solid #000000; border-left: 1px solid #000000; border-right: 1px solid #000000"></td>
		<td style="border-top: 1px solid #000000; border-bottom: 1px solid #000000; border-left: 1px solid #000000; border-right: 1px solid #000000"></td>
		<td style="border-top: 1px solid #000000; border-bottom: 1px solid #000000; border-left: 1px solid #000000; border-right: 1px solid #000000; background-color: #000000; color: #FFFFFF">GND</td>
		<td style="border-left: 1px solid #000000; background-color: #FFFFFF; color: #808080">3</td>
		<td style="border-right: 1px solid #000000; background-color: #FFFFFF; color: #808080">4</td>
		<td style="border-top: 1px solid #000000; border-bottom: 1px solid #000000; border-left: 1px solid #000000; border-right: 1px solid #000000; background-color: #666666; color: #FFFFFF">PB_IN</td>
		<td style="border-top: 1px solid #000000; border-bottom: 1px solid #000000; border-left: 1px solid #000000; border-right: 1px solid #000000; background-color: #FFFFFF; color: #000000">G8</td>
		<td style="border-top: 1px solid #000000; border-bottom: 1px solid #000000; border-left: 1px solid #000000; border-right: 1px solid #000000; background-color: #FFFFFF; color: #000000">ADC1_CH7/T8</td>
		<td style="border-top: 1px solid #000000; border-bottom: 1px solid #000000; border-left: 1px solid #000000; border-right: 1px solid #000000; background-color: #FFFFFF; color: #000000">I/O/T</td>
		<td style="border-top: 1px solid #000000; border-bottom: 1px solid #000000; border-left: 1px solid #000000; border-right: 1px solid #000000; background-color: #FFFFFF; color: #000000">PortB</td>
	</tr>
	<tr>
		<td style="border-top: 1px solid #000000; border-bottom: 1px solid #000000; border-left: 1px solid #000000; border-right: 1px solid #000000"></td>
		<td style="border-top: 1px solid #000000; border-bottom: 1px solid #000000; border-left: 1px solid #000000; border-right: 1px solid #000000"></td>
		<td style="border-top: 1px solid #000000; border-bottom: 1px solid #000000; border-left: 1px solid #000000; border-right: 1px solid #000000"></td>
		<td style="border-top: 1px solid #000000; border-bottom: 1px solid #000000; border-left: 1px solid #000000; border-right: 1px solid #000000"></td>
		<td style="border-top: 1px solid #000000; border-bottom: 1px solid #000000; border-left: 1px solid #000000; border-right: 1px solid #000000; background-color: #000000; color: #FFFFFF">GND</td>
		<td style="border-left: 1px solid #000000; background-color: #FFFFFF; color: #808080">5</td>
		<td style="border-right: 1px solid #000000; background-color: #FFFFFF; color: #808080">6</td>
		<td style="border-top: 1px solid #000000; border-bottom: 1px solid #000000; border-left: 1px solid #000000; border-right: 1px solid #000000; background-color: #D9D9D9; color: #000000">RST/EN</td>
		<td style="border-top: 1px solid #000000; border-bottom: 1px solid #000000; border-left: 1px solid #000000; border-right: 1px solid #000000"></td>
		<td style="border-top: 1px solid #000000; border-bottom: 1px solid #000000; border-left: 1px solid #000000; border-right: 1px solid #000000"></td>
		<td style="border-top: 1px solid #000000; border-bottom: 1px solid #000000; border-left: 1px solid #000000; border-right: 1px solid #000000"></td>
		<td style="border-top: 1px solid #000000; border-bottom: 1px solid #000000; border-left: 1px solid #000000; border-right: 1px solid #000000"></td>
	</tr>
	<tr>
		<td style="border-top: 1px solid #000000; border-bottom: 1px solid #000000; border-left: 1px solid #000000; border-right: 1px solid #000000; background-color: #FFFFFF; color: #000000">LCD,SD</td>
		<td style="border-top: 1px solid #000000; border-bottom: 1px solid #000000; border-left: 1px solid #000000; border-right: 1px solid #000000; background-color: #FFFFFF; color: #000000">I/O/T</td>
		<td style="border-top: 1px solid #000000; border-bottom: 1px solid #000000; border-left: 1px solid #000000; border-right: 1px solid #000000"></td>
		<td style="border-top: 1px solid #000000; border-bottom: 1px solid #000000; border-left: 1px solid #000000; border-right: 1px solid #000000; background-color: #FFFFFF; color: #000000">G37</td>
		<td style="border-top: 1px solid #000000; border-bottom: 1px solid #000000; border-left: 1px solid #000000; border-right: 1px solid #000000; background-color: #4BACC6; color: #000000">MOSI</td>
		<td style="border-left: 1px solid #000000; background-color: #FFFFFF; color: #808080">7</td>
		<td style="border-right: 1px solid #000000; background-color: #FFFFFF; color: #808080">8</td>
		<td style="border-top: 1px solid #000000; border-bottom: 1px solid #000000; border-left: 1px solid #000000; border-right: 1px solid #000000; background-color: #FCE5CD; color: #000000">GPIO</td>
		<td style="border-top: 1px solid #000000; border-bottom: 1px solid #000000; border-left: 1px solid #000000; border-right: 1px solid #000000; background-color: #FFFFFF; color: #000000">G5</td>
		<td style="border-top: 1px solid #000000; border-bottom: 1px solid #000000; border-left: 1px solid #000000; border-right: 1px solid #000000; background-color: #FFFFFF; color: #000000">ADC1_CH4/T5</td>
		<td style="border-top: 1px solid #000000; border-bottom: 1px solid #000000; border-left: 1px solid #000000; border-right: 1px solid #000000; background-color: #FFFFFF; color: #000000">I/O/T</td>
		<td style="border-top: 1px solid #000000; border-bottom: 1px solid #000000; border-left: 1px solid #000000; border-right: 1px solid #000000"></td>
	</tr>
	<tr>
		<td style="border-top: 1px solid #000000; border-bottom: 1px solid #000000; border-left: 1px solid #000000; border-right: 1px solid #000000; background-color: #FFFFFF; color: #000000">LCD,SD</td>
		<td style="border-top: 1px solid #000000; border-bottom: 1px solid #000000; border-left: 1px solid #000000; border-right: 1px solid #000000; background-color: #FFFFFF; color: #000000">I/O/T</td>
		<td style="border-top: 1px solid #000000; border-bottom: 1px solid #000000; border-left: 1px solid #000000; border-right: 1px solid #000000"></td>
		<td style="border-top: 1px solid #000000; border-bottom: 1px solid #000000; border-left: 1px solid #000000; border-right: 1px solid #000000; background-color: #FFFFFF; color: #000000">G35</td>
		<td style="border-top: 1px solid #000000; border-bottom: 1px solid #000000; border-left: 1px solid #000000; border-right: 1px solid #000000; background-color: #4BACC6; color: #000000">MISO</td>
		<td style="border-left: 1px solid #000000; background-color: #FFFFFF; color: #808080">9</td>
		<td style="border-right: 1px solid #000000; background-color: #FFFFFF; color: #808080">10</td>
		<td style="border-top: 1px solid #000000; border-bottom: 1px solid #000000; border-left: 1px solid #000000; border-right: 1px solid #000000; background-color: #666666; color: #FFFFFF">PB_OUT</td>
		<td style="border-top: 1px solid #000000; border-bottom: 1px solid #000000; border-left: 1px solid #000000; border-right: 1px solid #000000; background-color: #FFFFFF; color: #000000">G9</td>
		<td style="border-top: 1px solid #000000; border-bottom: 1px solid #000000; border-left: 1px solid #000000; border-right: 1px solid #000000; background-color: #FFFFFF; color: #000000">ADC1_CH8/T9</td>
		<td style="border-top: 1px solid #000000; border-bottom: 1px solid #000000; border-left: 1px solid #000000; border-right: 1px solid #000000; background-color: #FFFFFF; color: #000000">I/O/T</td>
		<td style="border-top: 1px solid #000000; border-bottom: 1px solid #000000; border-left: 1px solid #000000; border-right: 1px solid #000000; background-color: #FFFFFF; color: #000000">PortB</td>
	</tr>
	<tr>
		<td style="border-top: 1px solid #000000; border-bottom: 1px solid #000000; border-left: 1px solid #000000; border-right: 1px solid #000000; background-color: #FFFFFF; color: #000000">LCD,SD</td>
		<td style="border-top: 1px solid #000000; border-bottom: 1px solid #000000; border-left: 1px solid #000000; border-right: 1px solid #000000; background-color: #FFFFFF; color: #000000">I/O/T</td>
		<td style="border-top: 1px solid #000000; border-bottom: 1px solid #000000; border-left: 1px solid #000000; border-right: 1px solid #000000"></td>
		<td style="border-top: 1px solid #000000; border-bottom: 1px solid #000000; border-left: 1px solid #000000; border-right: 1px solid #000000; background-color: #FFFFFF; color: #000000">G36</td>
		<td style="border-top: 1px solid #000000; border-bottom: 1px solid #000000; border-left: 1px solid #000000; border-right: 1px solid #000000; background-color: #4BACC6; color: #000000">SCK</td>
		<td style="border-left: 1px solid #000000; background-color: #FFFFFF; color: #808080">11</td>
		<td style="border-right: 1px solid #000000; background-color: #FFFFFF; color: #808080">12</td>
		<td style="border-top: 1px solid #000000; border-bottom: 1px solid #000000; border-left: 1px solid #000000; border-right: 1px solid #000000; background-color: #CC0000; color: #FFFFFF">3.3V</td>
		<td style="border-top: 1px solid #000000; border-bottom: 1px solid #000000; border-left: 1px solid #000000; border-right: 1px solid #000000"></td>
		<td style="border-top: 1px solid #000000; border-bottom: 1px solid #000000; border-left: 1px solid #000000; border-right: 1px solid #000000"></td>
		<td style="border-top: 1px solid #000000; border-bottom: 1px solid #000000; border-left: 1px solid #000000; border-right: 1px solid #000000"></td>
		<td style="border-top: 1px solid #000000; border-bottom: 1px solid #000000; border-left: 1px solid #000000; border-right: 1px solid #000000"></td>
	</tr>
	<tr>
		<td style="border-top: 1px solid #000000; border-bottom: 1px solid #000000; border-left: 1px solid #000000; border-right: 1px solid #000000"></td>
		<td style="border-top: 1px solid #000000; border-bottom: 1px solid #000000; border-left: 1px solid #000000; border-right: 1px solid #000000; background-color: #FFFFFF; color: #000000">I1</td>
		<td style="border-top: 1px solid #000000; border-bottom: 1px solid #000000; border-left: 1px solid #000000; border-right: 1px solid #000000"></td>
		<td style="border-top: 1px solid #000000; border-bottom: 1px solid #000000; border-left: 1px solid #000000; border-right: 1px solid #000000; background-color: #FFFFFF; color: #000000">G44</td>
		<td style="border-top: 1px solid #000000; border-bottom: 1px solid #000000; border-left: 1px solid #000000; border-right: 1px solid #000000; background-color: #FFFFFF; color: #000000">RXD0</td>
		<td style="border-left: 1px solid #000000; background-color: #FFFFFF; color: #808080">13</td>
		<td style="border-right: 1px solid #000000; background-color: #FFFFFF; color: #808080">14</td>
		<td style="border-top: 1px solid #000000; border-bottom: 1px solid #000000; border-left: 1px solid #000000; border-right: 1px solid #000000; background-color: #FFFFFF; color: #000000">TXD0</td>
		<td style="border-top: 1px solid #000000; border-bottom: 1px solid #000000; border-left: 1px solid #000000; border-right: 1px solid #000000; background-color: #FFFFFF; color: #000000">G43</td>
		<td style="border-top: 1px solid #000000; border-bottom: 1px solid #000000; border-left: 1px solid #000000; border-right: 1px solid #000000"></td>
		<td style="border-top: 1px solid #000000; border-bottom: 1px solid #000000; border-left: 1px solid #000000; border-right: 1px solid #000000; background-color: #FFFFFF; color: #000000">O</td>
		<td style="border-top: 1px solid #000000; border-bottom: 1px solid #000000; border-left: 1px solid #000000; border-right: 1px solid #000000"></td>
	</tr>
	<tr>
		<td style="border-top: 1px solid #000000; border-bottom: 1px solid #000000; border-left: 1px solid #000000; border-right: 1px solid #000000; background-color: #FFFFFF; color: #000000">PortC</td>
		<td style="border-top: 1px solid #000000; border-bottom: 1px solid #000000; border-left: 1px solid #000000; border-right: 1px solid #000000; background-color: #FFFFFF; color: #000000">I/O/T</td>
		<td style="border-top: 1px solid #000000; border-bottom: 1px solid #000000; border-left: 1px solid #000000; border-right: 1px solid #000000; background-color: #FFFFFF; color: #000000">ADC2_CH7</td>
		<td style="border-top: 1px solid #000000; border-bottom: 1px solid #000000; border-left: 1px solid #000000; border-right: 1px solid #000000; background-color: #FFFFFF; color: #000000">G18</td>
		<td style="border-top: 1px solid #000000; border-bottom: 1px solid #000000; border-left: 1px solid #000000; border-right: 1px solid #000000; background-color: #1155CC; color: #FFFFFF">PC_RX</td>
		<td style="border-left: 1px solid #000000; background-color: #FFFFFF; color: #808080">15</td>
		<td style="border-right: 1px solid #000000; background-color: #FFFFFF; color: #808080">16</td>
		<td style="border-top: 1px solid #000000; border-bottom: 1px solid #000000; border-left: 1px solid #000000; border-right: 1px solid #000000; background-color: #1155CC; color: #FFFFFF">PC_TX</td>
		<td style="border-top: 1px solid #000000; border-bottom: 1px solid #000000; border-left: 1px solid #000000; border-right: 1px solid #000000; background-color: #FFFFFF; color: #000000">G17</td>
		<td style="border-top: 1px solid #000000; border-bottom: 1px solid #000000; border-left: 1px solid #000000; border-right: 1px solid #000000; background-color: #FFFFFF; color: #000000">ADC2_CH6</td>
		<td style="border-top: 1px solid #000000; border-bottom: 1px solid #000000; border-left: 1px solid #000000; border-right: 1px solid #000000; background-color: #FFFFFF; color: #000000">I/O/T</td>
		<td style="border-top: 1px solid #000000; border-bottom: 1px solid #000000; border-left: 1px solid #000000; border-right: 1px solid #000000; background-color: #FFFFFF; color: #000000">PortC</td>
	</tr>
	<tr>
		<td style="border-top: 1px solid #000000; border-bottom: 1px solid #000000; border-left: 1px solid #000000; border-right: 1px solid #000000; background-color: #FFFFFF; color: #000000">I2C_SYS</td>
		<td style="border-top: 1px solid #000000; border-bottom: 1px solid #000000; border-left: 1px solid #000000; border-right: 1px solid #000000; background-color: #FFFFFF; color: #000000">I/O/T</td>
		<td style="border-top: 1px solid #000000; border-bottom: 1px solid #000000; border-left: 1px solid #000000; border-right: 1px solid #000000; background-color: #FFFFFF; color: #000000">ADC2_CH1/T12</td>
		<td style="border-top: 1px solid #000000; border-bottom: 1px solid #000000; border-left: 1px solid #000000; border-right: 1px solid #000000; background-color: #FFFFFF; color: #000000">G12</td>
		<td style="border-top: 1px solid #000000; border-bottom: 1px solid #000000; border-left: 1px solid #000000; border-right: 1px solid #000000; background-color: #E69138; color: #FFFFFF">intSDA</td>
		<td style="border-left: 1px solid #000000; background-color: #FFFFFF; color: #808080">17</td>
		<td style="border-right: 1px solid #000000; background-color: #FFFFFF; color: #808080">18</td>
		<td style="border-top: 1px solid #000000; border-bottom: 1px solid #000000; border-left: 1px solid #000000; border-right: 1px solid #000000; background-color: #E69138; color: #FFFFFF">intSCL</td>
		<td style="border-top: 1px solid #000000; border-bottom: 1px solid #000000; border-left: 1px solid #000000; border-right: 1px solid #000000; background-color: #FFFFFF; color: #000000">G11</td>
		<td style="border-top: 1px solid #000000; border-bottom: 1px solid #000000; border-left: 1px solid #000000; border-right: 1px solid #000000; background-color: #FFFFFF; color: #000000">ADC2_CH0/T11</td>
		<td style="border-top: 1px solid #000000; border-bottom: 1px solid #000000; border-left: 1px solid #000000; border-right: 1px solid #000000; background-color: #FFFFFF; color: #000000">I/O/T</td>
		<td style="border-top: 1px solid #000000; border-bottom: 1px solid #000000; border-left: 1px solid #000000; border-right: 1px solid #000000; background-color: #FFFFFF; color: #000000">I2C_SYS</td>
	</tr>
	<tr>
		<td style="border-top: 1px solid #000000; border-bottom: 1px solid #000000; border-left: 1px solid #000000; border-right: 1px solid #000000; background-color: #FFFFFF; color: #000000">PortA</td>
		<td style="border-top: 1px solid #000000; border-bottom: 1px solid #000000; border-left: 1px solid #000000; border-right: 1px solid #000000; background-color: #FFFFFF; color: #000000">I/O/T</td>
		<td style="border-top: 1px solid #000000; border-bottom: 1px solid #000000; border-left: 1px solid #000000; border-right: 1px solid #000000; background-color: #FFFFFF; color: #000000">ADC1_CH1/T2</td>
		<td style="border-top: 1px solid #000000; border-bottom: 1px solid #000000; border-left: 1px solid #000000; border-right: 1px solid #000000; background-color: #FFFFFF; color: #000000">G2</td>
		<td style="border-top: 1px solid #000000; border-bottom: 1px solid #000000; border-left: 1px solid #000000; border-right: 1px solid #000000; background-color: #E06666; color: #FFFFFF">PA_SDA</td>
		<td style="border-left: 1px solid #000000; background-color: #FFFFFF; color: #808080">19</td>
		<td style="border-right: 1px solid #000000; background-color: #FFFFFF; color: #808080">20</td>
		<td style="border-top: 1px solid #000000; border-bottom: 1px solid #000000; border-left: 1px solid #000000; border-right: 1px solid #000000; background-color: #E06666; color: #FFFFFF">PA_SCL</td>
		<td style="border-top: 1px solid #000000; border-bottom: 1px solid #000000; border-left: 1px solid #000000; border-right: 1px solid #000000; background-color: #FFFFFF; color: #000000">G1</td>
		<td style="border-top: 1px solid #000000; border-bottom: 1px solid #000000; border-left: 1px solid #000000; border-right: 1px solid #000000; background-color: #FFFFFF; color: #000000">ADC1_CH0/T1</td>
		<td style="border-top: 1px solid #000000; border-bottom: 1px solid #000000; border-left: 1px solid #000000; border-right: 1px solid #000000; background-color: #FFFFFF; color: #000000">I/O/T</td>
		<td style="border-top: 1px solid #000000; border-bottom: 1px solid #000000; border-left: 1px solid #000000; border-right: 1px solid #000000; background-color: #FFFFFF; color: #000000">PortA</td>
	</tr>
	<tr>
		<td style="border-top: 1px solid #000000; border-bottom: 1px solid #000000; border-left: 1px solid #000000; border-right: 1px solid #000000"></td>
		<td style="border-top: 1px solid #000000; border-bottom: 1px solid #000000; border-left: 1px solid #000000; border-right: 1px solid #000000; background-color: #FFFFFF; color: #000000">I/O/T</td>
		<td style="border-top: 1px solid #000000; border-bottom: 1px solid #000000; border-left: 1px solid #000000; border-right: 1px solid #000000; background-color: #FFFFFF; color: #000000">ADC1_CH5/T6</td>
		<td style="border-top: 1px solid #000000; border-bottom: 1px solid #000000; border-left: 1px solid #000000; border-right: 1px solid #000000; background-color: #FFFFFF; color: #000000">G6</td>
		<td style="border-top: 1px solid #000000; border-bottom: 1px solid #000000; border-left: 1px solid #000000; border-right: 1px solid #000000; background-color: #FCE5CD; color: #000000">GPIO</td>
		<td style="border-left: 1px solid #000000; background-color: #FFFFFF; color: #808080">21</td>
		<td style="border-right: 1px solid #000000; background-color: #FFFFFF; color: #808080">22</td>
		<td style="border-top: 1px solid #000000; border-bottom: 1px solid #000000; border-left: 1px solid #000000; border-right: 1px solid #000000; background-color: #FCE5CD; color: #000000">GPIO</td>
		<td style="border-top: 1px solid #000000; border-bottom: 1px solid #000000; border-left: 1px solid #000000; border-right: 1px solid #000000; background-color: #FFFFFF; color: #000000">G7</td>
		<td style="border-top: 1px solid #000000; border-bottom: 1px solid #000000; border-left: 1px solid #000000; border-right: 1px solid #000000; background-color: #FFFFFF; color: #000000">ADC1_CH6/T7</td>
		<td style="border-top: 1px solid #000000; border-bottom: 1px solid #000000; border-left: 1px solid #000000; border-right: 1px solid #000000; background-color: #FFFFFF; color: #000000">I/O/T</td>
		<td style="border-top: 1px solid #000000; border-bottom: 1px solid #000000; border-left: 1px solid #000000; border-right: 1px solid #000000"></td>
	</tr>
	<tr>
		<td style="border-top: 1px solid #000000; border-bottom: 1px solid #000000; border-left: 1px solid #000000; border-right: 1px solid #000000"></td>
		<td style="border-top: 1px solid #000000; border-bottom: 1px solid #000000; border-left: 1px solid #000000; border-right: 1px solid #000000; background-color: #FFFFFF; color: #000000">I/O/T</td>
		<td style="border-top: 1px solid #000000; border-bottom: 1px solid #000000; border-left: 1px solid #000000; border-right: 1px solid #000000; background-color: #FFFFFF; color: #000000">ADC2_CH2/T13</td>
		<td style="border-top: 1px solid #000000; border-bottom: 1px solid #000000; border-left: 1px solid #000000; border-right: 1px solid #000000; background-color: #FFFFFF; color: #000000">G13</td>
		<td style="border-top: 1px solid #000000; border-bottom: 1px solid #000000; border-left: 1px solid #000000; border-right: 1px solid #000000; background-color: #FFFFFF; color: #000000">I2S_DOUT</td>
		<td style="border-left: 1px solid #000000; background-color: #FFFFFF; color: #808080">23</td>
		<td style="border-right: 1px solid #000000; background-color: #FFFFFF; color: #808080">24</td>
		<td style="border-top: 1px solid #000000; border-bottom: 1px solid #000000; border-left: 1px solid #000000; border-right: 1px solid #000000; background-color: #FFFFFF; color: #000000">I2S_LRCK</td>
		<td style="border-top: 1px solid #000000; border-bottom: 1px solid #000000; border-left: 1px solid #000000; border-right: 1px solid #000000; background-color: #FFFFFF; color: #000000">G0</td>
		<td style="border-top: 1px solid #000000; border-bottom: 1px solid #000000; border-left: 1px solid #000000; border-right: 1px solid #000000"></td>
		<td style="border-top: 1px solid #000000; border-bottom: 1px solid #000000; border-left: 1px solid #000000; border-right: 1px solid #000000; background-color: #FFFFFF; color: #000000">I/O/T</td>
		<td style="border-top: 1px solid #000000; border-bottom: 1px solid #000000; border-left: 1px solid #000000; border-right: 1px solid #000000"></td>
	</tr>
	<tr>
		<td style="border-top: 1px solid #000000; border-bottom: 1px solid #000000; border-left: 1px solid #000000; border-right: 1px solid #000000"></td>
		<td style="border-top: 1px solid #000000; border-bottom: 1px solid #000000; border-left: 1px solid #000000; border-right: 1px solid #000000"></td>
		<td style="border-top: 1px solid #000000; border-bottom: 1px solid #000000; border-left: 1px solid #000000; border-right: 1px solid #000000"></td>
		<td style="border-top: 1px solid #000000; border-bottom: 1px solid #000000; border-left: 1px solid #000000; border-right: 1px solid #000000"></td>
		<td style="border-top: 1px solid #000000; border-bottom: 1px solid #000000; border-left: 1px solid #000000; border-right: 1px solid #000000; background-color: #8064A2; color: #FFFFFF">NC</td>
		<td style="border-left: 1px solid #000000; background-color: #FFFFFF; color: #808080">25</td>
		<td style="border-right: 1px solid #000000; background-color: #FFFFFF; color: #808080">26</td>
		<td style="border-top: 1px solid #000000; border-bottom: 1px solid #000000; border-left: 1px solid #000000; border-right: 1px solid #000000; background-color: #FFFFFF; color: #000000">I2S_DIN</td>
		<td style="border-top: 1px solid #000000; border-bottom: 1px solid #000000; border-left: 1px solid #000000; border-right: 1px solid #000000; background-color: #FFFFFF; color: #000000">G14</td>
		<td style="border-top: 1px solid #000000; border-bottom: 1px solid #000000; border-left: 1px solid #000000; border-right: 1px solid #000000; background-color: #FFFFFF; color: #000000">ADC2_CH3/T14</td>
		<td style="border-top: 1px solid #000000; border-bottom: 1px solid #000000; border-left: 1px solid #000000; border-right: 1px solid #000000; background-color: #FFFFFF; color: #000000">I/O/T</td>
		<td style="border-top: 1px solid #000000; border-bottom: 1px solid #000000; border-left: 1px solid #000000; border-right: 1px solid #000000"></td>
	</tr>
	<tr>
		<td style="border-top: 1px solid #000000; border-bottom: 1px solid #000000; border-left: 1px solid #000000; border-right: 1px solid #000000"></td>
		<td style="border-top: 1px solid #000000; border-bottom: 1px solid #000000; border-left: 1px solid #000000; border-right: 1px solid #000000"></td>
		<td style="border-top: 1px solid #000000; border-bottom: 1px solid #000000; border-left: 1px solid #000000; border-right: 1px solid #000000"></td>
		<td style="border-top: 1px solid #000000; border-bottom: 1px solid #000000; border-left: 1px solid #000000; border-right: 1px solid #000000"></td>
		<td style="border-top: 1px solid #000000; border-bottom: 1px solid #000000; border-left: 1px solid #000000; border-right: 1px solid #000000; background-color: #8064A2; color: #FFFFFF">NC</td>
		<td style="border-left: 1px solid #000000; background-color: #FFFFFF; color: #808080">27</td>
		<td style="border-right: 1px solid #000000; background-color: #FFFFFF; color: #808080">28</td>
		<td style="border-top: 1px solid #000000; border-bottom: 1px solid #000000; border-left: 1px solid #000000; border-right: 1px solid #000000; background-color: #CC0000; color: #FFFFFF">5V</td>
		<td style="border-top: 1px solid #000000; border-bottom: 1px solid #000000; border-left: 1px solid #000000; border-right: 1px solid #000000"></td>
		<td style="border-top: 1px solid #000000; border-bottom: 1px solid #000000; border-left: 1px solid #000000; border-right: 1px solid #000000"></td>
		<td style="border-top: 1px solid #000000; border-bottom: 1px solid #000000; border-left: 1px solid #000000; border-right: 1px solid #000000"></td>
		<td style="border-top: 1px solid #000000; border-bottom: 1px solid #000000; border-left: 1px solid #000000; border-right: 1px solid #000000"></td>
	</tr>
	<tr>
		<td style="border-top: 1px solid #000000; border-bottom: 1px solid #000000; border-left: 1px solid #000000; border-right: 1px solid #000000"></td>
		<td style="border-top: 1px solid #000000; border-bottom: 1px solid #000000; border-left: 1px solid #000000; border-right: 1px solid #000000"></td>
		<td style="border-top: 1px solid #000000; border-bottom: 1px solid #000000; border-left: 1px solid #000000; border-right: 1px solid #000000"></td>
		<td style="border-top: 1px solid #000000; border-bottom: 1px solid #000000; border-left: 1px solid #000000; border-right: 1px solid #000000"></td>
		<td style="border-top: 1px solid #000000; border-bottom: 1px solid #000000; border-left: 1px solid #000000; border-right: 1px solid #000000; background-color: #8064A2; color: #FFFFFF">NC</td>
		<td style="border-bottom: 1px solid #000000; border-left: 1px solid #000000; background-color: #FFFFFF; color: #808080">29</td>
		<td style="border-bottom: 1px solid #000000; border-right: 1px solid #000000; background-color: #FFFFFF; color: #808080">30</td>
		<td style="border-top: 1px solid #000000; border-bottom: 1px solid #000000; border-left: 1px solid #000000; border-right: 1px solid #000000; background-color: #FFD966; color: #000000">BATTERY</td>
		<td style="border-top: 1px solid #000000; border-bottom: 1px solid #000000; border-left: 1px solid #000000; border-right: 1px solid #000000"></td>
		<td style="border-top: 1px solid #000000; border-bottom: 1px solid #000000; border-left: 1px solid #000000; border-right: 1px solid #000000"></td>
		<td style="border-top: 1px solid #000000; border-bottom: 1px solid #000000; border-left: 1px solid #000000; border-right: 1px solid #000000"></td>
		<td style="border-top: 1px solid #000000; border-bottom: 1px solid #000000; border-left: 1px solid #000000; border-right: 1px solid #000000"></td>
	</tr>
</tbody></table>

<figure>
<table>
    <tbody><tr>
        <td>{% asset_image_tag fitcontain 2024-07-28-stackchan-rt-pcb-front.jpg %}</td>
        <td>{% asset_image_tag fitcontain 2024-07-28-stackchan-rt-pcb-back.jpg %}</td>
    </tr></tbody>
</table>
<figcaption>RT-Stackchan v1.0.0 PCB</figcaption>
</figure>

ｽﾀｯｸﾁｬﾝ アールティver. の基板（RT-Stackchan v1.0.0 PCB）は、オリジナル版のｽﾀｯｸﾁｬﾝ基板と若干異なる。
アールティ社のロゴであるうさぎさんの絵がシルクで描かれているなどの外見上の差はすぐに気づくが、回路の違いも一部見られた。

PCB のピン配置は下記の通りであった。M-BUS のピン番号と M5Stack CoreS3 の GPIO ピン番号を記載した。

<table>
    <caption>Port.B Pin assignment</caption>
	<thead><tr>
		<th style="border-top: 1px solid #000000; border-bottom: 1px solid #000000; border-left: 1px solid #000000; border-right: 1px solid #000000"></th>
		<th style="border-top: 1px solid #000000; border-bottom: 1px solid #000000; border-left: 1px solid #000000; border-right: 1px solid #000000">M-BUS pin #</th>
		<th style="border-top: 1px solid #000000; border-bottom: 1px solid #000000; border-left: 1px solid #000000; border-right: 1px solid #000000">S3</th>
	</tr></thead>
	<tbody><tr>
		<td style="border-top: 1px solid #000000; border-bottom: 1px solid #000000; border-left: 1px solid #000000; border-right: 1px solid #000000; background-color: #FFFFFF; color: #000000">-</td>
		<td style="border-top: 1px solid #000000; border-bottom: 1px solid #000000; border-left: 1px solid #000000; border-right: 1px solid #000000; background-color: #FFFFFF; color: #B7B7B7">4</td>
		<td style="border-top: 1px solid #000000; border-bottom: 1px solid #000000; border-left: 1px solid #000000; border-right: 1px solid #000000; background-color: #FFFFFF; color: #000000">G8</td>
	</tr>
	<tr>
		<td style="border-top: 1px solid #000000; border-bottom: 1px solid #000000; border-left: 1px solid #000000; border-right: 1px solid #000000; background-color: #FFD966; color: #000000">-</td>
		<td style="border-top: 1px solid #000000; border-bottom: 1px solid #000000; border-left: 1px solid #000000; border-right: 1px solid #000000; background-color: #FFFFFF; color: #B7B7B7">10</td>
		<td style="border-top: 1px solid #000000; border-bottom: 1px solid #000000; border-left: 1px solid #000000; border-right: 1px solid #000000; background-color: #FFFFFF; color: #000000">G9</td>
	</tr>
	<tr>
		<td style="border-top: 1px solid #000000; border-bottom: 1px solid #000000; border-left: 1px solid #000000; border-right: 1px solid #000000; background-color: #CC0000; color: #FFFFFF">5V</td>
		<td style="border-top: 1px solid #000000; border-bottom: 1px solid #000000; border-left: 1px solid #000000; border-right: 1px solid #000000; background-color: #FFFFFF; color: #B7B7B7">28</td>
		<td style="border-top: 1px solid #000000; border-bottom: 1px solid #000000; border-left: 1px solid #000000; border-right: 1px solid #000000"></td>
	</tr>
	<tr>
		<td style="border-top: 1px solid #000000; border-bottom: 1px solid #000000; border-left: 1px solid #000000; border-right: 1px solid #000000; background-color: #000000; color: #FFFFFF">G</td>
		<td style="border-top: 1px solid #000000; border-bottom: 1px solid #000000; border-left: 1px solid #000000; border-right: 1px solid #000000; background-color: #FFFFFF; color: #B7B7B7">1</td>
		<td style="border-top: 1px solid #000000; border-bottom: 1px solid #000000; border-left: 1px solid #000000; border-right: 1px solid #000000"></td>
	</tr>
</tbody></table>

<table>
    <caption>Port.C Pin assignment</caption>
	<thead><tr>
		<th style="border-top: 1px solid #000000; border-bottom: 1px solid #000000; border-left: 1px solid #000000; border-right: 1px solid #000000"></th>
		<th style="border-top: 1px solid #000000; border-bottom: 1px solid #000000; border-left: 1px solid #000000; border-right: 1px solid #000000">M-BUS pin #</th>
		<th style="border-top: 1px solid #000000; border-bottom: 1px solid #000000; border-left: 1px solid #000000; border-right: 1px solid #000000">S3</th>
	</tr></thead>
	<tbody><tr>
		<td style="border-top: 1px solid #000000; border-bottom: 1px solid #000000; border-left: 1px solid #000000; border-right: 1px solid #000000; background-color: #FFFFFF; color: #000000">R</td>
		<td style="border-top: 1px solid #000000; border-bottom: 1px solid #000000; border-left: 1px solid #000000; border-right: 1px solid #000000; background-color: #FFFFFF; color: #B7B7B7">15</td>
		<td style="border-top: 1px solid #000000; border-bottom: 1px solid #000000; border-left: 1px solid #000000; border-right: 1px solid #000000; background-color: #FFFFFF; color: #000000">G18</td>
	</tr>
	<tr>
		<td style="border-top: 1px solid #000000; border-bottom: 1px solid #000000; border-left: 1px solid #000000; border-right: 1px solid #000000; background-color: #FFD966; color: #000000">T</td>
		<td style="border-top: 1px solid #000000; border-bottom: 1px solid #000000; border-left: 1px solid #000000; border-right: 1px solid #000000; background-color: #FFFFFF; color: #B7B7B7">16</td>
		<td style="border-top: 1px solid #000000; border-bottom: 1px solid #000000; border-left: 1px solid #000000; border-right: 1px solid #000000; background-color: #FFFFFF; color: #000000">G17</td>
	</tr>
	<tr>
		<td style="border-top: 1px solid #000000; border-bottom: 1px solid #000000; border-left: 1px solid #000000; border-right: 1px solid #000000; background-color: #CC0000; color: #FFFFFF">5V</td>
		<td style="border-top: 1px solid #000000; border-bottom: 1px solid #000000; border-left: 1px solid #000000; border-right: 1px solid #000000; background-color: #FFFFFF; color: #B7B7B7">28</td>
		<td style="border-top: 1px solid #000000; border-bottom: 1px solid #000000; border-left: 1px solid #000000; border-right: 1px solid #000000"></td>
	</tr>
	<tr>
		<td style="border-top: 1px solid #000000; border-bottom: 1px solid #000000; border-left: 1px solid #000000; border-right: 1px solid #000000; background-color: #000000; color: #FFFFFF">G</td>
		<td style="border-top: 1px solid #000000; border-bottom: 1px solid #000000; border-left: 1px solid #000000; border-right: 1px solid #000000; background-color: #FFFFFF; color: #B7B7B7">1</td>
		<td style="border-top: 1px solid #000000; border-bottom: 1px solid #000000; border-left: 1px solid #000000; border-right: 1px solid #000000"></td>
	</tr>
</tbody></table>

<table>
    <caption>Serial Servo Pin assignment</caption>
	<thead><tr>
		<th style="border-top: 1px solid #000000; border-bottom: 1px solid #000000; border-left: 1px solid #000000; border-right: 1px solid #000000"></th>
		<th style="border-top: 1px solid #000000; border-bottom: 1px solid #000000; border-left: 1px solid #000000; border-right: 1px solid #000000">M-BUS pin #</th>
		<th style="border-top: 1px solid #000000; border-bottom: 1px solid #000000; border-left: 1px solid #000000; border-right: 1px solid #000000">S3</th>
	</tr></thead>
	<tbody><tr>
		<td style="border-top: 1px solid #000000; border-bottom: 1px solid #000000; border-left: 1px solid #000000; border-right: 1px solid #000000; background-color: #FFFFFF; color: #000000">RXD2</td>
		<td style="border-top: 1px solid #000000; border-bottom: 1px solid #000000; border-left: 1px solid #000000; border-right: 1px solid #000000; background-color: #FFFFFF; color: #B7B7B7">21</td>
		<td style="border-top: 1px solid #000000; border-bottom: 1px solid #000000; border-left: 1px solid #000000; border-right: 1px solid #000000; background-color: #FFFFFF; color: #000000">G6</td>
	</tr>
	<tr>
		<td style="border-top: 1px solid #000000; border-bottom: 1px solid #000000; border-left: 1px solid #000000; border-right: 1px solid #000000; background-color: #FFFFFF; color: #000000">TXD2</td>
		<td style="border-top: 1px solid #000000; border-bottom: 1px solid #000000; border-left: 1px solid #000000; border-right: 1px solid #000000; background-color: #FFFFFF; color: #B7B7B7">22</td>
		<td style="border-top: 1px solid #000000; border-bottom: 1px solid #000000; border-left: 1px solid #000000; border-right: 1px solid #000000; background-color: #FFFFFF; color: #000000">G7</td>
	</tr>
</tbody></table>

シリアルサーボ制御用のこのピンは RS485ドライバー MAX3485 (筆者の PCB に実装されていたのは STMicro の ST3485EI であった)を介して、 TTL に変換されているようだ。
これらがDYNAMIXELサーボ用の 3P Molex コネクタに接続してあった。

<figure>
{% asset_image_tag fitcontain 2024-07-28-stackchan-rt-pcb-servo-schematics.svg %}
<figcaption>DYNAMIXELサーボ制御関連部の推定回路図</figcaption>
</figure>

Molex コネクタ付近でそれぞれの3番ピン（信号ピン、「SIG」とシルク印刷あり）はR13で0オーム抵抗接続によって短絡している。
だから、組み立てマニュアルにはｽﾀｯｸﾁｬﾝの頭側のコネクタに接続するよう指示されているが電気的には下側（バッテリー側）のコネクタに接続しても同じである。

<figure>
{% asset_image_tag fitcontain 2024-07-28-cable-connecting.jpg %}
<figcaption>基板の取り付けの指示図（<a href="https://github.com/rt-net/stack-chan/blob/main/docs/assembly_ja.md#%E5%9F%BA%E6%9D%BF%E3%81%AE%E5%8F%96%E3%82%8A%E4%BB%98%E3%81%91">ｽﾀｯｸﾁｬﾝ アールティver. 組み立てマニュアル</a>から引用）</figcaption>
</figure>

注意すべき点として、オリジナル版のｽﾀｯｸﾁｬﾝ基板の回路配線に従うと
G5,G7はPWM用、G18,G17はシリアルサーボ用と勘違いしてしまいそうだが、アールティ版と配線が異なっていた。
特に **G18,G17とサーボの制御側とは接続していなかった** （R17,R18が実装されておらず開放されていたのでつながっていない）。

## DYNAMIXEL サーボの配線改良

アールティ出荷時には各DYNAMIXELサーボにID=1とID=2が設定されている（そのIDの値がシールで貼られている）。
組み立てマニュアルではこれらのIDに対応した配線コネクタの繋げ方が指示してある。

筆者はこの配線で最初使用したが、この方法でロール軸（ID=2のDYNAMIXELサーボ）のサーボホーンとケーブルが干渉する問題に直面した（下の写真の左）。
そこで、ID=2のDYNAMIXELサーボの接続コネクタを変えることで干渉しないようにすることした（下の写真の右）。

<figure>
{% asset_image_tag fitcontain 2024-07-28-dynamixel-connection-photo.jpg %}
<figcaption>DYNAMIXEL 配線変更とサーボホーンの干渉状況</figcaption>
</figure>

メインコントローラ（M5Stack CoreS3）とDYNAMIXELサーボは、コマンドデータ（パケット）を送受信することで通信を行う。
信号線はバスになっており、複数の機器が共通の線を使って通信を行うことができる。
ｽﾀｯｸﾁｬﾝ アールティver.の場合は2つのDYNAMIXELサーボが接続される。
各DYNAMIXELサーボには、機器の識別番号であるIDが割り当てられており、このIDを指定することで、
特定のサーボだけを制御することができる。

このバス配線の特徴から、組み立てマニュアルの配線(下図の Recommended Connection)から
ID=2の接続コネクタを変えた配線（下図の Alternative Connection)でも電気的には同じであり、
制御プログラムも変更なしで使うことができる。`

<figure>
{% asset_image_tag fitcontain 2024-07-28-dynamixel-connection.svg %}
<figcaption>DYNAMIXEL 配線図</figcaption>
</figure>

図の説明：

* Recommended Connection: 組み立てマニュアルに記載されている標準的な配線方法
* Alternative Connection: 筆者が採用した、サーボホーンとの干渉を避けるための配線方法。この方法では、ID=2のDYNAMIXELサーボの接続コネクタを変更している。


## ESP32/Arduino から DYNAMIXEL サーボの制御方法

[robotis-git/Dynamixel2Arduino](https://github.com/ROBOTIS-GIT/dynamixel2arduino) を使う。

Dynamixel2Arduinoは、DYNAMIXEL の製造元である ROBOTIS社が提供する公式ライブラリであり、
このライブラリを使用するのが無難であろう。

このライブラリは、ROBOTIS 社製の OpenCM などの専用ボードを主要ユーザとして想定した作りになっているため、
サンプルコードをそのままでは初期化ができない（コンパイルも通らない）。


結論から言うと下記のような流れで初期化処理をすれば良い。

1. Dynamixel2Arduino ライブラリの外側で一旦ハードウェアシリアルをボーレートやピン番号を指定して初期化する ( `DXL_SERIAL.begin(...)` )
2. Dynamixel2Arduino の初期化にはハードウェアシリアルの参照を渡す (`Dynamixel2Arduino(DXL_SERIAL)`)
3. その後で Dynamixel2Arduino を `begin()` する

```c++
#include <Dynamixel2Arduino.h>

// ハードウェアシリアルを定義
#define DXL_RX_PIN 6
#define DXL_TX_PIN 7
#define DXL_BAUD 1000000
HardwareSerial &DXL_SERIAL = Serial1;

// Dynamixel2Arduinoオブジェクトを生成
Dynamixel2Arduino dxl;

void setup(void) {
  // ...

  // ハードウェアシリアルを初期化
  DXL_SERIAL.begin(DXL_BAUD, SERIAL_8N1, DXL_RX_PIN, DXL_TX_PIN);
  delay(1000); // ここのウエイトの妥当性は未調査

  // Dynamixel2Arduinoライブラリを初期化
  dxl = Dynamixel2Arduino(DXL_SERIAL);
  dxl.setPortProtocolVersion(2.0f); // 通信プロトコルバージョンを設定

  dxl.begin(DXL_BAUD); // DYNAMIXELとの通信を開始

  dxl.torqueOn(1); // サーボのトルクをオンにする
  // ...
}
```

ポイントとしては Dynamixel2Arduino ライブラリ自身でハードウェアシリアルの初期化コードが入っているのだけれども、
これを使わずに自力でハードウェアシリアルを用意する。


## ｽﾀｯｸﾁｬﾝをDynamixel2Arduinoで制御するにおける注意事項


座標系はオリジナルのｽﾀｯｸﾁｬﾝと同様に右手系で、
ｽﾀｯｸﾁｬﾝが左を向く方向がID=1(ロール軸)のDYNAMIXELサーボの正の向き、
ｽﾀｯｸﾁｬﾝが下を向く方向がID=2(ピッチ軸)のDYNAMIXELサーボの正の向きである。


<figure>
{% asset_image_tag fitcontain 2024-07-28-coordinate.jpg %}
<figcaption>ｽﾀｯｸﾁｬﾝの座標系 ( <a href="https://github.com/stack-chan/stack-chan/blob/dev/v1.0/firmware/docs/api_ja.md">stack-chan/firmware/docs/api_ja.md at dev/v1.0 · stack-chan/stack-chan</a> から図を引用)</figcaption>
</figure>

ｽﾀｯｸﾁｬﾝが真正面を向いたとき、
ID=1(ロール軸)のDYNAMIXELサーボが0度、
ID=2(ピッチ軸)のDYNAMIXELサーボが180度であった。

ｽﾀｯｸﾁｬﾝを右に向かせるにはID=1(ロール軸)のDYNAMIXELサーボに負の値を指定する必要があるので、
オペレーションモードが 0〜360 の範囲内でしか使えない `OP_POSITION` モードを使うと右に向かせることはできない。

そこで `OP_EXTENDED_POSITION` モードに変えるとｽﾀｯｸﾁｬﾝの真正面のときにDYNAMIXELサーボが認識する角度が
ID=1(ロール軸)のDYNAMIXELサーボが180度、
ID=2(ピッチ軸)のDYNAMIXELサーボが180度となる現象が発生した。

なぜこのような挙動になるのかはわからなかったが、DYNAMIXELサーボが認識する角度をログ表示して確認するのが確実であろう。

```c++
  const auto pos = dxl.getPresentPosition(1, UNIT_DEGREE);
  M5_LOGI("pos %f", pos);
```

ｽﾀｯｸﾁｬﾝを指定の角度に向けさせるには `setGoalPosition()` 関数を使えばよい。

```c++
  dxl.setOperatingMode(1, OP_EXTENDED_POSITION);
  dxl.setGoalPosition(1, -90 + 180, UNIT_DEGREE); // ｽﾀｯｸﾁｬﾝを右90度 = -90度に回転
```

これでDYNAMIXELサーボが回転しはじめる。しかしDYNAMIXELサーボの動作が停止したかどうかを取得するための関数はない。

Dynamixel2Arduino ライブラリは必ずしもすべての DYNAMIXEL のコマンドを関数として提供しておらず、
XL330-M288-Tの電子マニュアルなどを参照して任意コマンド（ Control Table Item ）実行する関数を実行する必要がある。

この場合は[XL330-M288-Tの電子マニュアルのMoving Status](https://emanual.robotis.com/docs/en/dxl/x/xl330-m288/#moving-status)によると、
Moving Status の結果の値について、bit1 (Profile Ongoing) が0のとき Profile completed 状態を示す、
つまり動作を完了していることを示すのでこれで確認した。

何らかの理由で目標位置に到着しない（モノにぶつかってサーボが目標位置まで回らなかった場合も含む）ときには
bit0(最下位ビット)は 0 ( Arrived 状態 ) にならないので注意が必要だ。

```c++
 auto status = dxl.readControlTableItem(ControlTableItem::MOVING_STATUS, 1);
 bool is_moving = (status & 0x02) != 0x00; // Arrived かつ Profile completed 状態
```

設定系のコマンドも同様に任意コマンド（ Control Table Item ）実行する関数を実行する必要があるものがある。

```c++
  dxl.writeControlTableItem(ControlTableItem::PROFILE_ACCELERATION, 1, 20);
  dxl.writeControlTableItem(ControlTableItem::PROFILE_VELOCITY, 1, 100);
```

## おわりに

Dynamixel2Arduinoライブラリを使って、ｽﾀｯｸﾁｬﾝ アールティver. を制御する方法について解説した。
座標系や初期角度など、ややこしいところについては具体的な手順を踏んで説明した。

この記事が、ｽﾀｯｸﾁｬﾝ アールティver. を Arduino で動かそうとする人の助けになれば幸いである。

## 参考文献

* ｽﾀｯｸﾁｬﾝ [stack\-chan/stack\-chan: A JavaScript\-driven M5Stack\-embedded super\-kawaii robot\.](https://github.com/stack-chan/stack-chan/)
* ｽﾀｯｸﾁｬﾝ アールティver [rt\-net/stack\-chan: This is the repository for Stack\-chan RT ver\.](https://github.com/rt-net/stack-chan)
  * アールティロボットショップ（販売サイト）
    * [【新製品】ｽﾀｯｸﾁｬﾝ アールティver\. \[RT\-Stackchan\-V1\]](https://rt-net.jp/shop-rt-stackchan-v1)
    * [【新製品】ｽﾀｯｸﾁｬﾝ アールティver\. 組立キット \[RT\-Stackchan\-DIY\-V1\]](https://rt-net.jp/shop-rt-stackchan-diy-v1)
  * ｽﾀｯｸﾁｬﾝ アールティver. 組み立てマニュアル [stack\-chan/docs/assembly\_ja\.md at main · rt\-net/stack\-chan](https://github.com/rt-net/stack-chan/blob/main/docs/assembly_ja.md)
  * [量産ｽﾀｯｸﾁｬﾝ試作基板の動作テスト · rt\-net/stack\-chan@f1f901c](https://github.com/rt-net/stack-chan/commit/f1f901cf) (コミットログ)
* [M5Stack CoreS3](https://docs.m5stack.com/en/core/CoreS3)
* [ESP32-S3 Series Datasheet](https://www.espressif.com/sites/default/files/documentation/esp32-s3_datasheet_en.pdf)
* ROBOTIS DYNAMIXEL
  * [XL330\-M288\-T](https://emanual.robotis.com/docs/en/dxl/x/xl330-m288/) (ROBOTIS e-Manual)
  * [DYNAMIXEL Protocol 2\.0](https://emanual.robotis.com/docs/en/dxl/protocol2/) (ROBOTIS e-Manual)
  * [Besttechnology \- Dynamixel通信プロトコルV2マニュアル \[DYNAMIXEL Communiation Protocol 2\.0\] \- ナレッジベース](https://www.besttechnology.co.jp/modules/knowledge/?DYNAMIXEL%20Communiation%20Protocol%202.0)
  * [ROBOTIS\-GIT/Dynamixel2Arduino: DYNAMIXEL protocol library for Arduino](https://github.com/ROBOTIS-GIT/Dynamixel2Arduino)
  * [ESP32 S3 \+ DXL MKR Shield Mash\-Up in ARDUINO \- Projects and Learning \- ROBOTIS](https://forum.robotis.com/t/esp32-s3-dxl-mkr-shield-mash-up-in-arduino/1871)

