import Foundation
import SwiftUI

@MainActor
final class AppState: ObservableObject {
    @Published var licenseStatus: LicenseStatus = .checking
    @Published var consentAccepted = false
    @Published var profile: UserProfile?
    @Published var weeklyPlan: WeeklyPlan?
    @Published var licenseExpiryNotice: String?
    @Published var autoTrialInProgress = false
    @Published var trialExpiredNotice = false
    @Published var showPlanReady = false
    @Published var diaryEntries: [FoodDiaryEntry] = []
    @Published var weightEntries: [WeightEntry] = []
    @Published var reminderSettings = ReminderSettings()
    @Published var aiMessages: [ChatMessage] = []
    @Published var therapeuticProfile: TherapeuticNutritionProfile?

    let licenseService = LicenseService()
    let profileStore = ProfileStore()
    let consentStore = ConsentStore()
    let planStore = PlanStore()
    let diaryStore = DiaryStore()
    let weightStore = WeightStore()
    let reminderStore = ReminderStore()
    let aiChatStore = AiChatStore()

    private var todayIso: String {
        let f = DateFormatter()
        f.dateFormat = "yyyy-MM-dd"
        f.locale = Locale(identifier: "en_US_POSIX")
        return f.string(from: Date())
    }

    func bootstrap() async {
        consentAccepted = consentStore.isAccepted
        profile = profileStore.load()
        weeklyPlan = planStore.load()
        diaryEntries = diaryStore.loadEntries()
        weightEntries = weightStore.load()
        reminderSettings = reminderStore.load()
        aiMessages = aiChatStore.load()
        refreshTherapeuticProfile()

        if AppConfig.autoTrialEnabled, licenseStatus == .checking {
            autoTrialInProgress = true
        }
        let (status, trialExpired) = await licenseService.bootstrapAccess()
        licenseStatus = status
        trialExpiredNotice = trialExpired
        autoTrialInProgress = false
        licenseExpiryNotice = await licenseService.expiryNoticeText()
    }

    func onActivated() async {
        licenseStatus = await licenseService.evaluateAccess()
        licenseExpiryNotice = await licenseService.expiryNoticeText()
    }

    func acceptConsent() {
        consentStore.accept()
        consentAccepted = true
    }

    func completeSurvey(_ profile: UserProfile) {
        saveProfile(profile)
        showPlanReady = true
    }

    func dismissPlanReady() {
        showPlanReady = false
    }

    func saveProfile(_ profile: UserProfile) {
        self.profile = profile
        profileStore.save(profile)
        regeneratePlan()
    }

    func regeneratePlan() {
        guard let profile else { return }
        weeklyPlan = WeeklyPlanGenerator.generate(for: profile)
        planStore.save(weeklyPlan!)
        refreshTherapeuticProfile()
    }

    func clearProfile() {
        profile = nil
        weeklyPlan = nil
        profileStore.clear()
        planStore.clear()
        diaryStore.clear()
        diaryEntries = []
        therapeuticProfile = nil
        showPlanReady = false
    }

    func refreshTherapeuticProfile() {
        guard let profile else {
            therapeuticProfile = nil
            return
        }
        therapeuticProfile = TherapeuticNutritionEngine.profileFor(profile)
    }

    var dailyProgress: DailyProgress? {
        guard let profile, let plan = weeklyPlan else { return nil }
        let entries = diaryEntries.filter { $0.dateIso == todayIso }
        let water = diaryStore.waterGlasses(for: todayIso)
        return DailyProgressCalculator.calculate(
            profile: profile, plan: plan, entries: entries, waterGlasses: water, dateIso: todayIso
        )
    }

    var waterGlassesToday: Int {
        diaryStore.waterGlasses(for: todayIso)
    }

    func addWaterGlass() {
        let next = min(waterGlassesToday + 1, weeklyPlan?.waterGlasses ?? 12)
        diaryStore.setWaterGlasses(next, for: todayIso)
        objectWillChange.send()
    }

    func markMealEaten(_ meal: DayMeal) {
        let entry = FoodDiaryEntry(
            dateIso: todayIso,
            mealType: meal.mealType,
            foodName: meal.dishName,
            calories: Double(meal.calories),
            protein: meal.proteinG,
            carbs: meal.carbsG,
            fat: meal.fatG,
            sodiumMg: meal.sodiumMg,
            sugarG: meal.sugarG,
            saturatedFatG: meal.saturatedFatG,
            fromPlan: true
        )
        diaryStore.add(entry)
        diaryEntries = diaryStore.loadEntries()
    }

    func addDiaryEntry(_ entry: FoodDiaryEntry) {
        diaryStore.add(entry)
        diaryEntries = diaryStore.loadEntries()
    }

    func removeDiaryEntry(id: String) {
        diaryStore.remove(id: id)
        diaryEntries = diaryStore.loadEntries()
    }

    func swapMeal(dayIndex: Int, mealIndex: Int) {
        guard let profile, var plan = weeklyPlan else { return }
        plan = WeeklyPlanGenerator.swapMeal(plan: plan, profile: profile, dayIndex: dayIndex, mealIndex: mealIndex)
        weeklyPlan = plan
        planStore.save(plan)
    }

    func addWeight(_ kg: Float, note: String? = nil) {
        let entry = WeightEntry(dateIso: todayIso, weightKg: kg, note: note)
        weightStore.add(entry)
        weightEntries = weightStore.load()
    }

    func saveReminders(_ settings: ReminderSettings) {
        reminderSettings = settings
        reminderStore.save(settings)
    }

    func sendAiMessage(_ text: String) async {
        let userMsg = ChatMessage(role: "user", content: text)
        aiMessages.append(userMsg)
        aiChatStore.save(aiMessages)
        do {
            let reply = try await YandexAiService.shared.ask(
                question: text, profile: profile, plan: weeklyPlan, history: aiMessages
            )
            let assistant = ChatMessage(role: "assistant", content: reply.text, modelBadge: reply.model)
            aiMessages.append(assistant)
            aiChatStore.save(aiMessages)
        } catch {
            let err = ChatMessage(role: "assistant", content: "Ошибка: \(error.localizedDescription)")
            aiMessages.append(err)
            aiChatStore.save(aiMessages)
        }
    }

    func todayDayIndex() -> Int {
        let weekday = Calendar.current.component(.weekday, from: Date())
        return weekday == 1 ? 6 : weekday - 2
    }
}

enum AppRoute {
    case activation
    case consent
    case survey
    case planReady
    case main
}

extension AppState {
    var currentRoute: AppRoute {
        if licenseStatus == .needsActivation || licenseStatus == .blocked {
            return .activation
        }
        if !consentAccepted { return .consent }
        if profile == nil { return .survey }
        if showPlanReady { return .planReady }
        return .main
    }
}
