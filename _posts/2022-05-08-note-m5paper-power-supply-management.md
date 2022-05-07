---
layout: post
title: 'Note: M5Paper Power Supply/Management'
author: cat_in_136
tags:
- m5paper
- embedded
date: '2022-05-08T00:11:23+09:00'
---
This post describes a summary of the following conditions for the power supply/management of M5Paper.

* Powered by USB Type-C or not
* "Shutdown" or "DeepSleep"

The following figure is an excerpt from the outline diagram on the back of the M5Paper that relates to the power supply.

<figure>
<svg xmlns="http://www.w3.org/2000/svg" version="1.1" width="646.08" height="457.19" viewBox="0 0 64.608 45.719" class="fitcontain">
  <g id="m5paper-power-diagram-base">
    <g transform="translate(-76.138 -139.86)" fill="none">
      <rect x="101.53" y="171.63" width="11.25" height="4.388" rx="1.5704" ry="1.5704" stroke="#000" stroke-width=".35278"/>
      <text x="107.0668" y="175.01181" font-family="sans-serif" font-size="3.5278px" letter-spacing="0px" stroke="#000000" stroke-width=".26458px" text-align="center" text-anchor="middle" word-spacing="0px" style="line-height:125%">
        <tspan x="107.0668" y="175.01181" fill="#000000" font-size="3.5278px" stroke="none" stroke-width=".26458px" text-align="center" text-anchor="middle">MOS</tspan>
      </text>
    </g>
    <g transform="translate(-72.424 -137.74)">
      <rect x="103.26" y="157.37" width="9.0747" height="8.7066" rx="1.9333" ry="1.9333" fill="#aade87"/>
      <text x="107.81548" y="161.00313" fill="#000000" font-family="sans-serif" font-size="3.175px" letter-spacing="0px" stroke-width=".26458px" text-anchor="middle" word-spacing="0px" style="line-height:110%">
        <tspan x="107.81548" y="161.00313" text-align="center">BM</tspan>
        <tspan x="107.81548" y="164.49562" text-align="center">8563</tspan>
      </text>
    </g>
    <g transform="translate(-76.138 -137.22)">
      <rect x="77.314" y="163.71" width="18.454" height="4.9492" rx="1.5704" ry="1.5704" fill="none" stroke="#800000" stroke-width=".35278"/>
      <text x="86.380272" y="167.34073" fill="none" font-family="sans-serif" font-size="3.5278px" letter-spacing="0px" stroke="#000000" stroke-width=".26458px" text-align="center" text-anchor="middle" word-spacing="0px" style="line-height:125%">
        <tspan x="86.380272" y="167.34073" fill="#000000" font-size="3.5278px" stroke="none" stroke-width=".26458px" text-align="center" text-anchor="middle">BATTERY</tspan>
      </text>
      <rect x="96.31" y="164.98" width=".77051" height="2.4051" fill="#800000"/>
    </g>
    <g transform="translate(-76.138 -139.86)">
      <g transform="matrix(.39104 0 0 .39104 106.03 142.32)" fill="#e7352c">
        <path d="m6.93 15.65a1.48 1.48 0 1 1-1.48-1.48 1.48 1.48 0 0 1 1.48 1.48"/>
        <path d="m19.84 14.11a15.34 15.34 0 0 0-13-13 9.73 9.73 0 0 0-2.15 1.55v1.43a12.18 12.18 0 0 1 12.17 12.16h1.43a10.25 10.25 0 0 0 1.55-2.14"/>
        <path d="m21 9.62a9.62 9.62 0 0 0-9.67-9.62c-0.34 0-0.67 0-1 0.05l-0.22 0.64a16.55 16.55 0 0 1 10.14 10.13l0.64-0.23c0-0.32 0.06-0.64 0.06-1"/>
        <path d="m11.44 21a11.44 11.44 0 0 1-11.44-11.39 11.36 11.36 0 0 1 3.35-8.09l0.65 0.61a10.56 10.56 0 0 0 0 15 10.56 10.56 0 0 0 15 0l0.61 0.61a11.35 11.35 0 0 1-8.17 3.26"/>
        <path d="m11.31 16.91a6.65 6.65 0 0 0-2.61-5.91 6.51 6.51 0 0 0-3.35-1.36 0.61 0.61 0 0 1-0.53-0.64 0.59 0.59 0 0 1 0.65-0.54 7.85 7.85 0 0 1 7 8.58 6.85 6.85 0 0 1-0.26 1.35l1.74 0.49a9.66 9.66 0 0 0 1.5-0.57 10.64 10.64 0 0 0 0.19-2.05 11 11 0 0 0-9.33-10.86 4.84 4.84 0 0 0-1.75 0 3.81 3.81 0 0 0-1.89 1.17 3.74 3.74 0 0 0 1.67 6 8.66 8.66 0 0 0 0.94 0.17 3.51 3.51 0 0 1 2.92 3.46 3.47 3.47 0 0 1-0.56 1.89l1.2 0.77a8.91 8.91 0 0 0 1.8 0.3 6.58 6.58 0 0 0 0.66-2.3"/>
      </g>
      <rect x="104.39" y="141.04" width="11.485" height="10.77" rx="1.5704" ry="1.5704" fill="none" stroke="#e7352c" stroke-width=".35278"/>
    </g>
    <text x="40.758881" y="3.0064886" fill="#000000" font-family="sans-serif" font-size="2.8222px" letter-spacing="0px" stroke-width=".26458px" word-spacing="0px" style="line-height:110%">
      <tspan x="40.758881" y="3.0064886" font-weight="bold">ESP32</tspan>
      <tspan x="40.758881" y="6.1109271">D0WDQ6-V3</tspan>
      <tspan x="40.758881" y="9.215374">16M-FLASH</tspan>
      <tspan x="40.758881" y="12.319813">8M-PSRAM</tspan>
    </text>
    <text x="4.9717717" y="34.719135" fill="#000000" font-family="sans-serif" font-size="2.8222px" letter-spacing="0px" stroke-width=".26458px" word-spacing="0px" style="line-height:110%">
      <tspan x="4.9717717" y="34.719135" font-weight="bold">Li-Po</tspan>
      <tspan x="4.9717717" y="37.823582">1150mAh</tspan>
      <tspan x="4.9717717" y="40.928013">4.35V</tspan>
    </text>
    <path d="m1.838 2.906a9.5202 9.5202 0 0 1 10.892 3.261 9.5202 9.5202 0 0 1 0 11.37 9.5202 9.5202 0 0 1-10.892 3.261" fill="none" stroke="#000" stroke-width=".70556"/>
    <path transform="scale(.26458)" d="m33.557 39.594a0.37503 0.37503 0 0 0-0.33008 0.60156c0.58103 0.80954 0.99299 1.6979 1.2363 2.6191h-12.146v4.002h12.15c-0.24136 0.91118-0.65301 1.7861-1.2344 2.5762a0.37503 0.37503 0 0 0 0.42969 0.57617l13.109-4.8203a0.37503 0.37503 0 0 0 0-0.70117l-13.109-4.8281a0.37503 0.37503 0 0 0-0.10547-0.025391z" color="#000000" stroke-width="3.7795" style=""/>
    <g transform="translate(-73.492 -139.86)">
      <rect x="114.94" y="163.27" width="9.0747" height="8.7066" rx="1.9333" ry="1.9333" fill="#faa"/>
      <text x="119.4726" y="166.91499" fill="#000000" font-family="sans-serif" font-size="3.175px" letter-spacing="0px" stroke-width=".26458px" text-anchor="middle" word-spacing="0px" style="line-height:110%">
        <tspan x="119.4726" y="166.91499" text-align="center">SY</tspan>
        <tspan x="119.4726" y="170.40749" text-align="center">7088</tspan>
      </text>
    </g>
    <g transform="translate(-60.583 -139.86)">
      <rect x="114.94" y="163.27" width="9.0747" height="8.7066" rx="4.3533" ry="4.3533" fill="none" stroke="#800000" stroke-width=".35278"/>
      <text x="119.4726" y="166.91499" fill="#000000" font-family="sans-serif" font-size="3.175px" letter-spacing="0px" stroke-width=".26458px" text-anchor="middle" word-spacing="0px" style="line-height:110%">
        <tspan x="119.4726" y="166.91499" font-weight="bold" text-align="center">5V</tspan>
        <tspan x="119.4726" y="170.40749" text-align="center">BUS</tspan>
      </text>
    </g>
    <g transform="translate(-58.837 -121.7)">
      <g transform="translate(-2.8307,-2.4278)">
        <rect x="77.314" y="163.71" width="18.454" height="4.9492" rx="1.5704" ry="1.5704" fill="#faa"/>
        <text x="86.551369" y="167.34073" fill="none" font-family="sans-serif" font-size="3.5278px" letter-spacing="0px" stroke="#000000" stroke-width=".26458px" text-align="center" text-anchor="middle" word-spacing="0px" style="line-height:125%">
          <tspan x="86.551369" y="167.34073" fill="#000000" font-size="3.5278px" stroke="none" stroke-width=".26458px" text-align="center" text-anchor="middle">SLM6635</tspan>
        </text>
      </g>
    </g>
    <g transform="translate(-73.3 -152.3)" fill="none">
      <text x="119.39691" y="190.77817" font-family="sans-serif" font-size="2.8222px" letter-spacing="0px" stroke="#000000" stroke-width=".26458px" text-align="center" text-anchor="middle" word-spacing="0px" style="line-height:110%">
        <tspan x="119.39691" y="190.77817" fill="#000000" font-size="2.8222px" stroke="none" stroke-width=".26458px" text-align="center" text-anchor="middle">USB-C</tspan>
      </text>
      <path d="m124.02 188v2.8722c0 0.74432-0.59921 1.3435-1.3435 1.3435h-6.4034c-0.74431 0-1.3435-0.59921-1.3435-1.3435v-2.8722" stroke="#000" stroke-width=".70556"/>
      <path d="m122.72 192.16v4.3243h-6.4971v-4.3243" stroke="#000" stroke-width=".70556"/>
    </g>
    <g font-family="sans-serif" font-size="2.8222px" letter-spacing="0px" word-spacing="0px">
      <text x="28.430695" y="15.621563" text-align="end" text-anchor="end" style="line-height:110%">
        <tspan x="28.430695" y="15.621563">G2</tspan>
      </text>
      <text x="35.79467" y="15.621563" fill="#000000" style="line-height:110%">
        <tspan x="35.79467" y="15.621563">SDA21</tspan>
        <tspan x="35.79467" y="18.726002">SCL22</tspan>
      </text>
      <text x="15.902069" y="14.953419" fill="#000000" stroke-width=".26458px" style="line-height:110%">
        <tspan x="15.902069" y="14.953419" font-weight="bold">PWR</tspan>
        <tspan x="15.902069" y="18.057858">G38</tspan>
      </text>
    </g>
    <path d="m28.666 11.947-0.07422 12.645 0.35156 2e-3 0.07617-12.645z" color="#000000" fill-rule="evenodd" style=""/>
    <path d="m28.939 24.551-0.34375 0.08398 1.7227 7.1758 0.34375-0.08203z" color="#000000" fill-rule="evenodd" style=""/>
    <g fill-rule="evenodd" stroke-linejoin="round">
      <path d="m30.747 31.009-0.14351 1.2236-0.68341-1.0251c0.28724 0.12102 0.62097 0.0398 0.82692-0.19853z" color="#000000" stroke-width=".066146" style=""/>
      <path d="m30.746 30.977a0.033076 0.033076 0 0 0-0.02344 0.0098c-0.19682 0.22777-0.51515 0.30681-0.78906 0.19141a0.033076 0.033076 0 0 0-0.04102 0.04883l0.6836 1.0234a0.033076 0.033076 0 0 0 0.06055-0.01367l0.14258-1.2246a0.033076 0.033076 0 0 0-0.0332-0.03516zm-0.03516 0.07031-0.13086 1.0938-0.60938-0.91797c0.2628 0.0824 0.54051 0.01755 0.74023-0.17578z" color="#000000" style=""/>
    </g>
    <path d="m34.598 11.936-0.35156 0.02734 0.60742 7.6777 0.35156-0.0293z" color="#000000" fill-rule="evenodd" style=""/>
    <path d="m33.312 28.262-1.5 3.4375 0.32422 0.14062 1.5-3.4375z" color="#000000" fill-rule="evenodd" style=""/>
    <g fill-rule="evenodd" stroke-linejoin="round">
      <path d="m32.638 31.317-0.85217 0.88979 0.07272-1.2299c0.15622 0.26972 0.47146 0.4061 0.77945 0.3401z" color="#000000" stroke-width=".066146" style=""/>
      <path d="m31.85 30.945a0.033076 0.033076 0 0 0-0.02344 0.0293l-0.07422 1.2305a0.033076 0.033076 0 0 0 0.05664 0.02539l0.85352-0.89062a0.033076 0.033076 0 0 0-0.03125-0.05469c-0.29434 0.06307-0.59517-0.06702-0.74414-0.32422a0.033076 0.033076 0 0 0-0.03711-0.01563zm0.03906 0.07422c0.15968 0.22416 0.42161 0.338 0.69726 0.30469l-0.76172 0.79492z" color="#000000" style=""/>
    </g>
    <path d="m19.191 30.836-0.08398 0.3418 6.4219 1.5996 0.08594-0.3418z" color="#000000" fill-rule="evenodd" style=""/>
    <g fill-rule="evenodd" stroke-linejoin="round">
      <path d="m25.016 32.028 1.0193 0.6921-1.2248 0.1331c0.23994-0.19895 0.32192-0.5325 0.20555-0.8252z" color="#000000" stroke-width=".066146" style=""/>
      <path d="m25.035 32a0.033076 0.033076 0 0 0-0.04883 0.04102c0.11121 0.27973 0.03154 0.59739-0.19727 0.78711a0.033076 0.033076 0 0 0 0.02539 0.05859l1.2246-0.13281a0.033076 0.033076 0 0 0 0.01563-0.06055zm-0.0039 0.07813 0.91211 0.61914-1.0957 0.11914c0.19403-0.19465 0.26204-0.47234 0.18359-0.73828z" color="#000000" style=""/>
    </g>
    <path d="m13.721 31.316-0.24219 0.25586 8.6465 8.1406 0.24023-0.25586z" color="#000000" fill-rule="evenodd" style=""/>
    <g fill-rule="evenodd" stroke-linejoin="round">
      <path d="m13.801 32.221-0.55036-1.1023 1.1334 0.48314c-0.3066 0.05613-0.54128 0.30693-0.58299 0.61914z" color="#000000" stroke-width=".066146" style=""/>
      <path d="m13.264 31.088a0.033076 0.033076 0 0 0-0.04297 0.04492l0.55078 1.1035a0.033076 0.033076 0 0 0 0.0625-0.01172c0.03986-0.29837 0.26427-0.53632 0.55664-0.58984a0.033076 0.033076 0 0 0 0.0059-0.06445zm0.05859 0.0957 1.0117 0.43359c-0.26378 0.07544-0.4602 0.28266-0.52148 0.55274z" color="#000000" style=""/>
    </g>
    <path d="m42.906 40.391-8.8203 0.73047 0.0293 0.35156 8.8203-0.73047z" color="#000000" fill-rule="evenodd" style=""/>
    <g fill-rule="evenodd" stroke-linejoin="round">
      <path d="m34.812 41.666-1.1875-0.32844 1.1173-0.51908c-0.16341 0.26542-0.13403 0.60764 0.0701 0.84752z" color="#000000" stroke-width=".066146" style=""/>
      <path d="m34.729 40.789-1.1172 0.51758a0.033076 0.033076 0 0 0 0.0059 0.0625l1.1855 0.32812a0.033076 0.033076 0 0 0 0.03516-0.05273c-0.19508-0.22925-0.22223-0.55549-0.06641-0.80859a0.033076 0.033076 0 0 0-0.04297-0.04687zm-0.0078 0.07617c-0.1211 0.24646-0.09887 0.53123 0.06055 0.75781l-1.0625-0.29297z" color="#000000" style=""/>
    </g>
    <path d="m35.943 35.773-0.13281 0.32617 5.75 2.334 0.13281-0.32617z" color="#000000" fill-rule="evenodd" style=""/>
    <g fill-rule="evenodd" stroke-linejoin="round">
      <path d="m36.346 36.587-0.91145-0.82896 1.2314 0.041c-0.2656 0.16312-0.39381 0.48176-0.3199 0.78795z" color="#000000" stroke-width=".066146" style=""/>
      <path d="m35.436 35.725a0.033076 0.033076 0 0 0-0.02344 0.05859l0.91211 0.82812a0.033076 0.033076 0 0 0 0.05469-0.03125c-0.07064-0.29262 0.05141-0.5964 0.30469-0.75195a0.033076 0.033076 0 0 0-0.01563-0.0625zm0.08789 0.07031 1.1016 0.03516c-0.21993 0.16497-0.32482 0.43071-0.28516 0.70508z" color="#000000" style=""/>
    </g>
    <path d="m13.42 16.557-0.24609 0.25391 15.471 15.084 0.24609-0.25195z" color="#000000" fill-rule="evenodd" style=""/>
    <g fill-rule="evenodd" stroke-linejoin="round">
      <path d="m28.579 30.989 0.53105 1.1117-1.1248-0.50284c0.30753-0.05077 0.54655-0.29743 0.5937-0.60887z" color="#000000" stroke-width=".066146" style=""/>
      <path d="m28.574 30.957a0.033076 0.033076 0 0 0-0.02734 0.02734c-0.04506 0.29763-0.27315 0.53166-0.56641 0.58008a0.033076 0.033076 0 0 0-0.0078 0.06445l1.123 0.50195a0.033076 0.033076 0 0 0 0.04492-0.04492l-0.53125-1.1113a0.033076 0.033076 0 0 0-0.03516-0.01758zm-0.0078 0.08398 0.47461 0.99219-1.0059-0.44922c0.26528-0.07031 0.46476-0.2742 0.53125-0.54297z" color="#000000" style=""/>
    </g>
    <path d="m41.381 29.479-5.6113 2.3242 0.13477 0.32617 5.6113-2.3242z" color="#000000" fill-rule="evenodd" style=""/>
    <g fill-rule="evenodd" stroke-linejoin="round">
      <path d="m40.657 29.508 1.231-0.04972-0.90556 0.83539c0.07459-0.30263-0.05785-0.61955-0.32547-0.78567z" color="#000000" stroke-width=".066146" style=""/>
      <path d="m41.887 29.424-1.2305 0.05078a0.033076 0.033076 0 0 0-0.01563 0.06055c0.25576 0.15876 0.38168 0.46141 0.31055 0.75a0.033076 0.033076 0 0 0 0.05469 0.0332l0.9043-0.83594a0.033076 0.033076 0 0 0-0.02344-0.05859zm-0.08594 0.07031-0.81055 0.74805c0.04047-0.27168-0.07027-0.53576-0.29102-0.70312z" color="#000000" style=""/>
    </g>
    <path d="m50.523 27.586v0.35352h3.834v-0.35352z" color="#000000" fill-rule="evenodd" style=""/>
    <g fill-rule="evenodd" stroke-linejoin="round">
      <path d="m53.678 27.335 1.1563 0.42521-1.1563 0.42521c0.18473-0.25105 0.18366-0.59452 0-0.85041z" color="#000000" stroke-width=".066146" style=""/>
      <path d="m53.689 27.305a0.033076 0.033076 0 0 0-0.03906 0.05078c0.17552 0.24456 0.17616 0.57115 0 0.81055a0.033076 0.033076 0 0 0 0.03906 0.05078l1.1562-0.42578a0.033076 0.033076 0 0 0 0-0.06055zm0.01563 0.07617 1.0352 0.38086-1.0352 0.37891c0.14115-0.23573 0.14033-0.52072 0-0.75977z" color="#000000" style=""/>
    </g>
  </g>
  <!--
  <g fill="none" stroke="#f00" stroke-width="1.35278" stroke-dasharray="2">
    <path d="m28.843 11.949-0.07504 12.644"/>
    <path d="m28.768 24.593 1.7229 7.1761"/>
    <path d="m33.474 28.333-1.4994 3.4364"/>
    <path d="m19.15 31.007 6.4228 1.5999"/>
    <path d="m22.245 39.585-8.6458-8.141"/>
    <path d="m42.921 40.567-8.8204 0.72959"/>
    <path d="m41.627 38.271-5.7498-2.3344"/>
    <path d="m13.297 16.684 15.471 15.085"/>
    <path d="m35.837 31.966 5.6111-2.3245"/>
    <path d="m50.523 27.762h3.8344"/>
    <animate attributeName="stroke-dashoffset" values="0;-8" dur="1s" repeatCount="indefinite"/>
  </g>
  -->
