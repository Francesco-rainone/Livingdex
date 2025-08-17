/// A utility class that defines standard screen width breakpoints for building
/// responsive user interfaces.
///
/// These values are based on the Material Design 3 responsive layout grid guidelines,
/// which categorize window sizes to help adapt UIs to different screen dimensions.
/// They represent the threshold in logical pixels for each size category.
class Breakpoints {
  /// The breakpoint for compact screen widths, typically for phones in portrait mode.
  /// A screen width below this value is considered 'Compact'.
  static int get compact => 600;

  /// The breakpoint for medium screen widths, such as small tablets or phones in landscape mode.
  /// A screen width between 'compact' (600) and 'medium' (840) is considered 'Medium'.
  static int get medium => 840;

  /// The breakpoint for expanded screen widths, suitable for large tablets or small laptops.
  /// A screen width between 'medium' (840) and 'expanded' (1200) is considered 'Expanded'.
  static int get expanded => 1200;

  /// The breakpoint for large screen widths, designed for standard desktops.
  /// A screen width between 'expanded' (1200) and 'large' (1600) is considered 'Large'.
  static int get large => 1600;
}
