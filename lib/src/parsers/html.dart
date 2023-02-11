import 'dart:collection';
import 'dart:math';

import 'package:csslib/parser.dart' as css_parser;
import 'package:csslib/visitor.dart' as css;
import 'package:flutter/material.dart';
import 'package:html/dom.dart' as dom;
import 'package:html/parser.dart' as html_parser;
import 'package:list_counter/list_counter.dart';
import 'package:qp_xt/qp_xt.dart';

import '../core/html5.dart';
import '../tags/html_tags.dart';
import '../tags/utils.dart';
import 'css.dart';
import 'custom.dart';

class HtmlParser extends StatelessWidget {
  final dom.Element htmlData;
  final OnTap? onLinkTap;
  final OnTap? onAnchorTap;
  final OnTap? onImageTap;
  final OnCssParseError? onCssParseError;
  final ImageErrorListener? onImageError;
  final bool shrinkWrap;
  final bool selectable;

  final Map<String, CSS3> style;
  final Map<CustomRenderMatcher, CustomRender> customRenders;
  final List<String> tagsList;
  final OnTap? internalOnAnchorTap;
  final HTML5? root;
  final TextSelectionControls? selectionControls;
  final ScrollPhysics? scrollPhysics;

  final Map<String, Size> cachedImageSizes = {};

  HtmlParser({
    required super.key,
    required this.htmlData,
    required this.onLinkTap,
    required this.onAnchorTap,
    required this.onImageTap,
    required this.onCssParseError,
    required this.onImageError,
    required this.shrinkWrap,
    required this.selectable,
    required this.style,
    required this.customRenders,
    required this.tagsList,
    this.root,
    this.selectionControls,
    this.scrollPhysics,
  }) : internalOnAnchorTap = onAnchorTap ??
            (key != null
                ? _handleAnchorTap(
                    key,
                    onLinkTap,
                  )
                : onLinkTap);

  /// As the widget [build]s, the HTML data is processed into
  /// a tree of [StyledElement]s,  which are then parsed into
  /// an [InlineSpan] tree that is then rendered to the screen
  /// by Flutter
  @override
  Widget build(BuildContext context) {
    // Lexing Step
    StyledElement lexedTree = lexDomTree(
      htmlData,
      customRenders.keys.toList(),
      tagsList,
      context,
      this,
    );

    // Styling Step
    StyledElement styledTree = styleTree(
      lexedTree,
      htmlData,
      style,
      onCssParseError,
    );

    // Processing Step
    StyledElement processedTree = processTree(
      styledTree,
      MediaQuery.of(context).devicePixelRatio,
    );

    // Parsing Step
    InlineSpan parsedTree = parseTree(
      RenderContext(
        buildContext: context,
        parser: this,
        tree: processedTree,
        style: processedTree.style,
      ),
      processedTree,
    );

    return CssBoxWidget.withInlineSpanChildren(
      style: processedTree.style,
      children: [parsedTree],
      selectable: selectable,
      scrollPhysics: scrollPhysics,
      selectionControls: selectionControls,
      shrinkWrap: shrinkWrap,
    );
  }

  /// [parseHTML] converts a string of HTML to a DOM element
  /// using the dart `html` library.
  static dom.Element parseHTML(String data) {
    return html_parser.parse(data).documentElement!;
  }

  /// [parseCss] converts a string of CSS to a CSS stylesheet
  /// using the dart `csslib` library.
  static css.StyleSheet parseCss(String data) {
    return css_parser.parse(data);
  }

  /// [lexDomTree] converts a DOM document to a simplified
  /// tree of [StyledElement]s.
  static StyledElement lexDomTree(
    dom.Element html,
    List<CustomRenderMatcher> customRenderMatchers,
    List<String> tagsList,
    BuildContext context,
    HtmlParser parser,
  ) {
    StyledElement tree = StyledElement(
      name: "[Tree Root]",
      children: <StyledElement>[],
      node: html,
      style: CSS3.fromTextStyle(Theme.of(context).textTheme.bodyMedium!),
    );

    for (var node in html.nodes) {
      tree.children.add(_recursiveLexer(
        node,
        customRenderMatchers,
        tagsList,
        context,
        parser,
      ));
    }

    return tree;
  }

