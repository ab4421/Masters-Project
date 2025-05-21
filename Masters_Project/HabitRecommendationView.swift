import SwiftUI
import RoomPlan

struct HabitRecommendationView: View {
    let habit: Habit
    let roomData: CapturedRoom?
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                // Habit Header
                HStack {
                    Image(systemName: habit.iconName)
                        .font(.system(size: 40))
                        .foregroundColor(.blue)
                        .frame(width: 60, height: 60)
                        .background(Color.blue.opacity(0.1))
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                    
                    VStack(alignment: .leading, spacing: 4) {
                        Text(habit.name)
                            .font(.title2)
                            .bold()
                        Text(habit.associatedObject)
                            .font(.subheadline)
                            .foregroundColor(.gray)
                    }
                }
                
                // Description
                Text(habit.description)
                    .font(.body)
                
                // Room Preview
                if let room = roomData {
                    Text("Room Preview")
                        .font(.headline)
                    
                    RoomPreviewView(capturedRoom: room, pathPoints: [])
                        .frame(height: 300)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                } else {
                    Text("No room scan available")
                        .foregroundColor(.gray)
                }
            }
            .padding()
        }
        .navigationTitle("Placement Guide")
        .navigationBarTitleDisplayMode(.inline)
    }
}

#Preview {
    NavigationView {
        HabitRecommendationView(
            habit: Habit.sampleHabits[0],
            roomData: nil
        )
    }
} 
