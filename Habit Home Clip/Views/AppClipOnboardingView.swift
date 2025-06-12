import SwiftUI
import RoomPlan

struct AppClipOnboardingView: View {
    @Binding var showOnboarding: Bool
    let roomData: CapturedRoom?
    let pathPoints: [PathPoint]
    
    @State private var currentPage = 0
    
    private let onboardingPages: [AppClipOnboardingPage] = [
        AppClipOnboardingPage(
            title: "Welcome to Habit Home",
            subtitle: "App Clip Preview",
            description: "Discover how intelligent object placement can transform your space into a habit-building environment.",
            visual: AnyView(AppClipWelcomeVisual()),
            showContinueButton: true
        ),
        AppClipOnboardingPage(
            title: "Room Analysis",
            subtitle: "AI-Powered Recommendations",
            description: "Our algorithm analyzes room layouts and movement patterns to find optimal placement for habit objects.",
            visual: AnyView(AppClipRoomAnalysisVisual()),
            showContinueButton: true
        ),
        AppClipOnboardingPage(
            title: "Try It Now",
            subtitle: "Interactive Demo",
            description: "Select a habit and see real-time recommendations in this sample room. Adjust settings to see how placement changes.",
            visual: AnyView(AppClipDemoVisual()),
            showContinueButton: false
        )
    ]
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Progress indicator
                HStack {
                    ForEach(0..<onboardingPages.count, id: \.self) { index in
                        Rectangle()
                            .fill(index <= currentPage ? Color.blue : Color.gray.opacity(0.3))
                            .frame(height: 4)
                            .animation(.easeInOut(duration: 0.3), value: currentPage)
                    }
                }
                .padding(.horizontal)
                .padding(.top)
                
                TabView(selection: $currentPage) {
                    ForEach(0..<onboardingPages.count, id: \.self) { index in
                        AppClipOnboardingPageView(
                            page: onboardingPages[index],
                            currentPage: index,
                            totalPages: onboardingPages.count,
                            onNext: {
                                if index < onboardingPages.count - 1 {
                                    withAnimation {
                                        currentPage += 1
                                    }
                                } else {
                                    completeOnboarding()
                                }
                            },
                            onStartDemo: completeOnboarding
                        )
                        .tag(index)
                    }
                }
                .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
            }
            .navigationBarHidden(true)
        }
        .navigationViewStyle(StackNavigationViewStyle())
    }
    
    private func completeOnboarding() {
        showOnboarding = false
    }
}

// MARK: - Page Data Model

struct AppClipOnboardingPage {
    let title: String
    let subtitle: String
    let description: String
    let visual: AnyView
    let showContinueButton: Bool
}

// MARK: - Individual Page View

struct AppClipOnboardingPageView: View {
    let page: AppClipOnboardingPage
    let currentPage: Int
    let totalPages: Int
    let onNext: () -> Void
    let onStartDemo: () -> Void
    
    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: 32) {
                Spacer(minLength: 20)
                
                // Visual content
                page.visual
                    .frame(maxHeight: 300)
                
                // Text content
                VStack(spacing: 16) {
                    Text(page.subtitle)
                        .font(.subheadline)
                        .foregroundColor(.blue)
                        .textCase(.uppercase)
                    
                    Text(page.title)
                        .font(.largeTitle)
                        .bold()
                        .multilineTextAlignment(.center)
                    
                    Text(page.description)
                        .font(.body)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 20)
                }
                
                Spacer(minLength: 20)
                
                // Action buttons
                VStack(spacing: 12) {
                    if page.showContinueButton {
                        Button(action: onNext) {
                            HStack {
                                Text("Continue")
                                Image(systemName: "arrow.right")
                            }
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.blue)
                            .foregroundColor(.white)
                            .cornerRadius(12)
                        }
                        .padding(.horizontal, 40)
                    } else {
                        Button(action: onStartDemo) {
                            HStack {
                                Text("Start Demo")
                                Image(systemName: "play.fill")
                            }
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.blue)
                            .foregroundColor(.white)
                            .cornerRadius(12)
                        }
                        .padding(.horizontal, 40)
                    }
                    
                    if currentPage == 0 {
                        Button("Skip to Demo") {
                            onStartDemo()
                        }
                        .foregroundColor(.blue)
                        .padding(.top, 8)
                    }
                }
                
                Spacer(minLength: 40)
            }
        }
    }
}

