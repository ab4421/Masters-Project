import SwiftUI

struct HabitChecklistView: View {
    @State private var isHabitCompleted: Bool = false
    @State private var areObjectsInPlace: Bool = false
    
    // Get current date in the format: Tuesday, 20th May 2025
    private var formattedDate: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEEE, d'th' MMMM yyyy"
        let calendar = Calendar.current
        let day = calendar.component(.day, from: Date())
        let suffix: String
        switch day {
        case 1, 21, 31: suffix = "st"
        case 2, 22: suffix = "nd"
        case 3, 23: suffix = "rd"
        default: suffix = "th"
        }
        formatter.dateFormat = "EEEE, d'\(suffix)' MMMM yyyy"
        let dateString = formatter.string(from: Date()).replacingOccurrences(of: "\\(suffix)", with: suffix)
        return dateString
    }
    
    private let motivationalMessage = "Keep up the great work and stay consistent with your habit!"
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                // Date and Motivation
                VStack(alignment: .leading, spacing: 4) {
                    Text("Today is \(formattedDate)!")
                        .font(.title3)
                        .fontWeight(.semibold)
                        .foregroundColor(.black)
                    Text(motivationalMessage)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                .padding(.top)
                .padding(.horizontal)
                
                // Habit Checklist
                VStack(alignment: .leading, spacing: 16) {
                    // Habit Completion Checkbox
                    HStack(alignment: .center, spacing: 12) {
                        Image(systemName: isHabitCompleted ? "checkmark.square.fill" : "square")
                            .foregroundColor(isHabitCompleted ? .green : .gray)
                            .font(.title2)
                        VStack(alignment: .leading, spacing: 2) {
                            Text("Habit Completed")
                                .font(.body)
                                .foregroundColor(.primary)
                            Text("Did you complete your habit today?")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding()
                    .background(Color(.systemBackground))
                    .cornerRadius(10)
                    .shadow(radius: 1)
                    .onTapGesture {
                        isHabitCompleted.toggle()
                    }
                    
                    // Objects in Place Checkbox
                    HStack(alignment: .center, spacing: 12) {
                        Image(systemName: areObjectsInPlace ? "checkmark.square.fill" : "square")
                            .foregroundColor(areObjectsInPlace ? .green : .gray)
                            .font(.title2)
                        VStack(alignment: .leading, spacing: 2) {
                            Text("Objects in Place")
                                .font(.body)
                                .foregroundColor(.primary)
                            Text("Are the objects for this habit in their recommended place?")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding()
                    .background(Color(.systemBackground))
                    .cornerRadius(10)
                    .shadow(radius: 1)
                    .onTapGesture {
                        areObjectsInPlace.toggle()
                    }
                }
                .padding(.horizontal)
                
                Spacer(minLength: 0)
            }
            .padding(.bottom)
        }
        .navigationTitle("Habit Checklist")
    }
}

#Preview {
    NavigationView {
        HabitChecklistView()
    }
} 