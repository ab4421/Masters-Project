import SwiftUI

struct OnboardingPageView: View {
    let page: OnboardingPageData
    let currentPage: Int
    let totalPages: Int
    let onNext: () -> Void
    let onSkip: () -> Void
    let onComplete: () -> Void
    
    @State private var showSkipConfirmation = false
    
    var body: some View {
        VStack(spacing: 0) {
            // Top section with skip button
            HStack {
                Spacer()
                if currentPage < totalPages - 1 && currentPage > 0 {
                    Button("Skip Tutorial") {
                        showSkipConfirmation = true
                    }
                    .font(.body)
                    .foregroundColor(.blue)
                }
            }
            .padding(.horizontal, 20)
            .padding(.top, 16)
            .frame(height: 50)
            
            // Main content area
            ScrollView {
                VStack(spacing: 32) {
                    Spacer(minLength: 20)
                    
                    // Main visual
                    page.visual
                        .frame(maxHeight: 200)
                    
                    // Title and description
                    VStack(spacing: 16) {
                        Text(page.title)
                            .font(.largeTitle)
                            .bold()
                            .multilineTextAlignment(.center)
                            .foregroundColor(.primary)
                        
                        Text(page.description)
                            .font(.body)
                            .multilineTextAlignment(.center)
                            .foregroundColor(.secondary)
                            .lineLimit(nil)
                    }
                    .padding(.horizontal, 32)
                    
                    // Interactive content (if available)
                    if let interactiveContent = page.interactiveContent {
                        interactiveContent
                            .padding(.horizontal, 20)
                    }
                    
                    Spacer(minLength: 40)
                }
            }
            
            // Bottom button section
            VStack(spacing: 16) {
                // Primary button
                Button(action: page.primaryAction) {
                    Text(page.primaryButtonText)
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(Color.blue)
                        .cornerRadius(12)
                }
                
                // Secondary button (if available)
                if let secondaryText = page.secondaryButtonText,
                   let secondaryAction = page.secondaryAction {
                    Button(action: secondaryAction) {
                        Text(secondaryText)
                            .font(.body)
                            .foregroundColor(.secondary)
                    }
                } else {
                    // Add spacing to maintain consistent layout when no secondary button
                    Spacer()
                        .frame(height: 20)
                }
            }
            .padding(.horizontal, 32)
            .padding(.bottom, 40)
        }
        .alert("Skip Tutorial", isPresented: $showSkipConfirmation) {
            Button("Skip", role: .destructive) {
                onComplete()
            }
            Button("Cancel", role: .cancel) { }
        } message: {
            Text("Are you sure you want to skip the tutorial? You can always replay it from the About section.")
        }
    }
}

#Preview {
    OnboardingPageView(
        page: OnboardingPageData(
            title: "Welcome to Smart Living Spaces",
            description: "Transform your home into a habit-building environment through intelligent object placement.",
            visual: AnyView(
                VStack {
                    Image(systemName: "house.and.flag.fill")
                        .font(.system(size: 60))
                        .foregroundColor(.blue)
                }
            ),
            interactiveContent: AnyView(
                VStack {
                    Text("Interactive content goes here")
                        .padding()
                        .background(Color.gray.opacity(0.1))
                        .cornerRadius(8)
                }
            ),
            primaryButtonText: "Let's transform your space",
            primaryAction: { },
            secondaryButtonText: "Skip Tutorial",
            secondaryAction: { }
        ),
        currentPage: 0,
        totalPages: 9,
        onNext: { },
        onSkip: { },
        onComplete: { }
    )
} 