  /// [_recursiveLexer] is the recursive worker function
  /// for [lexDomTree].
  ///
  /// It runs the parse functions of every type of element
  /// and returns a [StyledElement] tree representing the
  /// element.
  static StyledElement _recursiveLexer(
    dom.Node node,
    List<CustomRenderMatcher> customRenderMatchers,
    List<String> tagsList,
    BuildContext context,
    HtmlParser parser,
  ) {
    List<StyledElement> children = <StyledElement>[];
    for (var childNode in node.nodes) {
      children.add(_recursiveLexer(
        childNode,
        customRenderMatchers,
        tagsList,
        context,
        parser,
      ));
    }
    if (node is dom.Element) {
      if (!tagsList.contains(node.localName)) {
        return EmptyContentElement();
      }
      if (HtmlElements.styledElements.contains(node.localName)) {
        return parseStyledElement(node, children);
      } else if (HtmlElements.interactableElements.contains(node.localName)) {
        return parseReactElement(node, children);
      } else if (HtmlElements.replacedElements.contains(node.localName)) {
        return parseReplacedElement(node, children);
      } else if (HtmlElements.layoutElements.contains(node.localName)) {
        return parseLayoutElement(node, children);
      } else if (HtmlElements.tableCellElements.contains(node.localName)) {
        return parseTableCellElement(node, children);
      } else if (HtmlElements.tableDefinitionElements.contains(node.localName)) {
        return parseTableDefinitionElement(node, children);
      } else {
        final StyledElement tree = parseStyledElement(node, children);
        for (final entry in customRenderMatchers) {
          if (entry.call(
            RenderContext(
              buildContext: context,
              parser: parser,
              tree: tree,
              style: CSS3.fromTextStyle(Theme.of(context).textTheme.bodyMedium!),
            ),
          )) {
            return tree;
          }
        }
        return EmptyContentElement();
      }
    } else if (node is dom.Text) {
      return TextContentElement(
        text: node.text,
        style: CSS3(),
        element: node.parent,
        node: node,
      );
    } else {
      return EmptyContentElement();
    }
  }

  static Map<String, Map<String, List<css.Expression>>> _getExternalCssDeclarations(
    List<dom.Element> styles,
    OnCssParseError? errorHandler,
  ) {
    String fullCss = "";
    for (final e in styles) {
      fullCss = fullCss + e.innerHtml;
    }
    if (fullCss.isNotEmpty) {
      final declarations = parseExternalCss(fullCss, errorHandler);
      return declarations;
    } else {
      return {};
    }
  }

  static StyledElement _applyExternalCss(
    Map<String, Map<String, List<css.Expression>>> declarations,
    StyledElement tree,
  ) {
    declarations.forEach((key, style) {
      try {
        if (tree.matchesSelector(key)) {
          tree.style = tree.style.merge(cssToStyle(style));
        }
      } catch (_) {}
    });

    for (var element in tree.children) {
      _applyExternalCss(declarations, element);
    }

    return tree;
  }

  static StyledElement _applyInlineStyles(
    StyledElement tree,
    OnCssParseError? errorHandler,
  ) {
    if (tree.attributes.containsKey("style")) {
      final newStyle = inlineCssToStyle(
        tree.attributes['style'],
        errorHandler,
      );
      if (newStyle != null) {
        tree.style = tree.style.merge(newStyle);
      }
    }

    for (var element in tree.children) {
      _applyInlineStyles(element, errorHandler);
    }
    return tree;
  }

