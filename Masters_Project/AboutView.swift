import SwiftUI

struct AboutView: View {
    @StateObject private var onboardingManager = OnboardingManager.shared
    @State private var showOnboarding = false
    
    var body: some View {
        ScrollView {
            LazyVStack(spacing: 0) {
                // Header with visual icon
                VStack(spacing: 16) {
                    VStack(spacing: 12) {
                        Image(systemName: "house.and.flag.fill")
                            .font(.system(size: 60))
                            .foregroundColor(.blue)
                        
                        Text("Smart Living Spaces")
                            .font(.title)
                            .bold()
                            .multilineTextAlignment(.center)
                        
                        Text("Habit Formation Through Environmental Design")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 24)
                    .padding(.horizontal, 20)
                    .background(
                        LinearGradient(
                            gradient: Gradient(colors: [Color.blue.opacity(0.1), Color.purple.opacity(0.1)]),
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .cornerRadius(16)
                }
                .padding(.horizontal, 20)
                .padding(.top, 20)
                
                // Tutorial Section
                VStack(alignment: .leading, spacing: 16) {
                    SectionHeader(title: "Tutorial", icon: "play.circle.fill")
                    
                    VStack(spacing: 12) {
                        Text("New to the app or want a refresher? Replay the interactive tutorial to learn about all features.")
                            .font(.body)
                            .foregroundColor(.secondary)
                            .frame(maxWidth: .infinity, alignment: .leading)
                        
                        Button(action: {
                            onboardingManager.restartOnboarding()
                            showOnboarding = true
                        }) {
                            HStack {
                                Image(systemName: "play.circle.fill")
                                Text("Replay Tutorial")
                            }
                            .font(.headline)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.blue)
                            .cornerRadius(12)
                        }
                    }
                    .padding(16)
                    .background(Color(.systemGray6))
                    .cornerRadius(12)
                }
                .padding(.horizontal, 20)
                .padding(.top, 32)
                
                // Core Concept Visual
                VStack(alignment: .leading, spacing: 16) {
                    SectionHeader(title: "Core Concept", icon: "lightbulb.fill")
                    
                    VStack(spacing: 16) {
                        HStack(spacing: 12) {
                            // Visual Cues
                            ConceptPillar(
                                icon: "eye.fill",
                                title: "Visual Cues",
                                subtitle: "Maximize",
                                color: .green
                            )
                            
                            Image(systemName: "plus")
                                .font(.title2)
                                .foregroundColor(.gray)
                                .frame(minWidth: 20)
                            
                            // Low Friction
                            ConceptPillar(
                                icon: "speedometer",
                                title: "Low Friction",
                                subtitle: "Minimize",
                                color: .orange
                            )
                            
                            Image(systemName: "equal")
                                .font(.title2)
                                .foregroundColor(.gray)
                                .frame(minWidth: 20)
                            
                            // Better Habits
                            ConceptPillar(
                                icon: "checkmark.circle.fill",
                                title: "Better Habits",
                                subtitle: "Achieve",
                                color: .blue
                            )
                        }
                        .frame(maxWidth: .infinity)
                    }
                    .padding(16)
                    .background(Color(.systemGray6))
                    .cornerRadius(12)
                }
                .padding(.horizontal, 20)
                .padding(.top, 32)
                
                // How It Works - Visual Process
                VStack(alignment: .leading, spacing: 16) {
                    SectionHeader(title: "How It Works", icon: "gearshape.fill")
                    
                    VStack(spacing: 12) {
                        // Step 1: Scanning
                        ProcessStep(
                            stepNumber: 1,
                            icon: "camera.metering.matrix",
                            title: "Room Scanning",
                            description: "3D mapping with movement tracking",
                            color: .blue,
                            visual: RoomScanVisual()
                        )
                        
                        ArrowDown()
                        
                        // Step 2: Analysis
                        ProcessStep(
                            stepNumber: 2,
                            icon: "brain.head.profile",
                            title: "AI Analysis",
                            description: "Path patterns + furniture detection",
                            color: .purple,
                            visual: AnalysisVisual()
                        )
                        
                        ArrowDown()
                        
                        // Step 3: Recommendations
                        ProcessStep(
                            stepNumber: 3,
                            icon: "target",
                            title: "Smart Placement",
                            description: "Optimal object positioning",
                            color: .green,
                            visual: RecommendationVisual()
                        )
                    }
                }
                .padding(.horizontal, 20)
                .padding(.top, 32)
                
                // Algorithm Visualization
                VStack(alignment: .leading, spacing: 16) {
                    SectionHeader(title: "The Algorithm", icon: "function")
                    
                    VStack(spacing: 16) {
                        // Algorithm steps
                        VStack(spacing: 12) {
                            AlgorithmStepView(
                                stepNumber: 1,
                                title: "Surface Detection",
                                description: "Identify all horizontal surfaces in the room",
                                icon: "rectangle.3.group",
                                color: .blue
                            )
                            
                            AlgorithmStepView(
                                stepNumber: 2,
                                title: "Candidate Filtering",
                                description: "Filter for visible, accessible surfaces suitable for object placement",
                                icon: "line.3.horizontal.decrease.circle",
                                color: .purple
                            )
                            
                            AlgorithmStepView(
                                stepNumber: 3,
                                title: "Distance Scoring",
                                description: "Calculate path & furniture proximity scores",
                                icon: "ruler",
                                color: .orange
                            )
                            
                            AlgorithmStepView(
                                stepNumber: 4,
                                title: "Best Surface",
                                description: "Select surface with lowest weighted score",
                                icon: "target",
                                color: .green
                            )
                        }
                        
                        // Visual algorithm representation
                        AlgorithmVisualization()
                        
                        // Simplified formula
                        VStack(spacing: 12) {
                            Text("Scoring Formula")
                                .font(.headline)
                                .bold()
                                .frame(maxWidth: .infinity, alignment: .center)
                            
                            ScrollView(.horizontal, showsIndicators: false) {
                                HStack(spacing: 8) {
                                    FormulaComponent(
                                        icon: "figure.walk",
                                        label: "Path Distance",
                                        color: .blue
                                    )
                                    
                                    Text("×")
                                        .font(.title2)
                                        .foregroundColor(.gray)
                                    
                                    Text("W₁")
                                        .font(.title3)
                                        .bold()
                                        .foregroundColor(.blue)
                                    
                                    Text("+")
                                        .font(.title2)
                                        .foregroundColor(.gray)
                                    
                                    FormulaComponent(
                                        icon: "sofa.fill",
                                        label: "Furniture Distance",
                                        color: .orange
                                    )
                                    
                                    Text("×")
                                        .font(.title2)
                                        .foregroundColor(.gray)
                                    
                                    Text("W₂")
                                        .font(.title3)
                                        .bold()
                                        .foregroundColor(.orange)
                                }
                                .padding(.horizontal, 20)
                            }
                            
                            Text("Lower score = Better placement")
                                .font(.caption)
                                .foregroundColor(.secondary)
                                .frame(maxWidth: .infinity, alignment: .center)
                        }
                        .padding(16)
                        .background(Color(.systemGray6))
                        .cornerRadius(12)
                    }
                }
                .padding(.horizontal, 20)
                .padding(.top, 32)
                
                // User Journey - Visual Flow
                VStack(alignment: .leading, spacing: 16) {
                    SectionHeader(title: "Your Journey", icon: "arrow.right.circle.fill")
                    
                    UserJourneyVisual()
                }
                .padding(.horizontal, 20)
                .padding(.top, 32)
                
                // Research Foundation - Visual
                VStack(alignment: .leading, spacing: 16) {
                    SectionHeader(title: "Research Foundation", icon: "book.fill")
                    
                    LazyVGrid(columns: [
                        GridItem(.flexible(), spacing: 12),
                        GridItem(.flexible(), spacing: 12)
                    ], spacing: 12) {
                        ResearchPillar(
                            icon: "brain.head.profile",
                            title: "Environmental Psychology",
                            description: "How spaces shape behavior",
                            color: .purple
                        )
                        
                        ResearchPillar(
                            icon: "repeat.circle.fill",
                            title: "Habit Formation",
                            description: "Cues & friction theory",
                            color: .green
                        )
                        
                        ResearchPillar(
                            icon: "house.and.flag.fill",
                            title: "Smart Homes",
                            description: "IoT & AR interventions",
                            color: .blue
                        )
                        
                        ResearchPillar(
                            icon: "heart.text.square.fill",
                            title: "Wellbeing",
                            description: "Validated measurement",
                            color: .red
                        )
                    }
                }
                .padding(.horizontal, 20)
                .padding(.top, 32)
                
                // Thank You Section - Visual
                VStack(spacing: 20) {
                    VStack(spacing: 16) {
                        Image(systemName: "heart.circle.fill")
                            .font(.system(size: 50))
                            .foregroundColor(.red)
                        
                        Text("Thank You!")
                            .font(.title)
                            .bold()
                            .multilineTextAlignment(.center)
                        
                        Text("Your participation helps us understand how technology can support healthier living through better environmental design.")
                            .font(.body)
                            .multilineTextAlignment(.center)
                            .foregroundColor(.secondary)
                    }
                    .frame(maxWidth: .infinity)
                    
                    VStack(spacing: 12) {
                        HStack {
                            Image(systemName: "envelope.fill")
                                .foregroundColor(.blue)
                            Text("Contact")
                                .font(.headline)
                                .bold()
                        }
                        
                        VStack(spacing: 4) {
                            Text("Arnav Bhatia")
                                .font(.subheadline)
                                .bold()
                            Text("arnav.bhatia21@imperial.ac.uk")
                                .font(.subheadline)
                                .foregroundColor(.blue)
                        }
                    }
                    .frame(maxWidth: .infinity)
                    .padding(16)
                    .background(
                        LinearGradient(
                            gradient: Gradient(colors: [Color.green.opacity(0.1), Color.blue.opacity(0.1)]),
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .cornerRadius(12)
                }
                .padding(.horizontal, 20)
                .padding(.top, 32)
                .padding(.bottom, 32)
            }
        }
        .navigationTitle("About")
        .navigationBarTitleDisplayMode(.inline)
        .fullScreenCover(isPresented: $showOnboarding) {
            OnboardingView(showOnboarding: $showOnboarding)
        }
    }
}

// MARK: - Supporting Views

struct SectionHeader: View {
    let title: String
    let icon: String
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(.blue)
                .frame(width: 30)
            
            Text(title)
                .font(.title2)
                .bold()
        }
    }
}

// MARK: - Visual Components

struct ConceptPillar: View {
    let icon: String
    let title: String
    let subtitle: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.system(size: 32))
                .foregroundColor(color)
                .frame(width: 64, height: 64)
                .background(color.opacity(0.1))
                .clipShape(Circle())
            
