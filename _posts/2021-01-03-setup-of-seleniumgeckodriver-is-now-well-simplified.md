---
layout: post
title: Setup of Selenium + geckodriver is now well-simplified
date: '2021-01-03T15:32:47+09:00'
tags: firefox mozilla webdriver
---
As written in [the past post]({% post_url 2019-10-20-use-marionette-to-obtain-firefox-internal-information-easily %}),
I had been using [foxr](https://www.npmjs.com/package/foxr), a thin library of the Firefox marionette remote protocol,
to automatically control Firefox.
However, some of automated procedure didn't work now, so I switched to the **standard**-way setup of
[Selenium WebDriver](https://www.selenium.dev/documentation/en/webdriver/) with
[geckodriver](https://github.com/mozilla/geckodriver). I found its setup had become much simpler.

## TL;DR

```sh
npm i geckodriver selenium-webdriver
```

```js
const { Builder } = require('selenium-webdriver');
const firefox = require('selenium-webdriver/firefox');

require('geckodriver');

const options = new firefox.Options()
  .headless();
//.setBinary(executablePath);

const driver = await new Builder()
  .forBrowser('firefox')
  .setFirefoxOptions(options)
  .build();
```

## No need to download geckodriver manually

[A NPM package geckodriver](https://www.npmjs.com/package/geckodriver) is a downloader
for https://github.com/mozilla/geckodriver/releases.

When you install this package, it will start downloading geckodriver as follows:

```
% npm i geckodriver --save

> geckodriver@1.21.1 postinstall /tmp/a/node_modules/geckodriver
> node index.js

Downloading geckodriver... Extracting... Complete.
```

geckodriver is available at `node_modules/.bin/geckodriver` and `node_modules/geckodriver/geckodriver`.

## No need to add geckodriver to the system PATH manually

`require('geckodriver')` adds the directory where geckodriver is located to the system PATH.

```js
const assert = require('assert');
const path = require('path');

require('geckodriver');
assert.equal(process.env.PATH.split(path.delimiter)
  .includes(path.resolve('node_modules/geckodriver')), true);
```

Instead of manually downloading the geckodriver file and configuring the system PATH,
you can simply add this library to the package.json `dependencies`.

## Just only use selenium-webdriver/firefox

Hence, if you simply add `require('geckodriver')`, it will work fine!

```js
const { Builder } = require('selenium-webdriver');
const firefox = require('selenium-webdriver/firefox');

require('geckodriver');

const options = new firefox.Options()
  .headless();
//.setBinary(executablePath);

const driver = await new Builder()
  .forBrowser('firefox')
  .setFirefoxOptions(options)
  .build();
```