  /// [applyCustomStyles] applies the [CSS3] objects
  /// passed into the [HTML5] widget onto the [StyledElement]
  /// tree, no cascading of styles is done at this point.
  static StyledElement _applyCustomStyles(
    Map<String, CSS3> style,
    StyledElement tree,
  ) {
    style.forEach((key, style) {
      try {
        if (tree.matchesSelector(key)) {
          tree.style = tree.style.merge(style);
        }
      } catch (_) {}
    });
    for (var element in tree.children) {
      _applyCustomStyles(style, element);
    }

    return tree;
  }

  /// [_cascadeStyles] cascades all of the inherited styles
  /// down the tree, applying them to each child that doesn't
  /// specify a different style.
  static StyledElement _cascadeStyles(
    Map<String, CSS3> style,
    StyledElement tree,
  ) {
    for (var child in tree.children) {
      child.style = tree.style.copyOnlyInherited(child.style);
      _cascadeStyles(style, child);
    }

    return tree;
  }

  /// [styleTree] takes the lexed [StyleElement] tree
  /// and applies external, inline, and custom CSS/Flutter
  /// styles, and then cascades the styles down the tree.
  static StyledElement styleTree(
    StyledElement tree,
    dom.Element htmlData,
    Map<String, CSS3> style,
    OnCssParseError? onCssParseError,
  ) {
    final declarations = _getExternalCssDeclarations(
      htmlData.getElementsByTagName("style"),
      onCssParseError,
    );

    StyledElement? externalCssStyledTree;
    if (declarations.isNotEmpty) {
      externalCssStyledTree = _applyExternalCss(declarations, tree);
    }
    tree = _applyInlineStyles(externalCssStyledTree ?? tree, onCssParseError);
    tree = _applyCustomStyles(style, tree);
    tree = _cascadeStyles(style, tree);
    return tree;
  }

  /// [processTree] optimizes the [StyledElement] tree
  /// so all [BlockElement]s are on the first level,
  /// redundant levels are collapsed, empty elements
  /// are removed, and specialty elements are processed.
  static StyledElement processTree(
    StyledElement tree,
    double devicePixelRatio,
  ) {
    //...
    tree = _processInternalWhitespace(tree);
    tree = _processInlineWhitespace(tree);
    tree = _removeEmptyElements(tree);
    tree = _calculateRelativeValues(tree, devicePixelRatio);
    tree = _preprocessListMarkers(tree);
    tree = _processCounters(tree);
    tree = _processListMarkers(tree);
    tree = _processBeforeAndAfter(tree);
    tree = _collapseMargins(tree);
    return tree;
  }

  /// [parseTree] converts a tree of [StyledElement]s
  /// to an [InlineSpan] tree. [parseTree] is responsible
  /// for handling the [customRenders] parameter and
  /// deciding what different `Style.display` options
  /// look like as Widgets.
  InlineSpan parseTree(RenderContext context, StyledElement tree) {
    //...
    RenderContext newContext = RenderContext(
      buildContext: context.buildContext,
      parser: this,
      tree: tree,
      style: context.style.copyOnlyInherited(tree.style),
      key: AnchorKey.of(key, tree),
    );

    for (final entry in customRenders.keys) {
      if (entry.call(newContext)) {
        buildChildren() => tree.children.map((tree) => parseTree(newContext, tree)).toList();
        if (newContext.parser.selectable && customRenders[entry] is SelectableCustomRender) {
          selectableBuildChildren() =>
              tree.children.map((tree) => parseTree(newContext, tree) as TextSpan).toList();
          return (customRenders[entry] as SelectableCustomRender)
              .textSpan
              .call(newContext, selectableBuildChildren);
        }
        if (newContext.parser.selectable) {
          return customRenders[entry]!.inlineSpan!.call(newContext, buildChildren) as TextSpan;
        }
        if (customRenders[entry]?.inlineSpan != null) {
          return customRenders[entry]!.inlineSpan!.call(newContext, buildChildren);
        }
        return WidgetSpan(
          child: CssBoxWidget(
            style: tree.style,
            shrinkWrap: newContext.parser.shrinkWrap,
            childIsReplaced: true,
            child: customRenders[entry]!.widget!.call(newContext, buildChildren),
          ),
        );
      }
    }
    return const WidgetSpan(child: SizedBox(height: 0, width: 0));
  }