            Text(title)
                .font(.subheadline)
                .bold()
                .multilineTextAlignment(.center)
                .lineLimit(2)
            
            Text(subtitle)
                .font(.caption)
                .foregroundColor(color)
                .bold()
        }
        .frame(maxWidth: .infinity)
    }
}

struct AlgorithmStepView: View {
    let stepNumber: Int
    let title: String
    let description: String
    let icon: String
    let color: Color
    
    var body: some View {
        HStack(spacing: 12) {
            // Step number
            Text("\(stepNumber)")
                .font(.caption)
                .bold()
                .foregroundColor(.white)
                .frame(width: 20, height: 20)
                .background(color)
                .clipShape(Circle())
            
            // Icon
            Image(systemName: icon)
                .font(.title3)
                .foregroundColor(color)
                .frame(width: 24)
            
            // Content
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.subheadline)
                    .bold()
                
                Text(description)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
        .background(color.opacity(0.05))
        .cornerRadius(8)
    }
}

struct ProcessStep: View {
    let stepNumber: Int
    let icon: String
    let title: String
    let description: String
    let color: Color
    let visual: AnyView
    
    init<V: View>(stepNumber: Int, icon: String, title: String, description: String, color: Color, visual: V) {
        self.stepNumber = stepNumber
        self.icon = icon
        self.title = title
        self.description = description
        self.color = color
        self.visual = AnyView(visual)
    }
    
