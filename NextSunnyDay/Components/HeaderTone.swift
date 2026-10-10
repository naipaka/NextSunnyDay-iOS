import SwiftUI

/// The color of a layered screen's header. It is a gradient that gets lighter toward the top,
/// like sunlight: orange toward yellow, the grays toward white.
enum HeaderTone {
  /// A sunny day.
  case sunny
  /// No sunny day.
  case gray
  /// Loading or no data.
  case noData

  var color: Color {
    switch self {
    case .sunny: .orange
    case .gray: Color(.systemGray)
    case .noData: Color(.systemGray2)
    }
  }

  /// The top of the gradient, about #FFB047 for orange in light mode.
  var top: Color {
    switch self {
    case .sunny: color.mix(with: .yellow, by: 0.4).mix(with: .white, by: 0.1)
    case .gray, .noData: color.mix(with: .white, by: 0.18)
    }
  }

  /// The gradient, or the flat color with Increase Contrast, where the lighter top would lower
  /// the contrast of the white text.
  func fill(increasedContrast: Bool) -> AnyShapeStyle {
    if increasedContrast {
      AnyShapeStyle(color)
    } else {
      AnyShapeStyle(LinearGradient(colors: [top, color], startPoint: .top, endPoint: .bottom))
    }
  }
}