  static OnTap _handleAnchorTap(Key key, OnTap? onLinkTap) {
    //...
    return (url, context, attributes, element) {
      if (url?.startsWith("#") == true) {
        final anchorContext = AnchorKey.forId(
          key,
          url!.substring(1),
        )?.currentContext;
        if (anchorContext != null) {
          Scrollable.ensureVisible(anchorContext);
        }
        return;
      }
      onLinkTap?.call(
        url,
        context,
        attributes,
        element,
      );
    };
  }

  /// [processWhitespace] removes unnecessary whitespace
  /// from the StyledElement tree. The criteria for
  /// determining which whitespace is replaceable is outlined
  /// at https://www.w3.org/TR/css-text-3/ and summarized.
  static StyledElement _processInternalWhitespace(StyledElement tree) {
    if ((tree.style.whiteSpace ?? WhiteSpace.normal) == WhiteSpace.pre) {
      // Preserve this whitespace
    } else if (tree is TextContentElement) {
      tree.text = _removeUnnecessaryWhitespace(tree.text!);
    } else {
      tree.children.forEach(_processInternalWhitespace);
    }
    return tree;
  }

  /// [_processInlineWhitespace] is responsible for removing
  /// redundant whitespace between and among inline elements.
  /// It does so by creating a boolean [Context] and passing
  /// it to the [_processInlineWhitespaceRecursive] function.
  static StyledElement _processInlineWhitespace(StyledElement tree) {
    tree = _processInlineWhitespaceRecursive(tree, Context(false));
    return tree;
  }

  /// [_processInlineWhitespaceRecursive] analyzes the
  /// whitespace between and among different inline elements,
  /// and replaces any instance of two or more spaces with a
  /// single space, according to the w3's HTML whitespace
  /// processing specification linked to above.
  static StyledElement _processInlineWhitespaceRecursive(
    StyledElement tree,
    Context<bool> keepLeadingSpace,
  ) {
    if (tree is TextContentElement) {
      /// initialize indices to negative numbers to make
      /// conditionals a little easier
      int textIndex = -1;
      int elementIndex = -1;

      /// initialize parent after to a whitespace to account
      /// for elements that are the last child in the list of
      /// elements
      String parentAfterText = " ";

      /// find the index of the text in the current tree
      if ((tree.element?.nodes.length ?? 0) >= 1) {
        textIndex = tree.element?.nodes.indexWhere((element) => element == tree.node) ?? -1;
      }

      /// get the parent nodes
      dom.NodeList? parentNodes = tree.element?.parent?.nodes;

      /// find the index of the tree itself in the parent
      /// nodes
      if ((parentNodes?.length ?? 0) >= 1) {
        elementIndex = parentNodes?.indexWhere((element) => element == tree.element) ?? -1;
      }

      /// if the tree is any node except the last node in
      /// the node list and the next node in the node list
      /// is a text node, then get its text. Otherwise the
      /// next node will be a [dom.Element], so keep unwrapping
      /// that until we get the underlying text node, and
      /// finally get its text.
      if (elementIndex < (parentNodes?.length ?? 1) - 1 &&
          parentNodes?[elementIndex + 1] is dom.Text) {
        parentAfterText = parentNodes?[elementIndex + 1].text ?? " ";
      } else if (elementIndex < (parentNodes?.length ?? 1) - 1) {
        var parentAfter = parentNodes?[elementIndex + 1];
        while (parentAfter is dom.Element) {
          if (parentAfter.nodes.isNotEmpty) {
            parentAfter = parentAfter.nodes.first;
          } else {
            break;
          }
        }
        parentAfterText = parentAfter?.text ?? " ";
      }

      /// If the text is the first element in the current tree
      /// node list, it starts with a whitespace, it isn't a
      /// line break, either the whitespace is unnecessary or
      /// it is a block element, and either it is first element
      /// in the parent node list or the previous element in
      /// the parent node list ends with a whitespace, delete
      /// it.
      ///
      /// We should also delete the whitespace at any point in
      /// the node list if the previous element is a <br>
      /// because that tag makes the element act like a block
      /// element.
      if (textIndex < 1 &&
          tree.text!.startsWith(' ') &&
          tree.element?.localName != "br" &&
          (!keepLeadingSpace.data || tree.style.display == Display.block) &&
          (elementIndex < 1 ||
              (elementIndex >= 1 &&
                  parentNodes?[elementIndex - 1] is dom.Text &&
                  parentNodes![elementIndex - 1].text!.endsWith(" ")))) {
        tree.text = tree.text!.replaceFirst(' ', '');
      } else if (textIndex >= 1 &&
          tree.text!.startsWith(' ') &&
          tree.element?.nodes[textIndex - 1] is dom.Element &&
          (tree.element?.nodes[textIndex - 1] as dom.Element).localName == "br") {
        tree.text = tree.text!.replaceFirst(' ', '');
      }

      /// If the text is the last element in the current tree
      /// node list, it isn't a line break, and the next text
      /// node starts with a whitespace, update the [Context]
      /// to signify to that next text node whether it should
      /// keep its whitespace. This is based on whether the
      /// current text ends with a whitespace.
      if (textIndex == (tree.element?.nodes.length ?? 1) - 1 &&
          tree.element?.localName != "br" &&
          parentAfterText.startsWith(' ')) {
        keepLeadingSpace.data = !tree.text!.endsWith(' ');
      }
    }

    for (var element in tree.children) {
      //...
      _processInlineWhitespaceRecursive(element, keepLeadingSpace);
    }

    return tree;
  }