    var body: some View {
        HStack(alignment: .top, spacing: 16) {
            // Step indicator
            VStack(spacing: 8) {
                Text("\(stepNumber)")
                    .font(.headline)
                    .bold()
                    .foregroundColor(.white)
                    .frame(width: 32, height: 32)
                    .background(color)
                    .clipShape(Circle())
                
                Image(systemName: icon)
                    .font(.title3)
                    .foregroundColor(color)
            }
            .frame(width: 60)
            
            // Content
            VStack(alignment: .leading, spacing: 8) {
                Text(title)
                    .font(.headline)
                    .bold()
                
                Text(description)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                
                visual
                    .frame(height: 50)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .padding(16)
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }
}

struct ArrowDown: View {
    var body: some View {
        HStack {
            Spacer()
            Image(systemName: "arrow.down")
                .font(.title2)
                .foregroundColor(.gray)
            Spacer()
        }
    }
}

struct RoomScanVisual: View {
    var body: some View {
        HStack(spacing: 8) {
            Rectangle()
                .fill(Color.blue.opacity(0.3))
                .frame(width: 20, height: 15)
                .cornerRadius(2)
            Rectangle()
                .fill(Color.blue.opacity(0.5))
                .frame(width: 15, height: 20)
                .cornerRadius(2)
            Rectangle()
                .fill(Color.blue.opacity(0.7))
                .frame(width: 25, height: 12)
                .cornerRadius(2)
            
            Spacer()
            
            Image(systemName: "dot.radiowaves.left.and.right")
                .foregroundColor(.blue)
        }
    }
}

struct AnalysisVisual: View {
    var body: some View {
        HStack(spacing: 4) {
            ForEach(0..<6) { i in
                RoundedRectangle(cornerRadius: 2)
                    .fill(Color.purple.opacity(Double(i) * 0.15 + 0.2))
                    .frame(width: 8, height: CGFloat(10 + i * 5))
            }
            
            Spacer()
            
            Image(systemName: "brain.head.profile")
                .foregroundColor(.purple)
        }
    }
}

struct RecommendationVisual: View {
    var body: some View {
        HStack(spacing: 8) {
            Circle()
                .fill(Color.green.opacity(0.3))
                .frame(width: 12, height: 12)
            Circle()
                .fill(Color.green.opacity(0.5))
                .frame(width: 12, height: 12)
            Circle()
                .fill(Color.green)
                .frame(width: 16, height: 16)
                .overlay(
                    Image(systemName: "checkmark")
                        .font(.caption)
                        .foregroundColor(.white)
                )
            Circle()
                .fill(Color.green.opacity(0.5))
                .frame(width: 12, height: 12)
            Circle()
                .fill(Color.green.opacity(0.3))
                .frame(width: 12, height: 12)
            
            Spacer()
            
            Image(systemName: "target")
                .foregroundColor(.green)
        }
    }
}

struct AlgorithmVisualization: View {
    var body: some View {
        HStack(spacing: 16) {
            // Path visualization
            VStack(spacing: 8) {
                Image(systemName: "figure.walk")
                    .font(.title2)
                    .foregroundColor(.blue)
                
                // Dotted path
                HStack(spacing: 2) {
                    ForEach(0..<6) { _ in
                        Circle()
                            .fill(Color.blue)
                            .frame(width: 4, height: 4)
                    }
                }
                
                Text("Movement")
                    .font(.caption)
                    .foregroundColor(.blue)
            }
            .frame(maxWidth: .infinity)
            
            Image(systemName: "plus")
                .font(.title3)
                .foregroundColor(.gray)
            
            // Furniture visualization
            VStack(spacing: 8) {
                Image(systemName: "sofa.fill")
                    .font(.title2)
                    .foregroundColor(.orange)
                
                HStack(spacing: 3) {
                    Rectangle()
                        .fill(Color.orange.opacity(0.6))
                        .frame(width: 10, height: 8)
                    Rectangle()
                        .fill(Color.orange.opacity(0.8))
                        .frame(width: 8, height: 10)
                    Rectangle()
                        .fill(Color.orange)
                        .frame(width: 8, height: 8)
                }
                
                Text("Furniture")
                    .font(.caption)
                    .foregroundColor(.orange)
            }
            .frame(maxWidth: .infinity)
            
            Image(systemName: "equal")
                .font(.title3)
                .foregroundColor(.gray)
            
            // Result
            VStack(spacing: 8) {
                Image(systemName: "location.fill")
                    .font(.title2)
                    .foregroundColor(.red)
                
                Circle()
                    .fill(Color.red)
                    .frame(width: 18, height: 18)
                    .overlay(
                        Text("★")
                            .font(.caption2)
                            .foregroundColor(.white)
                    )
                
                Text("Best Spot")
                    .font(.caption)
                    .foregroundColor(.red)
            }
            .frame(maxWidth: .infinity)
        }
        .padding(16)
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }
}

struct FormulaComponent: View {
    let icon: String
    let label: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 4) {
            Image(systemName: icon)
                .font(.title3)
                .foregroundColor(color)
            Text(label)
                .font(.caption)
                .foregroundColor(color)
        }
    }
}

