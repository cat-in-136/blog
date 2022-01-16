---
layout: post
title: 'Note: Directory Layout of library for unit testing with PlatformIO'
author: cat_in_136
tags:
- platformio
date: '2022-01-16T11:16:27+09:00'
last_modified_at: '2022-01-16T16:06:28+09:00'
---

C/C++ source files shall be placed in `src/` or `include/`.
PlatformIO Unit Testing Engine does *not* build source code from `src/` by default.
To test library test code in `src/`,
instruct PlatformIO to build files in `src/`
using `test_build_project_src` option in `platformio.ini`.

### Directory Layout

    .
    ├── library.json
    ├── platformio.ini
    ├── src
    │   ├── HelloWorld.cpp
    │   └── HelloWorld.h
    └── test
        └── test_main.cpp


### Library Manifest library.json

Create the manifest file `library.json` as usual.

```json
{
  "name": "HelloWorld",
  "version": "1.0.0",
  "description": "A \"Hello world\" program is a computer program that outputs \"Hello World\" (or some variant) on a display device",
  "keywords": "planet, happiness, people",
  "repository":
  {
    "type": "git",
    "url": "https://git.example.com/john-smith/hello-world.git"
  },
  "authors":
  [
    {
      "name": "John Smith",
      "email": "me@john-smith.example.com",
      "url": "https://john-smith.example.com/contact"
    }
  ],
  "license": "MIT",
  "homepage": "https://helloworld.example.com/",
  "frameworks": "*",
  "platforms": "*"
}
```

### platform.io

As described above, you need specify `test_build_project_src` to `yes`.
To test on PC native by default, create `native` environment and set `default_envs` to `native`.

```ini
[platformio]
default_envs = native

[env]
monitor_flags = --echo
monitor_filters = time, send_on_enter, default
test_build_project_src = yes

[env:native]
platform = native

# create any other environment as you like...

[env:m5stack-atom]
platform = espressif32
board = m5stack-atom
framework = arduino
monitor_speed = 115200

[env:sparkfun_promicro16]
platform = atmelavr
board = sparkfun_promicro16
framework = arduino
```

### Codes

In this example, we simply declare a function
that returns a string "Hello, world."

```cpp
// src/HelloWorld.h
#ifndef _HELLO_WORLD_H_
#define _HELLO_WORLD_H_
//#pragma once

const char* HelloWorld(void);

#endif
```

```cpp
// src/HelloWorld.cpp
#include "HelloWorld.h"

const char* HelloWorld(void) {
  return "Hello, World.";
}
```

### Test codes

Write the test case as a function like the following:

```cpp
#include <HelloWorld.h>
#include <unity.h>

#include <cstring>

void test_hello_world() {
  TEST_ASSERT_EQUAL(0, strcmp("Hello, World.", HelloWorld()));
}
```

Register this function with `RUN_TEST()` surrounded `UNITY_BEGIN()` and `UNITY_END()`.

```cpp
//#include <unity.h>
UNITY_BEGIN();
RUN_TEST(test_hello_world);
// RUN_TEST(test_another_one);
UNITY_END();
```

The entry point is different between arduino and native.
`setup()` and `loop()` are required for arduino, `main()` for native.

To run it in the same source code, you need to switch entry point functions
using `#ifdef ARDUINO` as shown below:

```cpp
#include <HelloWorld.h>
#include <unity.h>

#include <cstring>

#ifdef ARDUINO
#include <Arduino.h>
#endif

void test_hello_world() {
  TEST_ASSERT_EQUAL(0, strcmp("Hello, World.", HelloWorld()));
}

#ifdef ARDUINO
void setup() {
  delay(2000); // add 2-sec wait for the board w/o software resetting via
               // Serial.DTR/RTS
#else
int main(int argc, char *argv[]) {
#endif
  UNITY_BEGIN();
  RUN_TEST(test_hello_world);
  UNITY_END();

#ifndef ARDUINO
  return 0;
#endif
}

#ifdef ARDUINO
void loop() {}
#endif
```

### Run test

Just run `pio test` (or run the test task on the your favorite tool).

```
$ pio -c vim test
Verbose mode can be enabled via `-v, --verbose` option
Collected 1 items

Processing * in native environment
--------------------------------------------------------------------------------
Building...
Testing...
test/test_main.cpp:22:test_hello_world	[PASSED]

-----------------------
1 Tests 0 Failures 0 Ignored
OK
========================== [PASSED] Took 0.64 seconds ==========================

Test    Environment    Status    Duration
------  -------------  --------  ------------
*       native         PASSED    00:00:00.642
========================= 1 succeeded in 00:00:00.642 =========================
```

Same way for testing on a board, but it takes longer time.

```
$ pio -c vim test -e m5stack-atom
Verbose mode can be enabled via `-v, --verbose` option
Collected 1 items

Processing * in m5stack-atom environment
--------------------------------------------------------------------------------
Building...
Uploading...
Testing...
If you don't see any output for the first 10 secs, please reset board (press reset button)

test/test_main.cpp:22:test_hello_world	[PASSED]
-----------------------
1 Tests 0 Failures 0 Ignored
========================== [PASSED] Took 8.13 seconds ==========================

Test    Environment    Status    Duration
------  -------------  --------  ------------
*       m5stack-atom   PASSED    00:00:08.127
========================= 1 succeeded in 00:00:08.127 =========================
```

### References

* [PlatformIO でユニットテストが書きたい \| мята](https://fum1h1ro.github.io/2021/01/26/m5paper-test/)
* [Creating Library — PlatformIO latest documentation](https://docs.platformio.org/en/latest/librarymanager/creating.html)
* [Unit Testing — PlatformIO latest documentation](https://docs.platformio.org/en/latest/plus/unit-testing.html)