  /// [removeUnnecessaryWhitespace] removes "unnecessary" white
  /// space from the given String.
  ///
  /// The steps for removing this whitespace are as follows:
  /// - Remove any whitespace immediately preceding or following
  ///   a newline.
  /// - Replace all newlines with a space
  /// - Replace all tabs with a space
  /// - Replace any instances of two or more spaces with a
  /// single space.
  static String _removeUnnecessaryWhitespace(String text) {
    return text
        .replaceAll(RegExp("\\ *(?=\n)"), "\n")
        .replaceAll(RegExp("(?:\n)\\ *"), "\n")
        .replaceAll("\n", " ")
        .replaceAll("\t", " ")
        .replaceAll(RegExp(" {2,}"), " ");
  }

  /// [preprocessListMarkers] adds marker pseudo elements to the
  /// front of all list items.
  static StyledElement _preprocessListMarkers(StyledElement tree) {
    //...
    tree.style.listStylePosition ??= ListStylePosition.outside;

    if (tree.style.display == Display.listItem) {
      //...
      tree.style.marker ??= Marker(
        content: Content.normal,
        style: tree.style,
      );

      tree.style.marker!.style = tree.style.copyOnlyInherited(
        tree.style.marker!.style ?? CSS3(),
      );

      tree.style.counterIncrement ??= {};
      if (!tree.style.counterIncrement!.containsKey('list-item')) {
        tree.style.counterIncrement!['list-item'] = 1;
      }
    }

    // Add the counters to ol and ul types.
    if (tree.name == 'ol' || tree.name == 'ul') {
      tree.style.counterReset ??= {};
      if (!tree.style.counterReset!.containsKey('list-item')) {
        tree.style.counterReset!['list-item'] = 0;
      }
    }

    for (var child in tree.children) {
      _preprocessListMarkers(child);
    }

    return tree;
  }

