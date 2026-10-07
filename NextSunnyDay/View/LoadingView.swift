import SwiftUI

struct LoadingView: View {
  var body: some View {
    ZStack {
      Color(.systemBackground)
        .opacity(0.9)
        .edgesIgnoringSafeArea(.all)
      ProgressView("Fetching data…")
    }
  }
}

struct LoadingView_Previews: PreviewProvider {
  static var previews: some View {
    LoadingView()
  }
}
