import Foundation

class OnboardingManager: ObservableObject {
    static let shared = OnboardingManager()
    
    @Published var onboardingState = OnboardingState()
    
    private let userDefaults = UserDefaults.standard
    private let onboardingKey = "onboarding_state"
    
    private init() {
        loadOnboardingState()
    }
    
    var isCompleted: Bool {
        onboardingState.isCompleted
    }
    
    func completeOnboarding() {
        onboardingState.isCompleted = true
        saveOnboardingState()
    }
    
    func restartOnboarding() {
        onboardingState = OnboardingState()
        saveOnboardingState()
    }
    
    func markStepCompleted(_ step: Int) {
        onboardingState.completedSteps.insert(step)
        onboardingState.currentStep = min(step + 1, 8) // 0-8 for 9 steps
        saveOnboardingState()
    }
    
    func markStepSkipped(_ step: Int) {
        onboardingState.skippedSteps.insert(step)
        saveOnboardingState()
    }
    
    func setNotificationPermissionRequested() {
        onboardingState.notificationPermissionRequested = true
        saveOnboardingState()
    }
    
    private func saveOnboardingState() {
        if let data = try? JSONEncoder().encode(onboardingState) {
            userDefaults.set(data, forKey: onboardingKey)
        }
    }
    
    private func loadOnboardingState() {
        if let data = userDefaults.data(forKey: onboardingKey),
           let state = try? JSONDecoder().decode(OnboardingState.self, from: data) {
            onboardingState = state
        }
    }
}

struct OnboardingState: Codable {
    var isCompleted: Bool = false
    var currentStep: Int = 0
    var completedSteps: Set<Int> = []
    var skippedSteps: Set<Int> = []
    var notificationPermissionRequested: Bool = false
} 