  /// [_processListCounters] adds the appropriate counter values
  /// to each StyledElement on the tree.
  static StyledElement _processCounters(
    StyledElement tree, [
    ListQueue<Counter>? counters,
  ]) {
    // Add the counters for the current scope.
    tree.counters.addAll(counters?.deepCopy() ?? []);

    // Create any new counters
    if (tree.style.counterReset != null) {
      tree.style.counterReset!.forEach((counterName, initialValue) {
        tree.counters.add(Counter(counterName, initialValue ?? 0));
      });
    }

    // Increment any counters that are to be incremented
    if (tree.style.counterIncrement != null) {
      tree.style.counterIncrement!.forEach((counterName, increment) {
        tree.counters
            .lastWhereOrNull<Counter>(
              (counter) => counter.name == counterName,
            )
            ?.increment(increment ?? 1);

        final check = !tree.style.counterReset!.containsKey(counterName);
        if (tree.style.counterReset == null || check) {
          counters
              ?.lastWhereOrNull<Counter>(
                (counter) => counter.name == counterName,
              )
              ?.increment(increment ?? 1);
        }
      });
    }

    for (var element in tree.children) {
      _processCounters(element, tree.counters);
    }

    return tree;
  }

  static StyledElement _processListMarkers(StyledElement tree) {
    if (tree.style.display == Display.listItem) {
      final listStyleType = tree.style.listStyleType ?? //
          ListStyleType.decimal;
      final counterStyle = CounterStyleRegistry.lookup(
        listStyleType.counterStyle,
      );
      String counterContent;
      if (tree.style.marker?.content.isNormal ?? true) {
        counterContent = counterStyle.generateMarkerContent(
          tree.counters.lastOrNull?.value ?? 0,
        );
      } else if (!(tree.style.marker?.content.display ?? true)) {
        counterContent = '';
      } else {
        counterContent = tree.style.marker?.content.replacementContent ??
            counterStyle.generateMarkerContent(
              tree.counters.lastOrNull?.value ?? 0,
            );
      }
      tree.style.marker = Marker(
        content: Content(counterContent),
        style: tree.style.marker?.style,
      );
    }

    for (var child in tree.children) {
      _processListMarkers(child);
    }

    return tree;
  }

  /// [_processBeforeAndAfter] adds text content to the
  /// beginning and end of the list of the trees children
  /// according to the `before` and `after` Style properties.
  static StyledElement _processBeforeAndAfter(StyledElement tree) {
    if (tree.style.before != null) {
      tree.children.insert(
        0,
        TextContentElement(
          text: tree.style.before,
          style: tree.style.copyWith(beforeAfterNull: true, display: Display.inline),
        ),
      );
    }
    if (tree.style.after != null) {
      tree.children.add(TextContentElement(
        text: tree.style.after,
        style: tree.style.copyWith(beforeAfterNull: true, display: Display.inline),
      ));
    }

    tree.children.forEach(_processBeforeAndAfter);

    return tree;
  }

