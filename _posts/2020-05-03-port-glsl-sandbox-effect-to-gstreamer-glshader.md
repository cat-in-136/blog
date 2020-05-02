---
layout: post
title: Porting GLSL Sandbox effect to GStreamer glshader element
tags:
- glsl
- gstreamer
date: '2020-05-03T00:48:01+09:00'
---
GStreamer has various filter elements, among which is
[OpenGL fragment shader filter "glshader"](https://gstreamer.freedesktop.org/documentation/opengl/glshader.html).

This filter accepts GLSL vertex source and shader,
but you can specify only shader. For example:

>     gst-launch-1.0 videotestsrc ! glupload ! glshader fragment="\"`cat myshader.frag`\"" ! glimagesink

"Shader" can create real-time effect/demo "movie" like posted in [GLSLSandbox] and [Shadertoy].
So, I looked into how to stream "shader" into Gstreamer.

[GLSLSandbox]: http://glslsandbox.com/
[Shadertoy]: https://www.shadertoy.com/

### Input is required

An input is actually required for glshader.
glshader is an implement of `GstBaseTransform`, which shall have a sink pad.

<figure> {% asset_image_tag fitcontain 2020-05-03-port-glsl-sandbox-effect-to-gstreamer-glshader-diagram-glshader.svg %}
<figcaption>Example diagram of glshader</figcaption>
</figure>

If no input required to the filter, the a dummy input is required.
I believe gltestsrc is good,
because using OpenGL source is the most efficient way to stream it to the glshader element
without conversion.

### Shader parameter incompatibility between GStreamer and GLSLSandbox

glshader varying and uniform parameters:

```glsl
varying vec2 v_texcoord;
uniform sampler2D tex;
uniform float time;
uniform float width;
uniform float height;
```

GLSLSandbox uniform parameters:

```glsl
uniform float time;
uniform vec2 mouse;
uniform vec2 resolution;
uniform sampler2D backbuffer;
```

Here, it is impossible to port some uniforms such as `mouse` into glshader.
`time` can be ported in the same value.
`resolution` can be ported to `vec2(width, height)`.

The output parameter `gl_FragColor` is same.
`Gl_FragCoord` can be used in the same way, but the coordinate systems are different.

<figure> {% asset_image_object_tag 2020-05-03-port-glsl-sandbox-effect-to-gstreamer-glshader-coordinate-system.svg %}
<figcaption>Coordinate system difference</figcaption>
</figure>

The coordinate transformation is required to acquire the same output image.
For example,

```glsl
// For GLSLSandbox
#ifdef GL_ES
precision mediump float;
#endif

#extension GL_OES_standard_derivatives : enable

uniform float time;
uniform vec2 mouse;
uniform vec2 resolution;

void main( void ) {
  vec2 uv = gl_FragCoord.xy / resolution;
  gl_FragColor = vec4( uv.x, uv.y, 1.0, 1.0 );
}
```

```glsl
// For GStreamer glshader
#version 100
#ifdef GL_ES
precision mediump float;
#endif
varying vec2 v_texcoord;
uniform sampler2D tex;
uniform float time;
uniform float width;
uniform float height;

void main() {
  vec2 uv = vec2(gl_FragCoord.x, height - gl_FragCoord.y) / vec2(width, height);
  gl_FragColor = vec4( uv.x, uv.y, 1.0, 1.0 );
}
```

Both yield same output as following:

<figure> {% asset_image_tag 2020-05-03-port-glsl-sandbox-effect-to-gstreamer-glshader-example.png %}
<figcaption>Example output</figcaption>
</figure>

### Output sink

All that's left is to connect some filters and sinks after the glshader in the usual GStreamer way.

For example, to show a window, connect glimagesink directly:

```
% gst-launch-1.0 gltestsrc pattern=black ! \
      glshader fragment="\"$(cat myshader.frag)\"" ! \
      glimagesink
```

To redirect a V4L2 device, conversion is required before connect to the device:

```
% gst-launch-1.0 gltestsrc pattern=black ! \
      glshader fragment="\"$(cat myshader.frag)\"" ! \
      gldownload ! \
      videoconvert ! \
      videoscale ! \
      video/x-raw,width=640,height=480,framerate=30/1,format=YUY2 ! \
      v4l2sink device=/dev/video1
```

To generate a PNG file...


```
% gst-launch-1.0 gltestsrc pattern=black num-buffers=1 ! \
      glshader fragment="\"$(cat myshader.frag)\"" ! \
      gldownload ! \
      videoconvert ! \
      pngenc ! \
      filesink location=capture1.png
```

### Reference

 * [glshader](https://gstreamer.freedesktop.org/documentation/opengl/glshader.html), GStreamer API Reference
 * [GstBaseTransform](https://gstreamer.freedesktop.org/documentation/base/gstbasetransform.html), GStreamer API Reference
 * [gltestsrc](https://gstreamer.freedesktop.org/documentation/opengl/gltestsrc.html), GStreamer API Reference
 * [mrdoob/glsl-sandbox: Online live editor for fragment shaders.](https://github.com/mrdoob/glsl-sandbox)
 * [jolivain/gst-shadertoy: Scripts for using some ShaderToy shaders in GStreamer](https://github.com/jolivain/gst-shadertoy)
