import 'dart:ui';

import 'package:csslib/parser.dart' as css_parser;
import 'package:csslib/visitor.dart' as css;
import 'package:flutter/material.dart';
import 'package:qp_xt/qp_xt.dart';

import '../core/html5.dart';
import '../style/size.dart';
import '../tags/utils.dart';
import 'html.dart';

CSS3 cssToStyle(Map<String, List<css.Expression>> exp) {
  //...
  final style = CSS3();
  //...
  exp.forEach((property, value) {
    if (value.isNotEmpty) {
      switch (property) {
        case 'background-color':
          //...background
          final color = Expression.toColor(value.first);
          style.backgroundColor = color ?? style.backgroundColor;
          break;

        case 'border':
          //...border-color
          expVsColor(element) => Expression.toColor(element) != null;
          final widths = value.whereType<css.LiteralTerm>().toList()
            ..removeWhere(
              (element) {
                return element.text != "thin" &&
                    element.text != "medium" &&
                    element.text != "thick" &&
                    element is! css.LengthTerm &&
                    element is! css.PercentageTerm &&
                    element is! css.EmTerm &&
                    element is! css.RemTerm &&
                    element is! css.NumberTerm;
              },
            );
          final colors = value.where(expVsColor).toList();
          //...border-style
          expVsBorder(element) => ![
                "dotted",
                "dashed",
                "solid",
                "double",
                "groove",
                "ridge",
                "inset",
                "outset",
                "none",
                "hidden",
              ].contains(element.text);
          final styles = value.whereType<css.LiteralTerm>().toList() //
            ..removeWhere(expVsBorder);
          //...border
          style.border = Expression.toBorder(widths, styles, colors);
          break;

        case 'border-left':
          final borderWidths = value.whereType<css.LiteralTerm>().toList()
            ..removeWhere(
              (element) {
                return element.text != "thin" &&
                    element.text != "medium" &&
                    element.text != "thick" &&
                    element is! css.LengthTerm &&
                    element is! css.PercentageTerm &&
                    element is! css.EmTerm &&
                    element is! css.RemTerm &&
                    element is! css.NumberTerm;
              },
            );
          final borderWidth = borderWidths.firstWhereOrNull();
          css.Expression? borderColor =
              value.firstWhereOrNull((element) => Expression.toColor(element) != null);
          List<css.LiteralTerm?>? potentialStyles = value.whereType<css.LiteralTerm>().toList();

          /// Currently doesn't matter, as Flutter only supports "solid"
          /// or "none", but may support more in the future.
          List<String> possibleBorderValues = [
            "dotted",
            "dashed",
            "solid",
            "double",
            "groove",
            "ridge",
            "inset",
            "outset",
            "none",
            "hidden"
          ];

          /// List<css.LiteralTerm> might include other values than the ones we want for [BorderSide.style], so make sure to remove those before passing it to [ExpressionMapping]
          potentialStyles.removeWhere(
              (element) => element == null || !possibleBorderValues.contains(element.text));
          css.LiteralTerm? borderStyle = potentialStyles.firstOrNull;
          Border newBorder = Border(
            left: style.border?.left.copyWith(
                  width: Expression.toBorderWidth(borderWidth),
                  style: Expression.toBorderStyle(borderStyle),
                  color: Expression.toColor(borderColor),
                ) ??
                BorderSide(
                  width: Expression.toBorderWidth(borderWidth),
                  style: Expression.toBorderStyle(borderStyle),
                  color: Expression.toColor(borderColor) ?? Colors.black,
                ),
            right: style.border?.right ?? BorderSide.none,
            top: style.border?.top ?? BorderSide.none,
            bottom: style.border?.bottom ?? BorderSide.none,
          );
          style.border = newBorder;
          break;
        case 'border-right':
          List<css.LiteralTerm?>? borderWidths = value.whereType<css.LiteralTerm>().toList();

          /// List<css.LiteralTerm> might include other values than the ones we want for [BorderSide.width], so make sure to remove those before passing it to [ExpressionMapping]
          borderWidths.removeWhere((element) =>
              element == null ||
              (element.text != "thin" &&
                  element.text != "medium" &&
                  element.text != "thick" &&
                  element is! css.LengthTerm &&
                  element is! css.PercentageTerm &&
                  element is! css.EmTerm &&
                  element is! css.RemTerm &&
                  element is! css.NumberTerm));
          css.LiteralTerm? borderWidth =
              borderWidths.firstWhereOrNull((element) => element != null);
          css.Expression? borderColor =
              value.firstWhereOrNull((element) => Expression.toColor(element) != null);
          List<css.LiteralTerm?>? potentialStyles = value.whereType<css.LiteralTerm>().toList();

          /// Currently doesn't matter, as Flutter only supports "solid" or "none", but may support more in the future.
          List<String> possibleBorderValues = [
            "dotted",
            "dashed",
            "solid",
            "double",
            "groove",
            "ridge",
            "inset",
            "outset",
            "none",
            "hidden"
          ];

          /// List<css.LiteralTerm> might include other values than the ones we want for [BorderSide.style], so make sure to remove those before passing it to [ExpressionMapping]
          potentialStyles.removeWhere(
              (element) => element == null || !possibleBorderValues.contains(element.text));
          css.LiteralTerm? borderStyle = potentialStyles.firstOrNull;
          Border newBorder = Border(
            left: style.border?.left ?? BorderSide.none,
            right: style.border?.right.copyWith(
                  width: Expression.toBorderWidth(borderWidth),
                  style: Expression.toBorderStyle(borderStyle),
                  color: Expression.toColor(borderColor),
                ) ??
                BorderSide(
                  width: Expression.toBorderWidth(borderWidth),
                  style: Expression.toBorderStyle(borderStyle),
                  color: Expression.toColor(borderColor) ?? Colors.black,
                ),
            top: style.border?.top ?? BorderSide.none,
            bottom: style.border?.bottom ?? BorderSide.none,
          );
          style.border = newBorder;
          break;
        case 'border-top':
          List<css.LiteralTerm?>? borderWidths = value.whereType<css.LiteralTerm>().toList();

          /// List<css.LiteralTerm> might include other values than the ones we want for [BorderSide.width], so make sure to remove those before passing it to [ExpressionMapping]
          borderWidths.removeWhere(
            (element) {
              return element == null ||
                  (element.text != "thin" &&
                      element.text != "medium" &&
                      element.text != "thick" &&
                      element is! css.LengthTerm &&
                      element is! css.PercentageTerm &&
                      element is! css.EmTerm &&
                      element is! css.RemTerm &&
                      element is! css.NumberTerm);
            },
          );
          css.LiteralTerm? borderWidth =
              borderWidths.firstWhereOrNull((element) => element != null);
          css.Expression? borderColor =
              value.firstWhereOrNull((element) => Expression.toColor(element) != null);
          List<css.LiteralTerm?>? potentialStyles = value.whereType<css.LiteralTerm>().toList();

          /// Currently doesn't matter, as Flutter only supports "solid" or "none", but may support more in the future.
          List<String> possibleBorderValues = [
            "dotted",
            "dashed",
            "solid",
            "double",
            "groove",
            "ridge",
            "inset",
            "outset",
            "none",
            "hidden"
          ];

          /// List<css.LiteralTerm> might include other values than the ones we want for [BorderSide.style], so make sure to remove those before passing it to [ExpressionMapping]
          potentialStyles.removeWhere(
              (element) => element == null || !possibleBorderValues.contains(element.text));
          css.LiteralTerm? borderStyle = potentialStyles.firstOrNull;
          Border newBorder = Border(
            left: style.border?.left ?? BorderSide.none,
            right: style.border?.right ?? BorderSide.none,
            top: style.border?.top.copyWith(
                  width: Expression.toBorderWidth(borderWidth),
                  style: Expression.toBorderStyle(borderStyle),
                  color: Expression.toColor(borderColor),
                ) ??
                BorderSide(
                  width: Expression.toBorderWidth(borderWidth),
                  style: Expression.toBorderStyle(borderStyle),
                  color: Expression.toColor(borderColor) ?? Colors.black,
                ),
            bottom: style.border?.bottom ?? BorderSide.none,
          );
          style.border = newBorder;
          break;
        case 'border-bottom':
          List<css.LiteralTerm?>? borderWidths = value.whereType<css.LiteralTerm>().toList();

          /// List<css.LiteralTerm> might include other values than the ones we want for [BorderSide.width], so make sure to remove those before passing it to [ExpressionMapping]
          borderWidths.removeWhere((element) =>
              element == null ||
              (element.text != "thin" &&
                  element.text != "medium" &&
                  element.text != "thick" &&
                  element is! css.LengthTerm &&
                  element is! css.PercentageTerm &&
                  element is! css.EmTerm &&
                  element is! css.RemTerm &&
                  element is! css.NumberTerm));
          css.LiteralTerm? borderWidth =
              borderWidths.firstWhereOrNull((element) => element != null);
          css.Expression? borderColor =
              value.firstWhereOrNull((element) => Expression.toColor(element) != null);
          List<css.LiteralTerm?>? potentialStyles = value.whereType<css.LiteralTerm>().toList();

          /// Currently doesn't matter, as Flutter only supports "solid" or "none", but may support more in the future.
          List<String> possibleBorderValues = [
            "dotted",
            "dashed",
            "solid",
            "double",
            "groove",
            "ridge",
            "inset",
            "outset",
            "none",
            "hidden"
          ];

          /// List<css.LiteralTerm> might include other values than the ones we want for [BorderSide.style], so make sure to remove those before passing it to [ExpressionMapping]
          potentialStyles.removeWhere(
              (element) => element == null || !possibleBorderValues.contains(element.text));
          css.LiteralTerm? borderStyle = potentialStyles.firstOrNull;
          Border newBorder = Border(
            left: style.border?.left ?? BorderSide.none,
            right: style.border?.right ?? BorderSide.none,
            top: style.border?.top ?? BorderSide.none,
            bottom: style.border?.bottom.copyWith(
                  width: Expression.toBorderWidth(borderWidth),
                  style: Expression.toBorderStyle(borderStyle),
                  color: Expression.toColor(borderColor),
                ) ??
                BorderSide(
                  width: Expression.toBorderWidth(borderWidth),
                  style: Expression.toBorderStyle(borderStyle),
                  color: Expression.toColor(borderColor) ?? Colors.black,
                ),
          );
          style.border = newBorder;
          break;
        case 'color':
          style.color = Expression.toColor(value.first) ?? style.color;
          break;
        case 'direction':
          style.direction = Expression.expressionToDirection(value.first);
          break;
        case 'display':
          style.display = Expression.expressionToDisplay(value.first);
          break;
        case 'line-height':
          style.lineHeight = Expression.expressionToLineHeight(value.first);
          break;
        case 'font-family':
          style.fontFamily = Expression.expressionToFontFamily(value.first) ?? style.fontFamily;
          break;
        case 'font-feature-settings':
          style.fontFeatureSettings = Expression.expressionToFontFeatureSettings(value);
          break;
        case 'font-size':
          style.fontSize = Expression.expressionToFontSize(value.first) ?? style.fontSize;
          break;
        case 'font-style':
          style.fontStyle = Expression.expressionToFontStyle(value.first);
          break;
        case 'font-weight':
          style.fontWeight = Expression.expressionToFontWeight(value.first);
          break;
        case 'list-style':
          css.LiteralTerm? position = value.firstWhereOrNull(
                  (e) => e is css.LiteralTerm && (e.text == "outside" || e.text == "inside"))
              as css.LiteralTerm?;
          css.UriTerm? image = value.firstWhereOrNull((e) => e is css.UriTerm) as css.UriTerm?;
          css.LiteralTerm? type = value.firstWhereOrNull(
                  (e) => e is css.LiteralTerm && e.text != "outside" && e.text != "inside")
              as css.LiteralTerm?;
          if (position != null) {
            switch (position.text) {
              case 'outside':
                style.listStylePosition = ListStylePosition.outside;
                break;
              case 'inside':
                style.listStylePosition = ListStylePosition.inside;
                break;
            }
          }
          if (image != null) {
            style.listStyleImage =
                Expression.expressionToListStyleImage(image) ?? style.listStyleImage;
          } else if (type != null) {
            style.listStyleType = Expression.expressionToListStyleType(type) ?? style.listStyleType;
          }
          break;
        case 'list-style-image':
          if (value.first is css.UriTerm) {
            style.listStyleImage =
                Expression.expressionToListStyleImage(value.first as css.UriTerm) ??
                    style.listStyleImage;
          }
          break;
        case 'list-style-position':
          if (value.first is css.LiteralTerm) {
            switch ((value.first as css.LiteralTerm).text) {
              case 'outside':
                style.listStylePosition = ListStylePosition.outside;
                break;
              case 'inside':
                style.listStylePosition = ListStylePosition.inside;
                break;
            }
          }
          break;
        case 'height':
          style.height = Expression.expressionToHeight(value.first) ?? style.height;
          break;
        case 'list-style-type':
          if (value.first is css.LiteralTerm) {
            style.listStyleType =
                Expression.expressionToListStyleType(value.first as css.LiteralTerm) ??
                    style.listStyleType;
          }
          break;
        case 'margin':
          List<css.LiteralTerm>? marginLengths = value.whereType<css.LiteralTerm>().toList();

          /// List<css.LiteralTerm> might include other values than the ones we want for margin length, so make sure to remove those before passing it to [ExpressionMapping]
          marginLengths.removeWhere((element) =>
              element is! css.LengthTerm &&
              element is! css.EmTerm &&
              element is! css.RemTerm &&
              element is! css.NumberTerm &&
              !(element.text == 'auto'));
          Margins margin = Expression.expressionToMargins(marginLengths);
          style.margin = (style.margin ?? Margins.all(0)).copyWith(
            left: margin.left,
            right: margin.right,
            top: margin.top,
            bottom: margin.bottom,
          );
          break;
        case 'margin-left':
          style.margin = (style.margin ?? Margins.zero)
              .copyWith(left: Expression.expressionToMargin(value.first));
          break;
        case 'margin-right':
          style.margin = (style.margin ?? Margins.zero)
              .copyWith(right: Expression.expressionToMargin(value.first));
          break;
        case 'margin-top':
          style.margin = (style.margin ?? Margins.zero)
              .copyWith(top: Expression.expressionToMargin(value.first));
          break;
        case 'margin-bottom':
          style.margin = (style.margin ?? Margins.zero)
              .copyWith(bottom: Expression.expressionToMargin(value.first));
          break;
        case 'padding':
          List<css.LiteralTerm>? paddingLengths = value.whereType<css.LiteralTerm>().toList();

          /// List<css.LiteralTerm> might include other values than the ones we want for padding length, so make sure to remove those before passing it to [ExpressionMapping]
          paddingLengths.removeWhere((element) =>
              element is! css.LengthTerm &&
              element is! css.EmTerm &&
              element is! css.RemTerm &&
              element is! css.NumberTerm);
          List<double?> padding = Expression.expressionToPadding(paddingLengths);
          style.padding = (style.padding ?? EdgeInsets.zero).copyWith(
            left: padding[0],
            right: padding[1],
            top: padding[2],
            bottom: padding[3],
          );
          break;
        case 'padding-left':
          style.padding = (style.padding ?? EdgeInsets.zero)
              .copyWith(left: Expression.expressionToPaddingLength(value.first));
          break;
        case 'padding-right':
          style.padding = (style.padding ?? EdgeInsets.zero)
              .copyWith(right: Expression.expressionToPaddingLength(value.first));
          break;
        case 'padding-top':
          style.padding = (style.padding ?? EdgeInsets.zero)
              .copyWith(top: Expression.expressionToPaddingLength(value.first));
          break;
        case 'padding-bottom':
          style.padding = (style.padding ?? EdgeInsets.zero)
              .copyWith(bottom: Expression.expressionToPaddingLength(value.first));
          break;
        case 'text-align':
          style.textAlign = Expression.expressionToTextAlign(value.first);
          break;
        case 'text-decoration':
          List<css.LiteralTerm?>? textDecorationList = value.whereType<css.LiteralTerm>().toList();

          /// List<css.LiteralTerm> might include other values than the ones we want for [textDecorationList], so make sure to remove those before passing it to [ExpressionMapping]
          textDecorationList.removeWhere((element) =>
              element == null ||
              (element.text != "none" &&
                  element.text != "overline" &&
                  element.text != "underline" &&
                  element.text != "line-through"));
          List<css.Expression?>? nullableList = value;
          css.Expression? textDecorationColor;
          textDecorationColor = nullableList.firstWhereOrNull(
              (element) => element is css.HexColorTerm || element is css.FunctionTerm);
          List<css.LiteralTerm?>? potentialStyles = value.whereType<css.LiteralTerm>().toList();

          /// List<css.LiteralTerm> might include other values than the ones we want for [textDecorationStyle], so make sure to remove those before passing it to [ExpressionMapping]
          potentialStyles.removeWhere((element) =>
              element == null ||
              (element.text != "solid" &&
                  element.text != "double" &&
                  element.text != "dashed" &&
                  element.text != "dotted" &&
                  element.text != "wavy"));
          css.LiteralTerm? textDecorationStyle =
              potentialStyles.isNotEmpty ? potentialStyles.last : null;
          style.textDecoration = Expression.expressionToTextDecorationLine(textDecorationList);
          if (textDecorationColor != null) {
            style.textDecorationColor =
                Expression.toColor(textDecorationColor) ?? style.textDecorationColor;
          }
          if (textDecorationStyle != null) {
            style.textDecorationStyle =
                Expression.expressionToTextDecorationStyle(textDecorationStyle);
          }
          break;
        case 'text-decoration-color':
          style.textDecorationColor = Expression.toColor(value.first) ?? style.textDecorationColor;
          break;
        case 'text-decoration-line':
          List<css.LiteralTerm?>? textDecorationList = value.whereType<css.LiteralTerm>().toList();
          style.textDecoration = Expression.expressionToTextDecorationLine(textDecorationList);
          break;
        case 'text-decoration-style':
          style.textDecorationStyle =
              Expression.expressionToTextDecorationStyle(value.first as css.LiteralTerm);
          break;
        case 'text-shadow':
          style.textShadow = Expression.expressionToTextShadow(value);
          break;
        case 'text-transform':
          final val = (value.first as css.LiteralTerm).text;
          if (val == 'uppercase') {
            style.textTransform = TextTransform.uppercase;
          } else if (val == 'lowercase') {
            style.textTransform = TextTransform.lowercase;
          } else if (val == 'capitalize') {
            style.textTransform = TextTransform.capitalize;
          } else {
            style.textTransform = TextTransform.none;
          }
          break;
        case 'width':
          style.width = Expression.expressionToWidth(value.first) ?? style.width;
          break;
      }
    }
  });
  return style;
}