  /// [collapseMargins] follows the specifications at
  /// https://www.w3.org/TR/CSS22/box.html#collapsing-margins
  /// for collapsing margins of block-level boxes. This
  /// prevents the doubling of margins between boxes, and
  /// makes for a more correct rendering of the html content.
  ///
  /// Paraphrased from the CSS specification:
  /// Margins are collapsed if both belong to vertically -
  /// adjacent box edges, i.e form one of the following
  /// pairs:
  /// - Top margin of a box and top margin of its first in-
  ///   flow child
  /// - Bottom margin of a box and top margin of its next
  ///   in-flow following sibling
  /// - Bottom margin of a last in-flow child and bottom
  ///   margin of its parent (if the parent's height is not
  ///   explicit)
  /// - Top and Bottom margins of a box with a height of
  ///   zero or no in-flow children.
  static StyledElement _collapseMargins(StyledElement tree) {
    //...
    if (tree.children.isEmpty) {
      if (tree.style.height?.value == 0 && tree.style.height?.unit != Unit.auto) {
        tree.style.margin = tree.style.margin?.collapse() ?? Margins.zero;
      }
      return tree;
    }

    tree.children.forEach(_collapseMargins);
    if (tree.name == '[Tree Root]' || tree.name == 'html') {
      return tree;
    }

    if ((tree.style.padding?.top ?? 0) == 0) {
      final parentTop = tree.style.margin?.top?.value ?? 0;
      final fct = tree.children.first.style.margin?.top?.value ?? 0;
      final newOuterMarginTop = max(parentTop, fct);

      if (tree.style.margin == null) {
        tree.style.margin = Margins.only(top: newOuterMarginTop);
      } else {
        tree.style.margin = tree.style.margin!.copyWithEdge(
          top: newOuterMarginTop,
        );
      }

      if (tree.children.first.style.margin == null) {
        tree.children.first.style.margin = Margins.zero;
      } else {
        tree.children.first.style.margin = tree.children.first.style.margin! //
            .copyWithEdge(top: 0);
      }
    }

    if ((tree.style.padding?.bottom ?? 0) == 0) {
      final parentBottom = tree.style.margin?.bottom?.value ?? 0;
      final lcb = tree.children.last.style.margin?.bottom?.value ?? 0;
      final newOuterMarginBottom = max(parentBottom, lcb);

      // Set the parent's margin
      if (tree.style.margin == null) {
        tree.style.margin = Margins.only(bottom: newOuterMarginBottom);
      } else {
        tree.style.margin = tree.style.margin!.copyWithEdge(
          bottom: newOuterMarginBottom,
        );
      }

      // And remove the child's margin
      if (tree.children.last.style.margin == null) {
        tree.children.last.style.margin = Margins.zero;
      } else {
        tree.children.last.style.margin = tree.children.last.style.margin! //
            .copyWithEdge(bottom: 0);
      }
    }

    // Handle case (2) from above.
    if (tree.children.length > 1) {
      for (int i = 1; i < tree.children.length; i++) {
        final psb = tree.children[i - 1].style.margin?.bottom?.value ?? 0;
        final thisTop = tree.children[i].style.margin?.top?.value ?? 0;
        final newInternalMargin = max(psb, thisTop);

        if (tree.children[i - 1].style.margin == null) {
          tree.children[i - 1].style.margin = Margins.only(bottom: newInternalMargin);
        } else {
          tree.children[i - 1].style.margin = tree.children[i - 1].style.margin! //
              .copyWithEdge(bottom: newInternalMargin);
        }

        if (tree.children[i].style.margin == null) {
          tree.children[i].style.margin = Margins.only(top: newInternalMargin);
        } else {
          tree.children[i].style.margin = tree.children[i].style.margin! //
              .copyWithEdge(top: newInternalMargin);
        }
      }
    }

    return tree;
  }

  /// [removeEmptyElements] recursively removes empty elements.
  ///
  /// An empty element is any [EmptyContentElement], any empty
  /// [TextContentElement], or any block-level [TextContentElement]
  /// that contains only whitespace and doesn't follow a block
  /// element or a line break.
  static StyledElement _removeEmptyElements(StyledElement tree) {
    //...
    List<StyledElement> toRemove = <StyledElement>[];
    bool lastChildBlock = true;
    tree.children.forEachIndexed((index, child) {
      if (child is EmptyContentElement || child is EmptyLayoutElement) {
        toRemove.add(child);
      } else if (child is TextContentElement &&
          ((tree.name == "body" &&
                  (index == 0 ||
                      index + 1 == tree.children.length ||
                      tree.children[index - 1].style.display == Display.block ||
                      tree.children[index + 1].style.display == Display.block)) ||
              tree.name == "ul") &&
          child.text!.replaceAll(' ', '').isEmpty) {
        toRemove.add(child);
      } else if (child is TextContentElement &&
          child.text!.isEmpty &&
          child.style.whiteSpace != WhiteSpace.pre) {
        toRemove.add(child);
      } else if (child is TextContentElement &&
          child.style.whiteSpace != WhiteSpace.pre &&
          tree.style.display == Display.block &&
          child.text!.isEmpty &&
          lastChildBlock) {
        toRemove.add(child);
      } else if (child.style.display == Display.none) {
        toRemove.add(child);
      } else {
        _removeEmptyElements(child);
      }

      lastChildBlock = (child.style.display == Display.block ||
          child.style.display == Display.listItem ||
          (child is TextContentElement && child.text == '\n'));
    });
    tree.children.removeWhere((element) => toRemove.contains(element));

    return tree;
  }