</svg>
<figcaption>M5Paper Power Supply Outline Diagram</figcaption>
</figure>

The following conditions must be achieved to keep the power ON:

 * Powered by USB Type-C;
 * Alarm IRQ from RTC (BM8563);
 * GPIO2 (`M5EPD_MAIN_PWR_PIN`) set to HIGH; or
 * Power button (GPIO38, `M5EPD_KEY_PUSH_PIN`)

Shutdown is achieved by setting all the above conditions to *false*.
It indicates as long as M5Paper is connected and powered by USB Type-C, always it cannot shutdown.

Then how is the shutdown process of sample programs such as [FactoryTest](https://github.com/m5stack/M5Paper_FactoryTest) handled?
The process is as follows:

```cpp
void Shutdown()
{
    // **snip**
    M5.disableEPDPower();  // digitalWrite(M5EPD_EPD_PWR_EN_PIN, 0);
    M5.disableEXTPower();  // digitalWrite(M5EPD_EXT_PWR_EN_PIN, 0);
    M5.disableMainPower(); // digitalWrite(M5EPD_MAIN_PWR_PIN, 1);
    esp_deep_sleep_start();
    while(1);
}
```

If USB Type-C is connected, `M5.disableMainPower()` (setting GPIO2 to OFF) does not turn off its power and
go to the next line and then deep sleep, not a *genuine* shutdown.
If not, it shutdown immediately after `M5.disableMainPower()` (setting GPIO2 to OFF) and `esp_deep_sleep_start()` does not executed.


### Case: Shutdown / Connected and Powered by USB Type-C

As long as M5Paper is connected and powered by USB Type-C, always one condition "Powered by USB Type-C" is *true* and it cannot shutdown.

<figure>
  <svg xmlns="http://www.w3.org/2000/svg" version="1.1" width="323.04" height="228.595" viewBox="0 0 64.608 45.719" class="fitcontain">
    <use href="#m5paper-power-diagram-base"/>
    <g fill="none" stroke="#f00" stroke-width="1.35278" stroke-dasharray="2">
      <path d="m28.843 11.949-0.07504 12.644"/>
      <path d="m28.768 24.593 1.7229 7.1761"/>
      <path d="m22.245 39.585-8.6458-8.141"/>
      <path d="m42.921 40.567-8.8204 0.72959"/>
      <path d="m41.627 38.271-5.7498-2.3344"/>
      <path d="m35.837 31.966 5.6111-2.3245"/>
      <path d="m50.523 27.762h3.8344"/>
      <animate attributeName="stroke-dashoffset" values="0;-8" dur="1s" repeatCount="indefinite"/>
    </g>
  </svg>
  <figcaption>Powered by USB Type-C</figcaption>
</figure>

After `M5.disableMainPower()` executed (setting GPIO2 to OFF), the MOS output is still HIGH and the power is still ON.

<figure>
  <svg xmlns="http://www.w3.org/2000/svg" version="1.1" width="323.04" height="228.595" viewBox="0 0 64.608 45.719" class="fitcontain">
    <use href="#m5paper-power-diagram-base"/>
    <g fill="none" stroke="#f00" stroke-width="1.35278" stroke-dasharray="2">
      <path d="m22.245 39.585-8.6458-8.141"/>
      <path d="m42.921 40.567-8.8204 0.72959"/>
      <path d="m41.627 38.271-5.7498-2.3344"/>
      <path d="m35.837 31.966 5.6111-2.3245"/>
      <path d="m50.523 27.762h3.8344"/>
      <animate attributeName="stroke-dashoffset" values="0;-8" dur="1s" repeatCount="indefinite"/>
    </g>
  </svg>
  <figcaption>Powered by USB Type-C, After main power disabled</figcaption>
</figure>

After that, if the USB Type-C cable unplugged further, the power goes off. Because the MOS output gets LOW.

<figure>
  <svg xmlns="http://www.w3.org/2000/svg" version="1.1" width="323.04" height="228.595" viewBox="0 0 64.608 45.719" class="fitcontain">
    <use href="#m5paper-power-diagram-base"/>
  </svg>
  <figcaption>Powered by USB Type-C, After main power disabled and then USB Type-C unplugged</figcaption>
</figure>

At this time, it is re-booted by pressing the PWR button, interrupt by the RTC Alarm, or plugging USB Type-C.

### Case: Shutdown / USB Type-C Unpuggled

Other hand, if the USB Type-C cable is unplugged without calling `M5.disableMainPower()`, the GPIO2 output remains HIGH.
Therefore, the power remains ON and is supplied from the LiPo battery.

It is the same condition as just after booting without the USB Type-C power supply.

<figure>
  <svg xmlns="http://www.w3.org/2000/svg" version="1.1" width="323.04" height="228.595" viewBox="0 0 64.608 45.719" class="fitcontain">
    <use href="#m5paper-power-diagram-base"/>
    <g fill="none" stroke="#f00" stroke-width="1.35278" stroke-dasharray="2">
      <path d="m28.843 11.949-0.07504 12.644"/>
      <path d="m28.768 24.593 1.7229 7.1761"/>
      <path d="m19.15 31.007 6.4228 1.5999"/>
      <path d="m35.837 31.966 5.6111-2.3245"/>
      <path d="m50.523 27.762h3.8344"/>
      <animate attributeName="stroke-dashoffset" values="0;-8" dur="1s" repeatCount="indefinite"/>
    </g>
  </svg>
  <figcaption>After USB Type-C unplugged</figcaption>
</figure>

After `M5.disableMainPower()` executed (setting GPIO2 to OFF), the MOS output and the power go off.

<figure>
  <svg xmlns="http://www.w3.org/2000/svg" version="1.1" width="323.04" height="228.595" viewBox="0 0 64.608 45.719" class="fitcontain">
    <use href="#m5paper-power-diagram-base"/>
  </svg>
  <figcaption>After USB Type-C unplugged and set GPIO2 to OFF</figcaption>
</figure>

At this time, it is re-booted by pressing the PWR button, interrupt by the RTC Alarm, or plugging USB Type-C.

### Case: Deep sleep / Connected and Powered by USB Type-C

The ESP32 immediately stops operating when it goes to deep sleep.
The output of GPIO2 goes LOW. Because GPIOs do not keep their state in deep sleep to conserve power.

<figure>
  <svg xmlns="http://www.w3.org/2000/svg" version="1.1" width="323.04" height="228.595" viewBox="0 0 64.608 45.719" class="fitcontain">
    <use href="#m5paper-power-diagram-base"/>
    <g fill="none" stroke="#f00" stroke-width="1.35278" stroke-dasharray="2">
      <path d="m22.245 39.585-8.6458-8.141"/>
      <path d="m42.921 40.567-8.8204 0.72959"/>
      <path d="m41.627 38.271-5.7498-2.3344"/>
      <path d="m35.837 31.966 5.6111-2.3245"/>
      <path d="m50.523 27.762h3.8344"/>
      <animate attributeName="stroke-dashoffset" values="0;-8" dur="1s" repeatCount="indefinite"/>
    </g>
  </svg>
  <figcaption>Deep sleep, powered by USB Type-C</figcaption>
</figure>

Pressing the PWR button etc... does not wake up or restart from the deep sleep status.
Because the MOS output remains HIGH and unchanged.

The ESP32 remains powered by USB Type-C, so the ULP coprocessor works.
ESP32 wake-up functions such as `esp_sleep_enable_timer_wakeup()` or ULP coprocessor program can be used.

### Case: Deep sleep / USB Type-C Unpuggled

The ESP32 immediately stops operating when it goes to deep sleep.
The output of GPIO2 goes LOW. Because GPIOs do not keep their state in deep sleep to conserve power.

When USB Type-C Unpuggled, such a process causes MOS output to OFF and a transition to a state equivalent to a *genuine* shutdown.

<figure>
  <svg xmlns="http://www.w3.org/2000/svg" version="1.1" width="323.04" height="228.595" viewBox="0 0 64.608 45.719" class="fitcontain">
    <use href="#m5paper-power-diagram-base"/>
  </svg>
  <figcaption>After Deep sleep and USB Type-C unplugged</figcaption>
</figure>

The ESP32 is not powered, so the ULP coprocessor does not work.
`esp_sleep_enable_timer_wakeup()` or ULP coprocessor program cannot be used for wake-up.

At this time, it is re-booted by pressing the PWR button, interrupt by the RTC Alarm, or plugging USB Type-C.


It is possible to change this behaviour to add following to lines before going to deep sleep.

```cpp
gpio_hold_en((gpio_num_t) M5EPD_MAIN_PWR_PIN);
gpio_deep_sleep_hold_en();
// ...snip...
esp_deep_sleep_start();
```

In this case, it keeps the GPIO2 even during deep sleep.

<figure>
  <svg xmlns="http://www.w3.org/2000/svg" version="1.1" width="323.04" height="228.595" viewBox="0 0 64.608 45.719" class="fitcontain">
    <use href="#m5paper-power-diagram-base"/>
    <g fill="none" stroke="#f00" stroke-width="1.35278" stroke-dasharray="2">
      <path d="m28.843 11.949-0.07504 12.644"/>
      <path d="m28.768 24.593 1.7229 7.1761"/>
      <path d="m19.15 31.007 6.4228 1.5999"/>
      <path d="m35.837 31.966 5.6111-2.3245"/>
      <path d="m50.523 27.762h3.8344"/>
      <animate attributeName="stroke-dashoffset" values="0;-8" dur="1s" repeatCount="indefinite"/>
    </g>
  </svg>
  <figcaption>Deep sleep with keeping GPIO2 to HIGH, powered by USB Type-C</figcaption>
</figure>

In this case, pressing the PWR button etc... does not wake up or restart from the deep sleep status.
Because GPIO2 keeps HIGH and the MOS output remains HIGH and unchanged.

The ESP32 remains powered by the LiPo battery, so the ULP coprocessor works.
ESP32 wake-up functions such as `esp_sleep_enable_timer_wakeup()` or ULP coprocessor program can be used.

### Note: RTC Alarm issue

When writing a program to reboot using RTC (BM8563) Alarm, be aware of the following bugs!

* https://github.com/m5stack/M5EPD/issues/26
* https://github.com/m5stack/M5-CoreInk/pull/3

### References

* [M5Paper](https://docs.m5stack.com/en/core/m5paper), M5Stack
* [M5Paper Shutdown\(\) / Deep Sleep / Wakeup \| M5Stack Community](https://community.m5stack.com/topic/2892/m5paper-shutdown-deep-sleep-wakeup)
* [M5Stack CoreInk、M5Paperのバッテリーについて \| Lang-ship](https://lang-ship.com/blog/work/m5stack-coreink-m5paper/) (Japanese)
* [Low-Cost, µP Supervisory Circuits - BM8563](https://www.belling.com.cn/media/file_object/bel_product/BM8563/datasheet/BM8563_V1.1_cn.pdf), BM8563 Datasheet, Shanghai Belling (Chinese)

