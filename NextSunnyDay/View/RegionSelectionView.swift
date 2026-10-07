import Combine
import MapKit
import SwiftUI

struct RegionSelectionView<T>: View where T: RegionSelectionViewModelObject {
  @ObservedObject private var viewModel: T
  @Environment(\.presentationMode) var presentationMode

  init(viewModel: T) {
    self.viewModel = viewModel
  }

  var body: some View {
    ZStack {
      Color(.systemGroupedBackground).edgesIgnoringSafeArea(.all)
      VStack {
        SearchBar(
          text: $viewModel.binding.cityName,
          placeholder: String(localized: "Enter an address or place name"))
        completionList
      }
    }
    .font(.none)
    .navigationBarTitle(Text("Set Region"))
  }
}

extension RegionSelectionView {
  private var completionList: some View {
    List {
      Section(
        header: Text(
          viewModel.output.completions.isEmpty ? "" : String(localized: "Search Results"))
      ) {
        ForEach(viewModel.output.completions) { completion in
          Button(
            action: {
              UIApplication.shared.sendAction(
                #selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
              viewModel.binding.selectedCompletion = completion
              viewModel.binding.isShowingAlert = true
            },
            label: {
              VStack(alignment: .leading) {
                Text(completion.title)
                  .foregroundColor(Color(.label))
                Text(completion.subtitle)
                  .font(.subheadline)
                  .foregroundColor(Color(.secondaryLabel))
              }
            }
          )
        }
      }
    }
    .listStyle(InsetGroupedListStyle())
    .alert(isPresented: $viewModel.binding.isShowingAlert) {
      Alert(
        title: Text("Set Region"),
        message: Text("Set region to “\(viewModel.binding.selectedCompletion.title)”?"),
        primaryButton: .cancel(Text("Cancel")),
        secondaryButton: .default(
          Text("OK"),
          action: {
            viewModel.input.regionSelected.send()
            presentationMode.wrappedValue.dismiss()
          }
        )
      )
    }
  }
}

struct RegionSelectionView_Previews: PreviewProvider {
  static var previews: some View {
    Group {
      RegionSelectionView(viewModel: MockViewModel())
      RegionSelectionView(viewModel: MockViewModel(cityName: "東京都"))
    }
  }
}

extension RegionSelectionView_Previews {
  final class MockViewModel: RegionSelectionViewModelObject {
    final class Input: RegionSelectionViewModelInputObject {
      var regionSelected = PassthroughSubject<Void, Never>()
    }

    final class Binding: RegionSelectionViewModelBindingObject {
      @Published var cityName: String = ""
      @Published var selectedCompletion = MKLocalSearchCompletion()
      @Published var isShowingAlert = false
    }

    final class Output: RegionSelectionViewModelOutputObject {
      @Published var completions: [MKLocalSearchCompletion] = []
    }

    var input: Input

    var binding: Binding

    var output: Output

    @ObservedObject private var localSearchService = LocalSearchService()

    private var cancellables: [AnyCancellable] = []

    init(cityName: String = "") {
      input = Input()
      binding = Binding()
      output = Output()

      localSearchService.$completions
        .assign(to: \.completions, on: output)
        .store(in: &cancellables)

      binding.$cityName
        .receive(on: DispatchQueue.main)
        .sink(
          receiveValue: { [weak self] in
            if $0.isEmpty {
              self?.output.completions = []
            } else {
              self?.localSearchService.searchQuery = $0
            }
          }
        )
        .store(in: &cancellables)

      binding.cityName = cityName
    }
  }
}
