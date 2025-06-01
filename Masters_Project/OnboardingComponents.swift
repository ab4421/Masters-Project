import SwiftUI

// MARK: - Step 1: Welcome & Core Concept

struct WelcomeVisual: View {
    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: "house.and.flag.fill")
                .font(.system(size: 80))
                .foregroundColor(.blue)
            
            Text("Habit Home")
                .font(.title2)
                .bold()
                .foregroundColor(.primary)
        }
    }
}

struct CoreConceptFormula: View {
    var body: some View {
        VStack(spacing: 20) {
            HStack(spacing: 16) {
                FormulaElement(
                    icon: "eye.fill",
                    label: "Visual Cues",
                    color: .green
                )
                
                Text("+")
                    .font(.title)
                    .foregroundColor(.gray)
                
                FormulaElement(
                    icon: "speedometer",
                    label: "Low Friction",
                    color: .orange
                )
                
                Text("=")
                    .font(.title)
                    .foregroundColor(.gray)
                
                FormulaElement(
                    icon: "checkmark.circle.fill",
                    label: "Better Habits",
                    color: .blue
                )
            }
            
            Text("Environmental psychology in action!")
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }
}

struct FormulaElement: View {
    let icon: String
    let label: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.system(size: 24))
                .foregroundColor(color)
                .frame(width: 50, height: 50)
                .background(color.opacity(0.1))
                .clipShape(Circle())
            
            Text(label)
                .font(.caption)
                .bold()
                .foregroundColor(.primary)
                .multilineTextAlignment(.center)
        }
    }
}

// MARK: - Step 2: Room Scanning

struct RoomScanningVisual: View {
    let isSupported: Bool
    @State private var isAnimating = false
    
    var body: some View {
        VStack(spacing: 16) {
            ZStack {
                // Room outline
                RoundedRectangle(cornerRadius: 8)
                    .stroke(Color.blue.opacity(0.3), lineWidth: 2)
                    .frame(width: 120, height: 80)
                
                // Furniture items
                HStack(spacing: 8) {
                    Rectangle()
                        .fill(Color.blue.opacity(0.5))
                        .frame(width: 20, height: 15)
                        .cornerRadius(2)
                    
                    Rectangle()
                        .fill(Color.blue.opacity(0.7))
                        .frame(width: 15, height: 20)
                        .cornerRadius(2)
                }
                
                if isSupported {
                    // Scanning animation
                    Circle()
                        .stroke(Color.blue, lineWidth: 2)
                        .frame(width: isAnimating ? 100 : 20, height: isAnimating ? 100 : 20)
                        .opacity(isAnimating ? 0 : 1)
                        .animation(.easeOut(duration: 2).repeatForever(autoreverses: false), value: isAnimating)
                }
            }
            
            HStack(spacing: 8) {
                Image(systemName: isSupported ? "camera.metering.matrix" : "square.and.arrow.down")
                    .foregroundColor(isSupported ? .blue : .orange)
                Text(isSupported ? "LiDAR Scanning" : "Import Required")
                    .font(.caption)
                    .foregroundColor(isSupported ? .blue : .orange)
            }
        }
        .frame(maxWidth: .infinity)
        .onAppear {
            if isSupported {
                isAnimating = true
            }
        }
    }
}

// MARK: - Step 3: Habit Selection

struct HabitSelectionVisual: View {
    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: "target")
                .font(.system(size: 60))
                .foregroundColor(.green)
            
            Text("Choose Your Focus")
                .font(.headline)
                .foregroundColor(.primary)
        }
    }
}

struct HabitGrid: View {
    let habits = [
        ("bed.double.fill", "Sleep"),
        ("fork.knife", "Diet"),
        ("figure.run", "Activity")
    ]
    
    var body: some View {
        VStack(spacing: 16) {
            Text("Focus on the 3 primary areas for wellbeing: Sleep, Diet, and Activity.")
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
            
            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 3), spacing: 16) {
                ForEach(habits, id: \.0) { habit in
                    VStack(spacing: 8) {
                        Image(systemName: habit.0)
                            .font(.title2)
                            .foregroundColor(.blue)
                            .frame(width: 50, height: 50)
                            .background(Color.blue.opacity(0.1))
                            .clipShape(Circle())
                        
                        Text(habit.1)
                            .font(.caption)
                            .bold()
                            .foregroundColor(.primary)
                    }
                }
            }
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }
}

// MARK: - Step 4: AI Analysis

struct AIAnalysisVisual: View {
    @State private var isProcessing = false
    
