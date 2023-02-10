import 'dart:collection';

import 'package:flutter/material.dart';
import 'package:html/dom.dart' as dom;
//ignore: implementation_imports
import 'package:html/src/query_selector.dart';
import 'package:list_counter/list_counter.dart';

import '../core/html5.dart';
import '../parsers/css.dart';

/// A [StyledElement] applies a style to all of its children.
class StyledElement {
  final String name;
  final String elementId;
  final List<String> elementClasses;
  List<StyledElement> children;
  CSS3 style;
  final dom.Element? _node;
  final ListQueue<Counter> counters = ListQueue<Counter>();

  StyledElement({
    this.name = "[[No name]]",
    this.elementId = "[[No ID]]",
    this.elementClasses = const [],
    required this.children,
    required this.style,
    required dom.Element? node,
  }) : _node = node;

  bool matchesSelector(String selector) =>
      (_node != null && matches(_node!, selector)) || name == selector;

  Map<String, String> get attributes =>
      _node?.attributes.map((key, value) {
        return MapEntry(key.toString(), value);
      }) ??
      <String, String>{};

  dom.Element? get element => _node;

  @override
  String toString() {
    String selfData =
        "[$name] ${children.length} ${elementClasses.isNotEmpty == true ? 'C:${elementClasses.toString()}' : ''}${elementId.isNotEmpty == true ? 'ID: $elementId' : ''}";
    for (var child in children) {
      selfData += ("\n${child.toString()}").replaceAll(RegExp("^", multiLine: true), "-");
    }
    return selfData;
  }
}