// MARK: - Visual Components

struct AppClipWelcomeVisual: View {
    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: "house.fill")
                .font(.system(size: 80))
                .foregroundColor(.blue)
            
            HStack(spacing: 8) {
                Image(systemName: "plus")
                    .font(.title2)
                    .foregroundColor(.secondary)
                
                Image(systemName: "brain.head.profile")
                    .font(.system(size: 40))
                    .foregroundColor(.orange)
                
                Image(systemName: "equal")
                    .font(.title2)
                    .foregroundColor(.secondary)
                
                Image(systemName: "checkmark.circle.fill")
                    .font(.system(size: 40))
                    .foregroundColor(.green)
            }
        }
    }
}

struct AppClipRoomAnalysisVisual: View {
    @State private var animationPhase = 0
    
    var body: some View {
        VStack(spacing: 20) {
            ZStack {
                // Room outline
                RoundedRectangle(cornerRadius: 12)
                    .stroke(Color.blue, lineWidth: 2)
                    .frame(width: 200, height: 150)
                
                // Furniture items
                HStack(spacing: 20) {
                    Rectangle()
                        .fill(Color.gray.opacity(0.6))
                        .frame(width: 30, height: 20)
                        .cornerRadius(4)
                    
                    Rectangle()
                        .fill(Color.gray.opacity(0.6))
                        .frame(width: 25, height: 25)
                        .cornerRadius(4)
                }
                
                // Analysis lines
                if animationPhase > 0 {
                    Path { path in
                        path.move(to: CGPoint(x: 50, y: 75))
                        path.addLine(to: CGPoint(x: 150, y: 75))
                    }
                    .stroke(Color.orange, lineWidth: 2)
                    .opacity(animationPhase > 1 ? 1.0 : 0.6)
                }
                
                // Recommendation highlight
                if animationPhase > 1 {
                    Circle()
                        .fill(Color.red.opacity(0.3))
                        .frame(width: 40, height: 40)
                        .position(x: 120, y: 60)
                }
            }
            
            HStack(spacing: 8) {
                Image(systemName: "cpu")
                    .foregroundColor(.blue)
                Text("Analyzing...")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
        .onAppear {
            withAnimation(.easeInOut(duration: 1.0)) {
                animationPhase = 1
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                withAnimation(.easeInOut(duration: 0.8)) {
                    animationPhase = 2
                }
            }
        }
    }
}

struct AppClipDemoVisual: View {
    var body: some View {
        VStack(spacing: 20) {
            HStack(spacing: 16) {
                VStack {
                    Image(systemName: "drop.fill")
                        .font(.system(size: 30))
                        .foregroundColor(.blue)
                    Text("Hydration")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                .padding()
                .background(Color.blue.opacity(0.1))
                .cornerRadius(12)
                
                VStack {
                    Image(systemName: "leaf.fill")
                        .font(.system(size: 30))
                        .foregroundColor(.green)
                    Text("Nutrition")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                .padding()
                .background(Color.green.opacity(0.1))
                .cornerRadius(12)
                
                VStack {
                    Image(systemName: "figure.yoga")
                        .font(.system(size: 30))
                        .foregroundColor(.orange)
                    Text("Movement")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                .padding()
                .background(Color.orange.opacity(0.1))
                .cornerRadius(12)
            }
            
            Text("↓")
                .font(.title)
                .foregroundColor(.secondary)
            
            RoundedRectangle(cornerRadius: 8)
                .fill(Color.gray.opacity(0.2))
                .frame(width: 150, height: 100)
                .overlay(
                    VStack {
                        Image(systemName: "cube.transparent")
                            .font(.system(size: 30))
                            .foregroundColor(.blue)
                        Text("3D Room View")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                )
        }
    }
}

#Preview {
    AppClipOnboardingView(
        showOnboarding: .constant(true),
        roomData: nil,
        pathPoints: []
    )
} 