import Foundation
import Combine

final class ContentViewModel: ObservableObject {
    @Published var selectedTab: Int = 0
    
    private var cancellables = Set<AnyCancellable>()
    
    init() {
        $selectedTab
            .sink { newTab in
                HapticManager.shared.selection()
            }
            .store(in: &cancellables)
    }
}
