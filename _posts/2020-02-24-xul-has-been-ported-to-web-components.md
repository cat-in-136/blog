---
layout: post
title: XUL が Web Components になったね
date: '2020-02-24T01:33:48+09:00'
tags:
- firefox
- xul
- チラシの裏
---

## XBL が消えたね

Firefox の GUI は長らくMozilla固有のUI技術XMLであるXULでつくられてきたが、これはHTMLに置き換えられた…というのは実は間違っていてXULはWebComponentsに置き換えられた。基幹機能であるXBLが捨てられWebComponentsに置き換えられた。

> WebComponentsの先祖みたいなMozilla固有のUI技術XMLであるXULを支える基幹機能であり、Webブラウザに高度な拡張機能のエコシステムをもたらしたXBLがお亡くなりになりました！
> 
> &mdash; dynamis (でゅなみす/レッサーパンダの人) (@dynamitter) [October 10, 2019](https://twitter.com/dynamitter/status/1182108689739575296)

したがって、現在のFirefoxのGUIはWebComponentsでいわば再実装されたXULで書かれている。WebComponentsなのでHTMLで書かれていることになる（正しくはXHTML）。

これはFirefoxで`chrome://content/browser/browser.xhtml`と打ち込んだ後で、開発者ツールなどで確認することができる。

<figure>
{% asset_image_tag fitcontain 2020-02-24_xulhasbeenported_browser-html.png 1024 %}
<figcaption><code>chrome://content/browser/browser.xhtml</code></figcaption>
</figure>

## XUL の WebComponents 構造と XBL 構造を雑に眺めてみる

上述の開発者ツールで、たとえばダウンロードボタンが`toolbarbutton`という要素名なのだが、これはWebComponentsで登録されたものであることは、下記を実行すれば直ちにわかる。

```javascript
$("#downloads-button") instanceof customElements.get("toolbarbutton")
// => true
```

クラスの階層構造は、XULとかDOMに関わらない純粋なJavaScriptのテクとして、
下記のようにして追っかけられる。
得られた配列の最後が祖先のクラス（のコンストラクタ）である。

```javascript
function *hoge(obj) {
  for (let proto = obj.__proto__; proto; proto = proto.__proto__) {
    yield proto.constructor;
  }
}
Array.from(hoge($("#downloads-button")))
// => Array(10) [ MozToolbarbutton(args), MozButtonBase(), BaseText(args),
//                BaseControl(args), MozElementBase(), (), (), (), (), Object() ]
```

実際にこれを実行するとJavaScriptコードへの参照は定義場所へ移動するアイコン
{% asset_image_tag 2020-02-24_xulhasbeenported_jump-definition.svg 16 16 %}
が表示されるのでJavaScriptで書かれているクラスに関しては追っていくのは結構簡単だ。

クラス階層を表すと下記の通りとなる。

* `Object`
  * [`EventTarget`](https://developer.mozilla.org/en-US/docs/Web/API/EventTarget)
    * [`Node`](https://developer.mozilla.org/en-US/docs/Web/API/Node)
      * [`Element`](https://developer.mozilla.org/en-US/docs/Web/API/Element)
        * `XULElement` ([nsXULElement.h](https://dxr.mozilla.org/mozilla-central/source/dom/xul/nsXULElement.h))
          * `MozElementBase` (chrome://global/content/customElements.js)
            * `BaseControl` (chrome://global/content/customElements.js)
              * `BaseText` (chrome://global/content/customElements.js)
                 * `MozButtonBase` (chrome://global/content/elements/button.js)
                    * `MozToolbarbutton` (chrome://global/content/elements/toolbarbutton.js)

`Object`〜`Element`まではDOM要素で共通だ。
HTML要素の場合は[`HTMLElement`](https://developer.mozilla.org/en-US/docs/Web/API/HTMLElement)が共通祖先になるが、
XUL要素の場合はあくまで`HTMLElement`ではなく`XULElement`である。

ちなみにXBL時代の古いFirefoxを使って同様に階層を調べると下記の通りと判明した。

* `Object`
  * [`EventTarget`](https://developer.mozilla.org/en-US/docs/Web/API/EventTarget)
    * [`Node`](https://developer.mozilla.org/en-US/docs/Web/API/Node)
      * [`Element`](https://developer.mozilla.org/en-US/docs/Web/API/Element)
        * `XULElement` ([nsXULElement.h](https://dxr.mozilla.org/mozilla-central/source/dom/xul/nsXULElement.h))
          * chrome://global/content/bindings/general.xml#basecontrol
            * chrome://global/content/bindings/general.xml#basetext
               * chrome://global/content/bindings/button.xml#button-base
                  * chrome://global/content/bindings/toolbarbutton.xml#toolbarbutton

これは意図してやったことだが、
XBL時代の階層をほぼそのままにWebComponentsに移行していることがよくわかる。
`BaseControl`以下がかつてXBLであった対応性がよくわかる。
それらのXBLで書かれていたところをJavaScriptに置き換えられたのだ。

興味深いことに`XULElement`はネイティブコードのままで変えていない。
設計は変えずに実装方法だけを現代化した、リファクタリングしたというのはすごい。

## 参考文献

* Brian Grinstead, "[The Firefox UI is now built with Web Components](https://briangrinstead.com/blog/firefox-webcomponents/)"
* Brian Grinstead, "[XBL In Firefox](https://briangrinstead.com/blog/xbl-in-firefox/)"
* [Are We XBL Still?](https://bgrins.github.io/xbl-analysis/)
* [Firefox/XUL and XBL Replacement - MozillaWiki](https://wiki.mozilla.org/Firefox/XUL_and_XBL_Replacement)