StyledElement parseStyledElement(
  dom.Element element,
  List<StyledElement> children,
) {
  StyledElement styledElement = StyledElement(
    name: element.localName!,
    elementId: element.id,
    elementClasses: element.classes.toList(),
    children: children,
    node: element,
    style: CSS3(),
  );

  switch (element.localName) {
    case "abbr":
    case "acronym":
      styledElement.style = CSS3(
        textDecoration: TextDecoration.underline,
        textDecorationStyle: TextDecorationStyle.dotted,
      );
      break;
    case "address":
      continue italics;
    case "article":
      styledElement.style = CSS3(
        display: Display.block,
      );
      break;
    case "aside":
      styledElement.style = CSS3(
        display: Display.block,
      );
      break;
    bold:
    case "b":
      styledElement.style = CSS3(
        fontWeight: FontWeight.bold,
      );
      break;
    case "bdo":
      TextDirection textDirection =
          ((element.attributes["dir"] ?? "ltr") == "rtl") ? TextDirection.rtl : TextDirection.ltr;
      styledElement.style = CSS3(
        direction: textDirection,
      );
      break;
    case "big":
      styledElement.style = CSS3(
        fontSize: FontSize.larger,
      );
      break;
    case "blockquote":
      if (element.parent!.localName == "blockquote") {
        styledElement.style = CSS3(
          margin: Margins.only(left: 40.0, right: 40.0, bottom: 14.0),
          display: Display.block,
        );
      } else {
        styledElement.style = CSS3(
          margin: Margins.symmetric(horizontal: 40.0, vertical: 14.0),
          display: Display.block,
        );
      }
      break;
    case "body":
      styledElement.style = CSS3(
        margin: Margins.all(8.0),
        display: Display.block,
      );
      break;
    case "center":
      styledElement.style = CSS3(
        alignment: Alignment.center,
        display: Display.block,
      );
      break;
    case "cite":
      continue italics;
    monospace:
    case "code":
      styledElement.style = CSS3(
        fontFamily: 'Monospace',
      );
      break;
    case "dd":
      styledElement.style = CSS3(
        margin: Margins.only(left: 40.0),
        display: Display.block,
      );
      break;
    strikeThrough:
    case "del":
      styledElement.style = CSS3(
        textDecoration: TextDecoration.lineThrough,
      );
      break;
    case "dfn":
      continue italics;
    case "div":
      styledElement.style = CSS3(
        margin: Margins.all(0),
        display: Display.block,
      );
      break;
    case "dl":
      styledElement.style = CSS3(
        margin: Margins.symmetric(vertical: 14.0),
        display: Display.block,
      );
      break;
    case "dt":
      styledElement.style = CSS3(
        display: Display.block,
      );
      break;
    case "em":
      continue italics;
    case "figcaption":
      styledElement.style = CSS3(
        display: Display.block,
      );
      break;
    case "figure":
      styledElement.style = CSS3(
        margin: Margins.symmetric(vertical: 14.0, horizontal: 40.0),
        display: Display.block,
      );
      break;
    case "footer":
      styledElement.style = CSS3(
        display: Display.block,
      );
      break;
    case "font":
      styledElement.style = CSS3(
        color: element.attributes['color'] != null
            ? element.attributes['color']!.startsWith("#")
                ? Expression.stringToColor(element.attributes['color']!)
                : Expression.namedColorToColor(element.attributes['color']!)
            : null,
        fontFamily: element.attributes['face']?.split(",").first,
        fontSize: element.attributes['size'] != null
            ? numberToFontSize(element.attributes['size']!)
            : null,
      );
      break;
    case "h1":
      styledElement.style = CSS3(
        fontSize: FontSize(2, Unit.em),
        fontWeight: FontWeight.bold,
        margin: Margins.symmetric(vertical: 0.67, unit: Unit.em),
        display: Display.block,
      );
      break;
    case "h2":
      styledElement.style = CSS3(
        fontSize: FontSize(1.5, Unit.em),
        fontWeight: FontWeight.bold,
        margin: Margins.symmetric(vertical: 0.83, unit: Unit.em),
        display: Display.block,
      );
      break;
    case "h3":
      styledElement.style = CSS3(
        fontSize: FontSize(1.17, Unit.em),
        fontWeight: FontWeight.bold,
        margin: Margins.symmetric(vertical: 1, unit: Unit.em),
        display: Display.block,
      );
      break;
    case "h4":
      styledElement.style = CSS3(
        fontWeight: FontWeight.bold,
        margin: Margins.symmetric(vertical: 1.33, unit: Unit.em),
        display: Display.block,
      );
      break;
    case "h5":
      styledElement.style = CSS3(
        fontSize: FontSize(0.83, Unit.em),
        fontWeight: FontWeight.bold,
        margin: Margins.symmetric(vertical: 1.67, unit: Unit.em),
        display: Display.block,
      );
      break;
    case "h6":
      styledElement.style = CSS3(
        fontSize: FontSize(0.67, Unit.em),
        fontWeight: FontWeight.bold,
        margin: Margins.symmetric(vertical: 2.33, unit: Unit.em),
        display: Display.block,
      );
      break;
    case "header":
      styledElement.style = CSS3(
        display: Display.block,
      );
      break;
    case "hr":
      styledElement.style = CSS3(
        margin: Margins(
          top: Margin(0.5, Unit.em),
          bottom: Margin(0.5, Unit.em),
          left: Margin.auto(),
          right: Margin.auto(),
        ),
        border: Border.all(),
        display: Display.block,
      );
      break;
    case "html":
      styledElement.style = CSS3(
        display: Display.block,
      );
      break;
    italics:
    case "i":
      styledElement.style = CSS3(
        fontStyle: FontStyle.italic,
      );
      break;
    case "ins":
      continue underline;
    case "kbd":
      continue monospace;
    case "li":
      styledElement.style = CSS3(
        display: Display.listItem,
      );
      break;
    case "main":
      styledElement.style = CSS3(
        display: Display.block,
      );
      break;
    case "mark":
      styledElement.style = CSS3(
        color: Colors.black,
        backgroundColor: Colors.yellow,
      );
      break;
    case "nav":
      styledElement.style = CSS3(
        display: Display.block,
      );
      break;
    case "noscript":
      styledElement.style = CSS3(
        display: Display.block,
      );
      break;
    case "ol":
    case "ul":
      styledElement.style = CSS3(
        display: Display.block,
        listStyleType: element.localName == "ol" ? ListStyleType.decimal : ListStyleType.disc,
        padding: const EdgeInsets.only(left: 40),
      );
      break;
    case "p":
      styledElement.style = CSS3(
        margin: Margins.symmetric(vertical: 1, unit: Unit.em),
        display: Display.block,
      );
      break;
    case "pre":
      styledElement.style = CSS3(
        fontFamily: 'monospace',
        margin: Margins.symmetric(vertical: 14.0),
        whiteSpace: WhiteSpace.pre,
        display: Display.block,
      );
      break;
    case "q":
      styledElement.style = CSS3(
        before: "\"",
        after: "\"",
      );
      break;
    case "s":
      continue strikeThrough;
    case "samp":
      continue monospace;
    case "section":
      styledElement.style = CSS3(
        display: Display.block,
      );
      break;
    case "small":
      styledElement.style = CSS3(
        fontSize: FontSize.smaller,
      );
      break;
    case "strike":
      continue strikeThrough;
    case "strong":
      continue bold;
    case "sub":
      styledElement.style = CSS3(
        fontSize: FontSize.smaller,
        verticalAlign: VerticalAlign.sub,
      );
      break;
    case "sup":
      styledElement.style = CSS3(
        fontSize: FontSize.smaller,
        verticalAlign: VerticalAlign.sup,
      );
      break;
    case "tt":
      continue monospace;
    underline:
    case "u":
      styledElement.style = CSS3(
        textDecoration: TextDecoration.underline,
      );
      break;
    case "var":
      continue italics;
  }

  return styledElement;
}

typedef ListCharacter = String Function(int i);

FontSize numberToFontSize(String num) {
  switch (num) {
    case "1":
      return FontSize.xxSmall;
    case "2":
      return FontSize.xSmall;
    case "3":
      return FontSize.small;
    case "4":
      return FontSize.medium;
    case "5":
      return FontSize.large;
    case "6":
      return FontSize.xLarge;
    case "7":
      return FontSize.xxLarge;
  }
  if (num.startsWith("+")) {
    final relativeNum = double.tryParse(num.substring(1)) ?? 0;
    return numberToFontSize((3 + relativeNum).toString());
  }
  if (num.startsWith("-")) {
    final relativeNum = double.tryParse(num.substring(1)) ?? 0;
    return numberToFontSize((3 - relativeNum).toString());
  }
  return FontSize.medium;
}

extension DeepCopy on ListQueue<Counter> {
  ListQueue<Counter> deepCopy() {
    return ListQueue<Counter>.from(map((counter) {
      return Counter(counter.name, counter.value);
    }));
  }
}
