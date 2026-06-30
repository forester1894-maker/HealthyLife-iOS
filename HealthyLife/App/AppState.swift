import Foundation
import SwiftUI

@MainActor
final class AppState: ObservableObject {
    @Published var licenseStatus: LicenseStatus = .checking
    @Published var consentAccepted: Bool = false
    @Published var profile: UserProfile?
    @Published var weeklyPlan: WeeklyPlan?

    let licenseService = LicenseService()
    let profileStore = ProfileStore()
    let consentStore = ConsentStore()

    func bootstrap() async {
        consentAccepted = consentStore.isAccepted
        profile = profileStore.load()
        licenseStatus = await licenseService.evaluateAccess()
    }

    func onActivated() async {
        licenseStatus = await licenseService.evaluateAccess()
    }

    func acceptConsent() {
        consentStore.accept()
        consentAccepted = true
    }

    func saveProfile(_ profile: UserProfile) {
        self.profile = profile
        profileStore.save(profile)
        weeklyPlan = WeeklyPlanGenerator.generate(for: profile)
    }

    func clearProfile() {
        profile = nil
        weeklyPlan = nil
        profileStore.clear()
    }
}

enum AppRoute {
    case activation
    case consent
    case survey
    case main
}

extension AppState {
    var currentRoute: AppRoute {
        if licenseStatus == .needsActivation || licenseStatus == .blocked {
            return .activation
        }
        if !consentAccepted { return .consent }
        if profile == nil { return .survey }
        return .main
    }
}