    var body: some View {
        VStack(spacing: 20) {
            // Main process flow
            HStack(spacing: 20) {
                // Input: Room + Path
                VStack(spacing: 8) {
                    Image(systemName: "house.fill")
                        .font(.title)
                        .foregroundColor(.blue)
                    Text("Room Data")
                        .font(.caption)
                        .foregroundColor(.blue)
                }
                
                Image(systemName: "arrow.right")
                    .foregroundColor(.gray)
                
                // Algorithm Brain
                VStack(spacing: 8) {
                    Image(systemName: "brain.head.profile")
                        .font(.title)
                        .foregroundColor(.purple)
                        .scaleEffect(isProcessing ? 1.2 : 1.0)
                        .animation(.easeInOut(duration: 1).repeatForever(autoreverses: true), value: isProcessing)
                    Text("Algorithm")
                        .font(.caption)
                        .foregroundColor(.purple)
                }
                
                Image(systemName: "arrow.right")
                    .foregroundColor(.gray)
                
                // Output: Recommendation
                VStack(spacing: 8) {
                    Image(systemName: "location.fill")
                        .font(.title)
                        .foregroundColor(.red)
                    Text("Best Surface")
                        .font(.caption)
                        .foregroundColor(.red)
                }
            }
            
            // Recommendation equation
            VStack(spacing: 12) {
                Text("Recommendation Formula")
                    .font(.subheadline)
                    .bold()
                    .foregroundColor(.primary)
                
                VStack(spacing: 8) {
                    Text("Score = (Path Distance × Path Weight) +")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    Text("(Furniture Distance × Furniture Weight)")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    Text("Lower score = Better placement")
                        .font(.caption)
                        .bold()
                        .foregroundColor(.blue)
                        .padding(.top, 4)
                }
            }
            .padding()
            .background(Color(.systemGray6))
            .cornerRadius(8)
        }
        .frame(maxWidth: .infinity)
        .onAppear {
            isProcessing = true
        }
    }
}

// MARK: - Step 5: Customization

struct CustomizationVisual: View {
    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: "slider.horizontal.3")
                .font(.system(size: 60))
                .foregroundColor(.orange)
            
            Text("Fine-tune Algorithm")
                .font(.headline)
                .foregroundColor(.primary)
        }
    }
}

struct CustomizationDemo: View {
    @State private var biasPosition: Double = 7.0
    
    private var importanceText: String {
        if biasPosition == 5 {
            return "Balanced"
        } else if biasPosition < 5 {
            let percentage = Int((5 - biasPosition) / 5 * 100)
            return "\(percentage)% Camera Path"
        } else {
            let percentage = Int((biasPosition - 5) / 5 * 100)
            return "\(percentage)% Furniture"
        }
    }
    