CSS3? inlineCssToStyle(String? inlineStyle, OnCssParseError? errorHandler) {
  var errors = <css_parser.Message>[];
  final sheet = css_parser.parse("*{$inlineStyle}", errors: errors);
  if (errors.isEmpty) {
    final declarations = DeclarationVisitor().getDeclarations(sheet);
    return cssToStyle(declarations["*"]!);
  } else if (errorHandler != null) {
    String? newCss = errorHandler.call(inlineStyle ?? "", errors);
    if (newCss != null) {
      return inlineCssToStyle(newCss, errorHandler);
    }
  }
  return null;
}

Map<String, Map<String, List<css.Expression>>> parseExternalCss(
    String css, OnCssParseError? errorHandler) {
  var errors = <css_parser.Message>[];
  final sheet = css_parser.parse(css, errors: errors);
  if (errors.isEmpty) {
    return DeclarationVisitor().getDeclarations(sheet);
  } else if (errorHandler != null) {
    String? newCss = errorHandler.call(css, errors);
    if (newCss != null) {
      return parseExternalCss(newCss, errorHandler);
    }
  }
  return {};
}

class DeclarationVisitor extends css.Visitor {
  final Map<String, Map<String, List<css.Expression>>> _result = {};
  final Map<String, List<css.Expression>> _properties = {};
  late String _selector;
  late String _currentProperty;

