---
layout: post
title: Use Marionette to obtain Firefox internal information easily
date: '2019-10-20T12:52:16+09:00'
tags: firefox mozilla
---
I've been tracking updates/differences in Firefox default settings [since around 2010]({% post_url 2010-08-22-diff-of-firefox4-default-preference %}).

It used to be a semi-manual process to extract files like prefs.js from [`omni.ja` files](https://developer.mozilla.org/en-US/docs/Mozilla/About_omni.ja_%28formerly_omni.jar%29) Firefox, and then combine them using `cat` command.

Recently, more and more settings are embedded inside libxul.so instead of writing them in text file (like prefs.js).
In addition, [to make it easier to use with trust, these settings were changed to be generated from YAML files](https://bugzilla.mozilla.org/show_bug.cgi?id=1563555) when building Firefox binaries.
The old methods are not making much sense.

So [I changed the process drastically](https://github.com/cat-in-136/firefox-prefjs-surveyer/pull/3). First, run Firefox headless and [marionette mode](https://firefox-source-docs.mozilla.org/testing/marionette/index.html). And then, run a script using [foxr NPM package](https://www.npmjs.com/package/foxr) to get the Firefox defaults directly.

The instruction in the README include the technique for using a *fresh clean* profile. Refer [another post]({% post_url 2012-12-31-tip-how-to-run-new-firefox-instance-w %}) for details.

> Create a temporary folder to use a *fresh clean* profile.
> 
>     % mkdir /tmp/profile_dir
> 
> Run firefox in headless mode.
> 
>     % /path/to/firefox -profile /tmp/profile_dir -marionette -headless
> 
> Execute fetcher.js to obtain all default prefs.
> 
>     % node fetcher.js > prefall.json

We can run JavaScript snippets on an opened page using foxr, which can be used for things like scraping.

```javascript
    await page.goto('about:config')

    //await page.evaluate('ShowPrefs()');
    const prefs = await page.evaluate(`(function(){
      const { Services } = ChromeUtils.import("resource://gre/modules/Services.jsm");
      const gPrefBranch = Services.prefs;
      const defaultBranch = gPrefBranch.getDefaultBranch("");
      // ... (snip) ...
      return prefs.map(entry => [entry.name, gTypeStrs[entry.type], entry.value]);
    })()`);
    //console.log(prefs);
    process.stdout.write(JSON.stringify(prefs));
```

`fetcher.js` opens about:config and run some snippets.
about:config supports firefox private interfaces (used to be available with old extensions).
So, `fetcher.js` is able to access Firefox preference information.

The comparison logic is the same as in the past.
I ported from code running in the browser to code running on Node.js.
In addition, it was rewritten into a modern grammar.
As a result, surveyer.js has also changed a lot.