    var body: some View {
        VStack(spacing: 16) {
            Text("You'll be able to adjust a single importance slider and select different furniture types to optimize the algorithm for your preferences.")
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
            
            VStack(spacing: 12) {
                HStack {
                    VStack(alignment: .leading) {
                        Image(systemName: "camera")
                            .font(.title3)
                        Text("Camera Path")
                            .font(.callout)
                            .foregroundColor(.secondary)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    
                    Spacer()
                    
                    VStack(alignment: .trailing) {
                        Image(systemName: "sofa")
                            .font(.title3)
                        Text("Furniture")
                            .font(.callout)
                            .foregroundColor(.secondary)
                    }
                    .frame(maxWidth: .infinity, alignment: .trailing)
                }
                
                Slider(value: $biasPosition, in: 0...10, step: 1)
                    .accentColor(.blue)
                
                Text("Importance: \(importanceText)")
                    .font(.caption)
                    .foregroundColor(.blue)
            }
            
            HStack(spacing: 12) {
                Image(systemName: "list.bullet.circle")
                    .foregroundColor(.orange)
                Text("Select specific furniture pieces")
                    .font(.caption)
                    .foregroundColor(.secondary)
                Spacer()
            }
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }
}

// MARK: - Step 6: Research

struct ResearchVisual: View {
    var body: some View {
        VStack(spacing: 16) {
            HStack(spacing: 20) {
                Image(systemName: "checkmark.square.fill")
                    .font(.system(size: 40))
                    .foregroundColor(.green)
                
                Image(systemName: "heart.text.square.fill")
                    .font(.system(size: 40))
                    .foregroundColor(.red)
            }
            
            Text("Daily Check-ins")
                .font(.headline)
                .foregroundColor(.primary)
        }
    }
}

struct ResearchDetails: View {
    var body: some View {
        VStack(spacing: 16) {
            VStack(spacing: 8) {
                HStack {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(.green)
                    Text("Habit Checklist")
                        .font(.subheadline)
                        .bold()
                    Spacer()
                }
                Text("Did you complete your habit? Are objects in place? (30 seconds)")
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
            
            VStack(spacing: 8) {
                HStack {
                    Image(systemName: "heart.fill")
                        .foregroundColor(.red)
                    Text("RENSS Wellbeing Scale")
                        .font(.subheadline)
                        .bold()
                    Spacer()
                }
                Text("12 questions about how your home supports your psychological needs")
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }
}

// MARK: - Step 7: Notifications

struct NotificationVisual: View {
    @State private var showNotifications = false
    
    var body: some View {
        VStack(spacing: 16) {
            ZStack {
                Image(systemName: "iphone")
                    .font(.system(size: 60))
                    .foregroundColor(.blue)
                
                if showNotifications {
                    VStack {
                        ForEach(0..<3) { index in
                            Circle()
                                .fill(Color.red)
                                .frame(width: 8, height: 8)
                                .offset(x: 25, y: -30 + CGFloat(index * 10))
                                .opacity(0.8)
                        }
                    }
                    .animation(.easeInOut(duration: 2).repeatForever(), value: showNotifications)
                }
            }
            
            Text("Smart Reminders")
                .font(.headline)
                .foregroundColor(.primary)
        }
        .onAppear {
            showNotifications = true
        }
    }
}

struct NotificationSchedule: View {
    var body: some View {
        VStack(spacing: 12) {
            HStack {
                Image(systemName: "clock")
                    .foregroundColor(.blue)
                Text("6:00 PM - First reminder")
                    .font(.subheadline)
                Spacer()
            }
            
            HStack {
                Image(systemName: "clock")
                    .foregroundColor(.blue)
                Text("8:00 PM - Second reminder")
                    .font(.subheadline)
                Spacer()
            }
            
            HStack {
                Image(systemName: "clock")
                    .foregroundColor(.blue)
                Text("10:00 PM - Final reminder")
                    .font(.subheadline)
                Spacer()
            }
            
            Text("💡 Notifications stop automatically when both check-ins are complete")
                .font(.caption)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.top, 8)
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }
}

// MARK: - Step 8: Support

struct SupportVisual: View {
    var body: some View {
        VStack(spacing: 16) {
            HStack(spacing: 20) {
                Image(systemName: "envelope.fill")
                    .font(.system(size: 40))
                    .foregroundColor(.blue)
                
                Image(systemName: "graduationcap.fill")
                    .font(.system(size: 40))
                    .foregroundColor(.purple)
            }
            
            Text("Research & Support")
                .font(.headline)
                .foregroundColor(.primary)
        }
    }
}

struct ContactInfo: View {
    var body: some View {
        VStack(spacing: 16) {
            VStack(spacing: 8) {
                HStack {
                    Image(systemName: "person.fill")
                        .foregroundColor(.blue)
                    Text("Arnav Bhatia")
                        .font(.subheadline)
                        .bold()
                    Spacer()
                }
                HStack {
                    Image(systemName: "envelope.fill")
                        .foregroundColor(.blue)
                    Text("arnav.bhatia21@imperial.ac.uk")
                        .font(.caption)
                        .foregroundColor(.blue)
                    Spacer()
                }
            }
            
            VStack(spacing: 8) {
                HStack {
                    Image(systemName: "info.circle.fill")
                        .foregroundColor(.purple)
                    Text("Imperial College Research")
                        .font(.subheadline)
                        .bold()
                    Spacer()
                }
                Text("Contributing to technology-supported healthy living research")
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }
}

// MARK: - Step 9: Ready to Start

struct ReadyToStartVisual: View {
    @State private var isAnimating = false
    
    var body: some View {
        VStack(spacing: 16) {
            ZStack {
                Circle()
                    .fill(LinearGradient(
                        gradient: Gradient(colors: [Color.green, Color.blue]),
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ))
                    .frame(width: 80, height: 80)
                    .scaleEffect(isAnimating ? 1.2 : 1.0)
                    .animation(.easeInOut(duration: 2).repeatForever(autoreverses: true), value: isAnimating)
                
                Image(systemName: "checkmark")
                    .font(.system(size: 40, weight: .bold))
                    .foregroundColor(.white)
            }
            
            Text("All Set!")
                .font(.title)
                .bold()
                .foregroundColor(.primary)
        }
        .onAppear {
            isAnimating = true
        }
    }
}

struct AppPreview: View {
    var body: some View {
        HStack(spacing: 16) {
            VStack(spacing: 8) {
                Image(systemName: "camera.metering.matrix")
                    .font(.title2)
                    .foregroundColor(.blue)
                Text("Scan")
                    .font(.caption)
                    .bold()
            }
            
            Image(systemName: "arrow.right")
                .foregroundColor(.gray)
            
            VStack(spacing: 8) {
                Image(systemName: "lightbulb.fill")
                    .font(.title2)
                    .foregroundColor(.orange)
                Text("Recommend")
                    .font(.caption)
                    .bold()
            }
            
            Image(systemName: "arrow.right")
                .foregroundColor(.gray)
            
            VStack(spacing: 8) {
                Image(systemName: "checkmark.circle.fill")
                    .font(.title2)
                    .foregroundColor(.green)
                Text("Track")
                    .font(.caption)
                    .bold()
            }
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }
} 