  Map<String, Map<String, List<css.Expression>>> getDeclarations(css.StyleSheet sheet) {
    for (var element in sheet.topLevels) {
      if (element.span != null) {
        _selector = element.span!.text;
        element.visit(this);
        if (_result[_selector] != null) {
          _properties.forEach((key, value) {
            if (_result[_selector]![key] != null) {
              _result[_selector]![key]!.addAll(List<css.Expression>.from(value));
            } else {
              _result[_selector]![key] = List<css.Expression>.from(value);
            }
          });
        } else {
          _result[_selector] = Map<String, List<css.Expression>>.from(_properties);
        }
        _properties.clear();
      }
    }
    return _result;
  }

  @override
  void visitDeclaration(css.Declaration node) {
    _currentProperty = node.property;
    _properties[_currentProperty] = <css.Expression>[];
    node.expression!.visit(this);
  }

  @override
  void visitExpressions(css.Expressions node) {
    if (_properties[_currentProperty] != null) {
      _properties[_currentProperty]!.addAll(node.expressions);
    } else {
      _properties[_currentProperty] = node.expressions;
    }
  }
}

//Mapping functions
class Expression {
  static Border toBorder(List<css.Expression?>? borderWidths, List<css.LiteralTerm?>? borderStyles,
      List<css.Expression?>? borderColors) {
    CustomBorderSide left = CustomBorderSide();
    CustomBorderSide top = CustomBorderSide();
    CustomBorderSide right = CustomBorderSide();
    CustomBorderSide bottom = CustomBorderSide();
    if (borderWidths != null && borderWidths.isNotEmpty) {
      top.width = toBorderWidth(borderWidths.first);
      if (borderWidths.length == 4) {
        right.width = toBorderWidth(borderWidths[1]);
        bottom.width = toBorderWidth(borderWidths[2]);
        left.width = toBorderWidth(borderWidths.last);
      }
      if (borderWidths.length == 3) {
        left.width = toBorderWidth(borderWidths[1]);
        right.width = toBorderWidth(borderWidths[1]);
        bottom.width = toBorderWidth(borderWidths.last);
      }
      if (borderWidths.length == 2) {
        bottom.width = toBorderWidth(borderWidths.first);
        left.width = toBorderWidth(borderWidths.last);
        right.width = toBorderWidth(borderWidths.last);
      }
      if (borderWidths.length == 1) {
        bottom.width = toBorderWidth(borderWidths.first);
        left.width = toBorderWidth(borderWidths.first);
        right.width = toBorderWidth(borderWidths.first);
      }
    }
    if (borderStyles != null && borderStyles.isNotEmpty) {
      top.style = toBorderStyle(borderStyles.first);
      if (borderStyles.length == 4) {
        right.style = toBorderStyle(borderStyles[1]);
        bottom.style = toBorderStyle(borderStyles[2]);
        left.style = toBorderStyle(borderStyles.last);
      }
      if (borderStyles.length == 3) {
        left.style = toBorderStyle(borderStyles[1]);
        right.style = toBorderStyle(borderStyles[1]);
        bottom.style = toBorderStyle(borderStyles.last);
      }
      if (borderStyles.length == 2) {
        bottom.style = toBorderStyle(borderStyles.first);
        left.style = toBorderStyle(borderStyles.last);
        right.style = toBorderStyle(borderStyles.last);
      }
      if (borderStyles.length == 1) {
        bottom.style = toBorderStyle(borderStyles.first);
        left.style = toBorderStyle(borderStyles.first);
        right.style = toBorderStyle(borderStyles.first);
      }
    }
    if (borderColors != null && borderColors.isNotEmpty) {
      top.color = toColor(borderColors.first);
      if (borderColors.length == 4) {
        right.color = toColor(borderColors[1]);
        bottom.color = toColor(borderColors[2]);
        left.color = toColor(borderColors.last);
      }
      if (borderColors.length == 3) {
        left.color = toColor(borderColors[1]);
        right.color = toColor(borderColors[1]);
        bottom.color = toColor(borderColors.last);
      }
      if (borderColors.length == 2) {
        bottom.color = toColor(borderColors.first);
        left.color = toColor(borderColors.last);
        right.color = toColor(borderColors.last);
      }
      if (borderColors.length == 1) {
        bottom.color = toColor(borderColors.first);
        left.color = toColor(borderColors.first);
        right.color = toColor(borderColors.first);
      }
    }
    return Border(
        top: BorderSide(width: top.width, color: top.color ?? Colors.black, style: top.style),
        right:
            BorderSide(width: right.width, color: right.color ?? Colors.black, style: right.style),
        bottom: BorderSide(
            width: bottom.width, color: bottom.color ?? Colors.black, style: bottom.style),
        left: BorderSide(width: left.width, color: left.color ?? Colors.black, style: left.style));
  }

