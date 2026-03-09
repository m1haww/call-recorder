import SwiftUI
import Combine
import RevenueCat

final class SubscriptionService : ObservableObject {
    static let shared = SubscriptionService()
    
    @Published var isProUser: Bool = false
    @Published var showPaywall = false
    
    private let entitlementKey = "Main"
    
    private init () {}
    
    func checkSubscriptionStatus() {
        Purchases.shared.getCustomerInfo { (customerInfo, error) in
            self.isProUser = customerInfo?.entitlements.all[self.entitlementKey]?.isActive == true
        }
    }
}