  /// [_calculateRelativeValues] converts rem values to px
  /// sizes and then applies relative calculations
  static StyledElement _calculateRelativeValues(
    StyledElement tree,
    double devicePixelRatio,
  ) {
    double remSize = (tree.style.fontSize?.value ?? FontSize.medium.value);
    if (tree.style.fontSize?.unit == Unit.rem) {
      tree.style.fontSize = FontSize(FontSize.medium.value * remSize);
    }

    _applyRelativeValuesRecursive(tree, remSize, devicePixelRatio);
    tree.style.setRelativeValues(remSize, remSize / devicePixelRatio);

    return tree;
  }

  /// This is the recursive worker function for
  /// [_calculateRelativeValues]
  static void _applyRelativeValuesRecursive(
    StyledElement tree,
    double remFontSize,
    double devicePixelRatio,
  ) {
    //...
    assert(tree.style.fontSize != null);
    final parentFontSize = tree.style.fontSize!.value;
    for (var child in tree.children) {
      if (child.style.fontSize == null) {
        child.style.fontSize = FontSize(parentFontSize);
      } else {
        switch (child.style.fontSize!.unit) {
          case Unit.em:
            child.style.fontSize = FontSize(
              parentFontSize * child.style.fontSize!.value,
            );
            break;
          case Unit.percent:
            child.style.fontSize = FontSize(
              parentFontSize * (child.style.fontSize!.value / 100.0),
            );
            break;
          case Unit.rem:
            child.style.fontSize = FontSize(
              remFontSize * child.style.fontSize!.value,
            );
            break;
          case Unit.px:
          case Unit.auto:
            //Ignore
            break;
        }
      }
      final emSize = child.style.fontSize!.value / devicePixelRatio;
      tree.style.setRelativeValues(remFontSize, emSize);
      _applyRelativeValuesRecursive(child, remFontSize, devicePixelRatio);
    }
  }
}

/// The [RenderContext] is available when parsing the tree.
/// It contains information about the [BuildContext] of the
/// `Html` widget, contains the configuration available in
/// the [HtmlParser], and contains information about the [CSS3]
/// of the current tree root.
class RenderContext {
  final BuildContext buildContext;
  final HtmlParser parser;
  final StyledElement tree;
  final CSS3 style;
  final AnchorKey? key;

  RenderContext({
    required this.buildContext,
    required this.parser,
    required this.tree,
    required this.style,
    this.key,
  });
}

extension IterateLetters on String {
  String nextLetter() {
    String s = toLowerCase();
    if (s == "z") {
      return String.fromCharCode(s.codeUnitAt(0) - 25) +
          String.fromCharCode(s.codeUnitAt(0) - 25); // AA or aa
    } else {
      var lastChar = s.substring(s.length - 1);
      var sub = s.substring(0, s.length - 1);
      if (lastChar == "z") {
        return '${sub.nextLetter()}a';
      } else {
        return sub + String.fromCharCode(lastChar.codeUnitAt(0) + 1);
      }
    }
  }
}

typedef OnTap = void Function(
  String? url,
  RenderContext context,
  Map<String, String> attributes,
  dom.Element? element,
);

typedef OnCssParseError = String? Function(
  String css,
  List<css_parser.Message> errors,
);