  static double toBorderWidth(css.Expression? value) {
    if (value is css.NumberTerm) {
      return double.tryParse(value.text) ?? 1.0;
    } else if (value is css.PercentageTerm) {
      return (double.tryParse(value.text) ?? 400) / 100;
    } else if (value is css.EmTerm) {
      return double.tryParse(value.text) ?? 1.0;
    } else if (value is css.RemTerm) {
      return double.tryParse(value.text) ?? 1.0;
    } else if (value is css.LengthTerm) {
      return double.tryParse(value.text.replaceAll(RegExp(r'\s+(\d+\.\d+)\s+'), '')) ?? 1.0;
    } else if (value is css.LiteralTerm) {
      switch (value.text) {
        case "thin":
          return 2.0;
        case "medium":
          return 4.0;
        case "thick":
          return 6.0;
      }
    }
    return 4.0;
  }

  static BorderStyle toBorderStyle(css.LiteralTerm? value) {
    if (value != null && value.text != "none" && value.text != "hidden") {
      return BorderStyle.solid;
    }
    return BorderStyle.none;
  }

  static Color? toColor(css.Expression? value) {
    if (value != null) {
      if (value is css.HexColorTerm) {
        return stringToColor(value.text);
      } else if (value is css.FunctionTerm) {
        if (value.text == 'rgba' || value.text == 'rgb') {
          return rgbOrRgbaToColor(value.span!.text);
        } else if (value.text == 'hsla' || value.text == 'hsl') {
          return hslToRgbToColor(value.span!.text);
        }
      } else if (value is css.LiteralTerm) {
        return namedColorToColor(value.text);
      }
    }
    return null;
  }