struct UserJourneyVisual: View {
    var body: some View {
        VStack(spacing: 16) {
            HStack(spacing: 8) {
                JourneyStep(icon: "camera.metering.matrix", title: "Scan", color: .blue)
                JourneyArrow()
                JourneyStep(icon: "list.bullet.circle", title: "Choose", color: .green)
                JourneyArrow()
                JourneyStep(icon: "target", title: "Place", color: .orange)
            }
            
            HStack(spacing: 8) {
                JourneyStep(icon: "checkmark.circle", title: "Track", color: .purple)
                JourneyArrow()
                JourneyStep(icon: "heart.text.square", title: "Measure", color: .red)
                Spacer()
                    .frame(maxWidth: .infinity)
            }
        }
        .padding(16)
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }
}

struct JourneyStep: View {
    let icon: String
    let title: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(.white)
                .frame(width: 50, height: 50)
                .background(color)
                .clipShape(Circle())
            
            Text(title)
                .font(.caption)
                .bold()
                .foregroundColor(color)
        }
    }
}

struct JourneyArrow: View {
    var body: some View {
        Image(systemName: "arrow.right")
            .font(.title3)
            .foregroundColor(.gray)
    }
}

struct ResearchPillar: View {
    let icon: String
    let title: String
    let description: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 12) {
            Image(systemName: icon)
                .font(.system(size: 28))
                .foregroundColor(color)
                .frame(width: 56, height: 56)
                .background(color.opacity(0.1))
                .clipShape(Circle())
            
            VStack(spacing: 4) {
                Text(title)
                    .font(.subheadline)
                    .bold()
                    .multilineTextAlignment(.center)
                    .lineLimit(2)
                
                Text(description)
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .lineLimit(2)
            }
        }
        .padding(12)
        .frame(maxWidth: .infinity, minHeight: 120)
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }
}

#Preview {
    NavigationView {
        AboutView()
    }
} 
