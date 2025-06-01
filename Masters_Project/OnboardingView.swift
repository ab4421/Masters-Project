import SwiftUI
import RoomPlan

struct OnboardingView: View {
    @Binding var showOnboarding: Bool
    @State private var currentPage = 0
    @StateObject private var onboardingManager = OnboardingManager.shared
    @StateObject private var roomDataManager = RoomDataManager.shared
    
    // Check device capabilities
    private let isRoomPlanSupported = RoomCaptureSession.isSupported
    
    var body: some View {
        TabView(selection: $currentPage) {
            ForEach(0..<onboardingPages.count, id: \.self) { index in
                OnboardingPageView(
                    page: onboardingPages[index],
                    currentPage: index,
                    totalPages: onboardingPages.count,
                    onNext: { 
                        moveToNextPage()
                    },
                    onSkip: { 
                        skipCurrentPage()
                    },
                    onComplete: { 
                        completeOnboarding()
                    }
                )
                .tag(index)
            }
        }
        .tabViewStyle(PageTabViewStyle(indexDisplayMode: .always))
        .indexViewStyle(PageIndexViewStyle(backgroundDisplayMode: .always))
        .onAppear {
            currentPage = onboardingManager.onboardingState.currentStep
        }
    }
    
    // MARK: - Navigation Actions
    
    private func moveToNextPage() {
        onboardingManager.markStepCompleted(currentPage)
        
        if currentPage < onboardingPages.count - 1 {
            withAnimation {
                currentPage += 1
            }
        } else {
            completeOnboarding()
        }
    }
    
    private func skipCurrentPage() {
        onboardingManager.markStepSkipped(currentPage)
        
        if currentPage < onboardingPages.count - 1 {
            withAnimation {
                currentPage += 1
            }
        } else {
            completeOnboarding()
        }
    }
    
    private func completeOnboarding() {
        onboardingManager.completeOnboarding()
        showOnboarding = false
    }
    
    private func skipEntireTutorial() {
        onboardingManager.completeOnboarding()
        showOnboarding = false
    }
    
    // MARK: - Page Definitions
    
    private var onboardingPages: [OnboardingPageData] {
        [
            // Step 1: Welcome & Core Concept
            OnboardingPageData(
                title: "Welcome to Habit Home",
                description: "Transform your home into a habit-building environment through intelligent object placement.",
                visual: AnyView(WelcomeVisual()),
                interactiveContent: AnyView(CoreConceptFormula()),
                primaryButtonText: "Continue",
                primaryAction: moveToNextPage,
                secondaryButtonText: "Skip Tutorial",
                secondaryAction: skipEntireTutorial
            ),
            
            // Step 2: Room Scanning
            OnboardingPageData(
                title: "Room Scanning",
                description: isRoomPlanSupported ? 
                    "You'll create a 3D map of your space while tracking your movement patterns. Your data stays private and secure on your device." :
                    "You'll need someone with a newer iPhone/iPad to scan your room and share the JSON file with you to import.",
                visual: AnyView(RoomScanningVisual(isSupported: isRoomPlanSupported)),
                interactiveContent: nil,
                primaryButtonText: hasExistingRoomData ? "Continue with saved room" : "Continue",
                primaryAction: moveToNextPage,
                secondaryButtonText: nil,
                secondaryAction: nil
            ),
            
            // Step 3: Habit Selection
            OnboardingPageData(
                title: "Choose Your Habit",
                description: "You'll select a habit you'd like to build in this space. You can change this anytime in the app.",
                visual: AnyView(HabitSelectionVisual()),
                interactiveContent: AnyView(HabitGrid()),
                primaryButtonText: "Continue",
                primaryAction: moveToNextPage,
                secondaryButtonText: nil,
                secondaryAction: nil
            ),
            
            // Step 4: AI Analysis & Recommendations
            OnboardingPageData(
                title: "Recommendation Algorithm",
                description: "Our recommendation algorithm analyzes your room layout and movement patterns to find the optimal object placement for habit success.",
                visual: AnyView(AIAnalysisVisual()),
                interactiveContent: nil,
                primaryButtonText: "Continue",
                primaryAction: moveToNextPage,
                secondaryButtonText: nil,
                secondaryAction: nil
            ),
            
            // Step 5: Customization Power
            OnboardingPageData(
                title: "Customization Options",
                description: "You'll be able to fine-tune recommendations to your preferences. Adjust importance weights and select specific furniture pieces to optimize the algorithm.",
                visual: AnyView(CustomizationVisual()),
                interactiveContent: AnyView(CustomizationDemo()),
                primaryButtonText: "Continue",
                primaryAction: moveToNextPage,
                secondaryButtonText: nil,
                secondaryAction: nil
            ),
            
            // Step 6: Research Participation
            OnboardingPageData(
                title: "Research Participation",
                description: "You'll help us understand how environment affects habits and wellbeing through two quick daily check-ins.",
                visual: AnyView(ResearchVisual()),
                interactiveContent: AnyView(ResearchDetails()),
                primaryButtonText: "Learn about reminders",
                primaryAction: moveToNextPage,
                secondaryButtonText: nil,
                secondaryAction: nil
            ),
            
            // Step 7: Smart Notifications
            OnboardingPageData(
                title: "Smart Notifications",
                description: "Gentle daily reminders to complete your check-ins. Notifications automatically stop when you've completed both surveys.",
                visual: AnyView(NotificationVisual()),
                interactiveContent: AnyView(NotificationSchedule()),
                primaryButtonText: "Enable reminders",
                primaryAction: {
                    NotificationManager.shared.requestNotificationPermission()
                    onboardingManager.setNotificationPermissionRequested()
                    moveToNextPage()
                },
                secondaryButtonText: "Maybe later",
                secondaryAction: skipCurrentPage
            ),
            
            // Step 8: Support & Research Impact
            OnboardingPageData(
                title: "Support & Research Impact",
                description: "Questions? Need help? You're contributing to Masters research at Imperial College that advances technology-supported healthy living.",
                visual: AnyView(SupportVisual()),
                interactiveContent: AnyView(ContactInfo()),
                primaryButtonText: "Continue",
                primaryAction: moveToNextPage,
                secondaryButtonText: nil,
                secondaryAction: nil
            ),
            
            // Step 9: Ready to Start
            OnboardingPageData(
                title: "Ready to Start!",
                description: "You're all set! Let's build better habits through smarter environments.",
                visual: AnyView(ReadyToStartVisual()),
                interactiveContent: AnyView(AppPreview()),
                primaryButtonText: getStartButtonText(),
                primaryAction: completeOnboarding,
                secondaryButtonText: nil,
                secondaryAction: nil
            )
        ]
    }
    
    // MARK: - Helper Properties
    
    private var hasExistingRoomData: Bool {
        roomDataManager.hasPersistedRoom
    }
    
    private func getStartButtonText() -> String {
        if !hasExistingRoomData {
            return "Start scanning my room"
        } else {
            return "Explore the app"
        }
    }
}

// MARK: - Page Data Model

struct OnboardingPageData {
    let title: String
    let description: String
    let visual: AnyView
    let interactiveContent: AnyView?
    let primaryButtonText: String
    let primaryAction: () -> Void
    let secondaryButtonText: String?
    let secondaryAction: (() -> Void)?
}

#Preview {
    OnboardingView(showOnboarding: .constant(true))
} 