  static TextDirection expressionToDirection(css.Expression value) {
    if (value is css.LiteralTerm) {
      switch (value.text) {
        case "ltr":
          return TextDirection.ltr;
        case "rtl":
          return TextDirection.rtl;
      }
    }
    return TextDirection.ltr;
  }

  static Display expressionToDisplay(css.Expression value) {
    if (value is css.LiteralTerm) {
      switch (value.text) {
        case 'block':
          return Display.block;
        case 'inline-block':
          return Display.inlineBlock;
        case 'inline':
          return Display.inline;
        case 'list-item':
          return Display.listItem;
        case 'none':
          return Display.none;
      }
    }
    return Display.inline;
  }

  static List<FontFeature> expressionToFontFeatureSettings(List<css.Expression> value) {
    List<FontFeature> fontFeatures = [];
    for (int i = 0; i < value.length; i++) {
      css.Expression exp = value[i];
      if (exp is css.LiteralTerm) {
        if (exp.text != "on" && exp.text != "off" && exp.text != "1" && exp.text != "0") {
          if (i < value.length - 1) {
            css.Expression nextExp = value[i + 1];
            if (nextExp is css.LiteralTerm &&
                (nextExp.text == "on" ||
                    nextExp.text == "off" ||
                    nextExp.text == "1" ||
                    nextExp.text == "0")) {
              fontFeatures
                  .add(FontFeature(exp.text, nextExp.text == "on" || nextExp.text == "1" ? 1 : 0));
            } else {
              fontFeatures.add(FontFeature.enable(exp.text));
            }
          } else {
            fontFeatures.add(FontFeature.enable(exp.text));
          }
        }
      }
    }
    List<FontFeature> finalFontFeatures = fontFeatures.toSet().toList();
    return finalFontFeatures;
  }

