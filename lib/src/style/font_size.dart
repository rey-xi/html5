import 'length.dart';

class FontSize extends LengthOrPercent {
  //...Fields
  static final xxSmall = FontSize(7.875);
  static final xSmall = FontSize(8.75);
  static final small = FontSize(11.375);
  static final medium = FontSize(14.0);
  static final large = FontSize(15.75);
  static final xLarge = FontSize(21.0);
  static final xxLarge = FontSize(28.0);
  static final smaller = FontSize(83, Unit.percent);
  static final larger = FontSize(120, Unit.percent);

  FontSize(
    double size, [
    Unit unit = Unit.px,
  ]) : super(size, unit);

  static FontSize? inherit(FontSize? parent, FontSize? child) {
    if (child != null && parent != null) {
      if (child.unit == Unit.em) {
        return FontSize(child.value * parent.value);
      } else if (child.unit == Unit.percent) {
        return FontSize(child.value / 100.0 * parent.value);
      }
      return child;
    }

    return parent;
  }

  double get emValue => value;
}
