import 'package:flutter/material.dart';
import 'package:html/dom.dart' as dom;

import '../core/html5.dart';

/// An [ReactElement] is a [StyledElement] that takes user gestures (e.g. tap).
class ReactElement extends StyledElement {
  String? href;

  ReactElement({
    required super.name,
    required super.children,
    required super.style,
    required this.href,
    required dom.Node node,
    required super.elementId,
  }) : super(node: node as dom.Element?);
}

/// A [Gesture] indicates the type of interaction by a user.
enum Gesture {
  tap,
}

StyledElement parseReactElement(
  dom.Element element,
  List<StyledElement> children,
) {
  switch (element.localName) {
    case "a":
      if (element.attributes.containsKey('href')) {
        return ReactElement(
          name: element.localName!,
          children: children,
          href: element.attributes['href'],
          style: CSS3(
            color: Colors.blue,
            textDecoration: TextDecoration.underline,
          ),
          node: element,
          elementId: element.id,
        );
      }
      // When <a> tag have no href, it must be non clickable and without decoration.
      return StyledElement(
        name: element.localName!,
        children: children,
        style: CSS3(),
        node: element,
        elementId: element.id,
      );

    /// will never be called, just to suppress missing return warning
    default:
      return ReactElement(
        name: element.localName!,
        children: children,
        node: element,
        href: '',
        style: CSS3(),
        elementId: "[[No ID]]",
      );
  }
}