  static FontSize? expressionToFontSize(css.Expression value) {
    if (value is css.NumberTerm) {
      return FontSize(double.tryParse(value.text) ?? 16, Unit.px);
    } else if (value is css.PercentageTerm) {
      return FontSize(double.tryParse(value.text) ?? 100, Unit.percent);
    } else if (value is css.EmTerm) {
      return FontSize(double.tryParse(value.text) ?? 1, Unit.em);
      // } else if (value is css.RemTerm) { TODO
      //   return FontSize.rem(double.tryParse(value.text) ?? 1, Unit.em);
    } else if (value is css.LengthTerm) {
      return FontSize(
          double.tryParse(value.text.replaceAll(RegExp(r'\s+(\d+\.\d+)\s+'), '')) ?? 16);
    } else if (value is css.LiteralTerm) {
      switch (value.text) {
        case "xx-small":
          return FontSize.xxSmall;
        case "x-small":
          return FontSize.xSmall;
        case "small":
          return FontSize.small;
        case "medium":
          return FontSize.medium;
        case "large":
          return FontSize.large;
        case "x-large":
          return FontSize.xLarge;
        case "xx-large":
          return FontSize.xxLarge;
      }
    }
    return null;
  }

  static FontStyle expressionToFontStyle(css.Expression value) {
    if (value is css.LiteralTerm) {
      switch (value.text) {
        case "italic":
        case "oblique":
          return FontStyle.italic;
      }
      return FontStyle.normal;
    }
    return FontStyle.normal;
  }

  static FontWeight expressionToFontWeight(css.Expression value) {
    if (value is css.NumberTerm) {
      switch (value.text) {
        case "100":
          return FontWeight.w100;
        case "200":
          return FontWeight.w200;
        case "300":
          return FontWeight.w300;
        case "400":
          return FontWeight.w400;
        case "500":
          return FontWeight.w500;
        case "600":
          return FontWeight.w600;
        case "700":
          return FontWeight.w700;
        case "800":
          return FontWeight.w800;
        case "900":
          return FontWeight.w900;
      }
    } else if (value is css.LiteralTerm) {
      switch (value.text) {
        case "bold":
          return FontWeight.bold;
        case "bolder":
          return FontWeight.w900;
        case "lighter":
          return FontWeight.w200;
      }
      return FontWeight.normal;
    }
    return FontWeight.normal;
  }

  static String? expressionToFontFamily(css.Expression value) {
    if (value is css.LiteralTerm) return value.text;
    return null;
  }

  static LineHeight expressionToLineHeight(css.Expression value) {
    if (value is css.NumberTerm) {
      return LineHeight.number(double.tryParse(value.text)!);
    } else if (value is css.PercentageTerm) {
      return LineHeight.percent(double.tryParse(value.text)!);
    } else if (value is css.EmTerm) {
      return LineHeight.em(double.tryParse(value.text)!);
    } else if (value is css.RemTerm) {
      return LineHeight.rem(double.tryParse(value.text)!);
    } else if (value is css.LengthTerm) {
      return LineHeight(double.tryParse(value.text.replaceAll(RegExp(r'\s+(\d+\.\d+)\s+'), '')),
          units: "length");
    }
    return LineHeight.normal;
  }

  static ListStyleImage? expressionToListStyleImage(css.UriTerm value) {
    return ListStyleImage(value.text);
  }

  static ListStyleType? expressionToListStyleType(css.LiteralTerm value) {
    return ListStyleType.fromName(value.text);
  }

  static Width? expressionToWidth(css.Expression value) {
    if ((value is css.LiteralTerm) && value.text == 'auto') {
      return Width.auto();
    } else {
      final computedValue = expressionToLengthOrPercent(value);
      return Width(computedValue.value, computedValue.unit);
    }
  }

