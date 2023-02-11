# HTML5

A Flutter widget for rendering HTML and CSS as Flutter widgets.

<table>
  <tr>
    <td align="center">Screenshot 1</td>
    <td align="center">Screenshot 2</td>
    <td align="center">Screenshot 3</td>
  </tr>
  <tr>
    <td><img alt="Screenshot of HTML5" src="https://raw.githubusercontent.com/Sub6Resources/flutter_html/master/.github/flutter_html_screenshot.png" width="250"/></td>
    <td><img alt="Screenshot of HTML5" src="https://raw.githubusercontent.com/Sub6Resources/flutter_html/master/.github/flutter_html_screenshot2.png" width="250"/></td>
    <td><img alt="Screenshot of HTML5" src="https://raw.githubusercontent.com/Sub6Resources/flutter_html/master/.github/flutter_html_screenshot3.png" width="250"/></td>
  </tr>
 </table>

## Table of Contents:

- [Installing](#installing)

- [Currently Supported HTML Tags](#currently-supported-html-tags)

- [Currently Supported CSS Attributes](#currently-supported-css-attributes)

- [Currently Supported Inline CSS Attributes](#currently-supported-inline-css-attributes)

## Installing:

Add the following to your `pubspec.yaml` file:

```yaml
    ...
    dependencies:
      html5_api: ^0.0.1
```

## Currently Supported HTML Tags:

|              |            |           |            |              |          |          |         |          |           |              |
|--------------|------------|-----------|------------|--------------|----------|----------|---------|----------|-----------|--------------|
| `a`          | `abbr`     | `acronym` | `address`  | `article`    | `aside`  | `audio`  | `b`     | `bdi`    | `bdo`     | `big`        |
| `blockquote` | `body`     | `br`      | `caption`  | `cite`       | `code`   | `data`   | `dd`    | `del`    | `details` | `dfn`        |
| `div`        | `dl`       | `dt`      | `em`       | `figcaption` | `figure` | `footer` | `font`  | `h1`     | `h2`      | `h3`         |
| `h4`         | `h5`       | `h6`      | `header`   | `hr`         | `i`      | `iframe` | `img`   | `ins`    | `kbd`     | `li`         |
| `main`       | `mark`     | `nav`     | `noscript` | `ol`         | `p`      | `pre`    | `q`     | `rp`     | `rt`      | `ruby`       |
| `s`          | `samp`     | `section` | `small`    | `span`       | `strike` | `strong` | `sub`   | `sup`    | `summary` | `svg`        |
| `table`      | `tbody`    | `td`      | `template` | `tfoot`      | `th`     | `thead`  | `time`  | `tr`     | `tt`      | `u`          |
| `ul`         | `var`      | `video`   | `math`:    | `mrow`       | `msup`   | `msub`   | `mover` | `munder` | `msubsup` | `moverunder` |
| `mfrac`      | `mlongdiv` | `msqrt`   | `mroot`    | `mi`         | `mn`     | `mo`     |         |          |           |              | 

## Currently Supported CSS Attributes:

|                    |                  |               |                   |                         |                         |                             |
|--------------------|------------------|---------------|-------------------|-------------------------|-------------------------|-----------------------------|
| `background-color` | `color`          | `direction`   | `display`         | `font-family`           | `font-feature-settings` | `font-size`                 |
| `font-style`       | `font-weight`    | `height`      | `letter-spacing`  | `line-height`           | `list-style-type`       | `list-style-position`       |
| `padding`          | `margin`         | `text-align`  | `text-decoration` | `text-decoration-color` | `text-decoration-style` | `text-decoration-thickness` |
| `text-shadow`      | `vertical-align` | `white-space` | `width`           | `word-spacing`          |                         |                             |

## Currently Supported Inline CSS Attributes:

|                                          |                                          |                   |                         |                         |                       |                                            |
|------------------------------------------|------------------------------------------|-------------------|-------------------------|-------------------------|-----------------------|--------------------------------------------|
| `background-color`                       | `border` (including specific directions) | `color`           | `direction`             | `display`               | `font-family`         | `font-feature-settings`                    |
| `font-size`                              | `font-style`                             | `font-weight`     | `line-height`           | `list-style-type`       | `list-style-position` | `padding`  (including specific directions) |
| `margin` (including specific directions) | `text-align`                             | `text-decoration` | `text-decoration-color` | `text-decoration-style` | `text-shadow`         |                                            |

Don't see a tag or attribute you need? File a feature request or contribute to the project!

## Usage

- [See wiki for more details]()

```dart
import 'html5/html5.dart';

Widget html = Html(
    data: """
       <h1>Table support:</h1>
       <table>
       <colgroup>
       <col width="50%" />
       <col span="2" width="25%" />
       </colgroup>
       <thead>
       <tr><th>One</th><th>Two</th><th>Three</th></tr>
       </thead>
       <tbody>
       <tr>
       <td rowspan='2'>Rowspan<br>Rowspan<br>Rowspan<br>Rowspan<br>Rowspan<br>Rowspan<br>Rowspan<br>Rowspan<br>Rowspan<br>Rowspan</td><td>Data</td><td>Data</td>
       </tr>
       <tr>
       <td colspan="2"><img alt='Google' src='https://www.google.com/images/branding/googlelogo/2x/googlelogo_color_92x30dp.png' /></td>
       </tr>
       </tbody>
       <tfoot>
       <tr><td>fData</td><td>fData</td><td>fData</td></tr>
       </tfoot>
       </table>""",
    style: {
      // tables will have the below background color
      "table": Style(
        backgroundColor: Color.fromARGB(0x50, 0xee, 0xee, 0xee),
      ),
      // some other granular customizations are also possible
      "tr": Style(
        border: Border(bottom: BorderSide(color: Colors.grey)),
      ),
      "th": Style(
        padding: EdgeInsets.all(6),
        backgroundColor: Colors.grey,
      ),
      "td": Style(
        padding: EdgeInsets.all(6),
        alignment: Alignment.topLeft,
      ),
      // text that renders h1 elements will be red
      "h1": Style(color: Colors.red),
    }
);
```