  static Height? expressionToHeight(css.Expression value) {
    if ((value is css.LiteralTerm) && value.text == 'auto') {
      return Height.auto();
    } else {
      final computedValue = expressionToLengthOrPercent(value);
      return Height(computedValue.value, computedValue.unit);
    }
  }

  static Margin? expressionToMargin(css.Expression value) {
    if ((value is css.LiteralTerm) && value.text == 'auto') {
      return Margin.auto();
    } else {
      final computedValue = expressionToLengthOrPercent(value);
      return Margin(computedValue.value, computedValue.unit);
    }
  }

  static Margins expressionToMargins(List<css.Expression>? lengths) {
    Margin? left;
    Margin? right;
    Margin? top;
    Margin? bottom;
    if (lengths != null && lengths.isNotEmpty) {
      top = expressionToMargin(lengths.first);
      if (lengths.length == 4) {
        right = expressionToMargin(lengths[1]);
        bottom = expressionToMargin(lengths[2]);
        left = expressionToMargin(lengths.last);
      }
      if (lengths.length == 3) {
        left = expressionToMargin(lengths[1]);
        right = expressionToMargin(lengths[1]);
        bottom = expressionToMargin(lengths.last);
      }
      if (lengths.length == 2) {
        bottom = expressionToMargin(lengths.first);
        left = expressionToMargin(lengths.last);
        right = expressionToMargin(lengths.last);
      }
      if (lengths.length == 1) {
        bottom = expressionToMargin(lengths.first);
        left = expressionToMargin(lengths.first);
        right = expressionToMargin(lengths.first);
      }
    }
    return Margins(left: left, right: right, top: top, bottom: bottom);
  }

  static List<double?> expressionToPadding(List<css.Expression>? lengths) {
    double? left;
    double? right;
    double? top;
    double? bottom;
    if (lengths != null && lengths.isNotEmpty) {
      top = expressionToPaddingLength(lengths.first);
      if (lengths.length == 4) {
        right = expressionToPaddingLength(lengths[1]);
        bottom = expressionToPaddingLength(lengths[2]);
        left = expressionToPaddingLength(lengths.last);
      }
      if (lengths.length == 3) {
        left = expressionToPaddingLength(lengths[1]);
        right = expressionToPaddingLength(lengths[1]);
        bottom = expressionToPaddingLength(lengths.last);
      }
      if (lengths.length == 2) {
        bottom = expressionToPaddingLength(lengths.first);
        left = expressionToPaddingLength(lengths.last);
        right = expressionToPaddingLength(lengths.last);
      }
      if (lengths.length == 1) {
        bottom = expressionToPaddingLength(lengths.first);
        left = expressionToPaddingLength(lengths.first);
        right = expressionToPaddingLength(lengths.first);
      }
    }
    return [left, right, top, bottom];
  }

  static double? expressionToPaddingLength(css.Expression value) {
    if (value is css.NumberTerm) {
      return double.tryParse(value.text);
    } else if (value is css.EmTerm) {
      return double.tryParse(value.text);
    } else if (value is css.RemTerm) {
      return double.tryParse(value.text);
    } else if (value is css.LengthTerm) {
      return double.tryParse(value.text.replaceAll(RegExp(r'\s+(\d+\.\d+)\s+'), ''));
    }
    return null;
  }

  static LengthOrPercent expressionToLengthOrPercent(css.Expression value) {
    if (value is css.NumberTerm) {
      return LengthOrPercent(double.parse(value.text));
    } else if (value is css.EmTerm) {
      return LengthOrPercent(double.parse(value.text), Unit.em);
      // } else if (value is css.RemTerm) {
      //   return LengthOrPercent(double.parse(value.text), Unit.rem);
      // TODO there are several other available terms processed by the CSS parser
    } else if (value is css.LengthTerm) {
      double number = double.parse(value.text.replaceAll(RegExp(r'\s+(\d+\.\d+)\s+'), ''));
      Unit unit = _unitMap(value.unit);
      return LengthOrPercent(number, unit);
    }

    //Ignore unparsable input
    return LengthOrPercent(0);
  }

  static Unit _unitMap(int cssParserUnitToken) {
    switch (cssParserUnitToken) {
      default:
        return Unit.px;
    }
  }

  static TextAlign expressionToTextAlign(css.Expression value) {
    if (value is css.LiteralTerm) {
      switch (value.text) {
        case "center":
          return TextAlign.center;
        case "left":
          return TextAlign.left;
        case "right":
          return TextAlign.right;
        case "justify":
          return TextAlign.justify;
        case "end":
          return TextAlign.end;
        case "start":
          return TextAlign.start;
      }
    }
    return TextAlign.start;
  }

  static TextDecoration expressionToTextDecorationLine(List<css.LiteralTerm?> value) {
    List<TextDecoration> decorationList = [];
    for (css.LiteralTerm? term in value) {
      if (term != null) {
        switch (term.text) {
          case "overline":
            decorationList.add(TextDecoration.overline);
            break;
          case "underline":
            decorationList.add(TextDecoration.underline);
            break;
          case "line-through":
            decorationList.add(TextDecoration.lineThrough);
            break;
          default:
            decorationList.add(TextDecoration.none);
            break;
        }
      }
    }
    if (decorationList.contains(TextDecoration.none)) {
      decorationList = [TextDecoration.none];
    }
    return TextDecoration.combine(decorationList);
  }

  static TextDecorationStyle expressionToTextDecorationStyle(css.LiteralTerm value) {
    switch (value.text) {
      case "wavy":
        return TextDecorationStyle.wavy;
      case "dotted":
        return TextDecorationStyle.dotted;
      case "dashed":
        return TextDecorationStyle.dashed;
      case "double":
        return TextDecorationStyle.double;
      default:
        return TextDecorationStyle.solid;
    }
  }

  static List<Shadow> expressionToTextShadow(List<css.Expression> value) {
    List<Shadow> shadow = [];
    List<int> indices = [];
    List<List<css.Expression>> valueList = [];
    for (css.Expression e in value) {
      if (e is css.OperatorComma) {
        indices.add(value.indexOf(e));
      }
    }
    indices.add(value.length);
    int previousIndex = 0;
    for (int i in indices) {
      valueList.add(value.sublist(previousIndex, i));
      previousIndex = i + 1;
    }
    for (List<css.Expression> list in valueList) {
      css.Expression? offsetX;
      css.Expression? offsetY;
      css.Expression? blurRadius;
      css.Expression? color;
      int expressionIndex = 0;
      for (var element in list) {
        if (element is css.HexColorTerm || element is css.FunctionTerm) {
          color = element;
        } else if (expressionIndex == 0) {
          offsetX = element;
          expressionIndex++;
        } else if (expressionIndex++ == 1) {
          offsetY = element;
          expressionIndex++;
        } else {
          blurRadius = element;
        }
      }
      RegExp nonNumberRegex = RegExp(r'\s+(\d+\.\d+)\s+');
      if (offsetX is css.LiteralTerm && offsetY is css.LiteralTerm) {
        if (color != null && Expression.toColor(color) != null) {
          shadow.add(Shadow(
            color: toColor(color)!,
            offset: Offset(double.tryParse((offsetX).text.replaceAll(nonNumberRegex, ''))!,
                double.tryParse((offsetY).text.replaceAll(nonNumberRegex, ''))!),
            blurRadius: (blurRadius is css.LiteralTerm)
                ? double.tryParse((blurRadius).text.replaceAll(nonNumberRegex, ''))!
                : 0.0,
          ));
        } else {
          shadow.add(Shadow(
            offset: Offset(double.tryParse((offsetX).text.replaceAll(nonNumberRegex, ''))!,
                double.tryParse((offsetY).text.replaceAll(nonNumberRegex, ''))!),
            blurRadius: (blurRadius is css.LiteralTerm)
                ? double.tryParse((blurRadius).text.replaceAll(nonNumberRegex, ''))!
                : 0.0,
          ));
        }
      }
    }
    List<Shadow> finalShadows = shadow.toSet().toList();
    return finalShadows;
  }

  static Color stringToColor(String rawText) {
    var text = rawText.replaceFirst('#', '');
    if (text.length == 3) {
      text = text.replaceAllMapped(RegExp(r"[a-f]|\d", caseSensitive: false),
          (match) => '${match.group(0)}${match.group(0)}');
    }
    if (text.length > 6) {
      text = "0x$text";
    } else {
      text = "0xFF$text";
    }
    return Color(int.parse(text));
  }

  static Color? rgbOrRgbaToColor(String text) {
    final rgbaText = text.replaceAll(')', '').replaceAll(' ', '');
    try {
      final rgbaValues = rgbaText.split(',').map((value) => double.parse(value)).toList();
      if (rgbaValues.length == 4) {
        return Color.fromRGBO(
          rgbaValues[0].toInt(),
          rgbaValues[1].toInt(),
          rgbaValues[2].toInt(),
          rgbaValues[3],
        );
      } else if (rgbaValues.length == 3) {
        return Color.fromRGBO(
          rgbaValues[0].toInt(),
          rgbaValues[1].toInt(),
          rgbaValues[2].toInt(),
          1.0,
        );
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  static Color hslToRgbToColor(String text) {
    final hslText = text.replaceAll(')', '').replaceAll(' ', '');
    final hslValues = hslText.split(',').toList();
    List<double?> parsedHsl = [];
    for (var element in hslValues) {
      if (element.contains("%") && double.tryParse(element.replaceAll("%", "")) != null) {
        parsedHsl.add(double.tryParse(element.replaceAll("%", ""))! * 0.01);
      } else {
        if (element != hslValues.first &&
            (double.tryParse(element) == null || double.tryParse(element)! > 1)) {
          parsedHsl.add(null);
        } else {
          parsedHsl.add(double.tryParse(element));
        }
      }
    }
    if (parsedHsl.length == 4 && !parsedHsl.contains(null)) {
      return HSLColor.fromAHSL(parsedHsl.last!, parsedHsl.first!, parsedHsl[1]!, parsedHsl[2]!)
          .toColor();
    } else if (parsedHsl.length == 3 && !parsedHsl.contains(null)) {
      return HSLColor.fromAHSL(1.0, parsedHsl.first!, parsedHsl[1]!, parsedHsl.last!).toColor();
    } else {
      return Colors.black;
    }
  }

  static Color? namedColorToColor(String text) {
    String namedColor = namedColors.keys
        .firstWhere((element) => element.toLowerCase() == text.toLowerCase(), orElse: () => "");
    if (namedColor != "") {
      return stringToColor(namedColors[namedColor]!);
    } else {
      return null;
    }
  }
}
