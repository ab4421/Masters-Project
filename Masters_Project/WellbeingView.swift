import SwiftUI

struct WellbeingView: View {
    @State private var answers: [Int] = Array(repeating: 0, count: 12)
    @State private var showSaveConfirmation: Bool = false
    @StateObject private var dataManager = DataManager.shared
    
    let questions = [
        "that I can effectively accomplish the things I set out to do",
        "unable to accomplish the things I am good at",
        "that I can express myself honestly",
        "restricted to express my ideas and opinions",
        "that I can maintain important relationships",
        "disconnected to people who are important for me",
        "free to be who I want to be",
        "capable to accomplish things that are important to me",
        "that I am capable to bring out the desired outcomes for the things I set out to do",
        "a sense of closeness with others",
        "that I can make my own choices freely",
        "that I can interact with people who are important to me"
    ]
    let legend = "1 = Never, 2 = Sometimes, 3 = About half the time, 4 = Most of the time, 5 = Always"
    
    // Check if data exists for today
    private var hasDataForToday: Bool {
        dataManager.getTodayEntry()?.wellbeingEntry != nil
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Static header with description, instruction, and legend
            VStack(alignment: .leading, spacing: 8) {
                Text("The Residential Eudaimonic Need Satisfaction Scale (RENSS) measures how well your psychological needs are being met at home.")
                    .font(.callout)
                    .fontWeight(.regular)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.leading)
                Divider()
                Text("Please indicate how often you feel the following when you are at home. When I am at home, I feel...")
                    .font(.callout)
                    .foregroundColor(.primary)
                Text(legend)
                    .font(.footnote)
                    .foregroundColor(.secondary)
                
                // Data Status Indicator
                if hasDataForToday {
                    HStack {
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundColor(.green)
                        Text("Wellbeing data submitted for today")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    .padding(.top, 8)
                }
            }
            .padding()
            
            // Scrollable form below
            Form {
                ForEach(0..<questions.count, id: \.self) { i in
                    VStack(alignment: .leading, spacing: 8) {
                        Text("\(i+1). \(questions[i])")
                            .font(.body)
                        Picker("Response", selection: $answers[i]) {
                            ForEach(1...5, id: \.self) { value in
                                Text("\(value)").tag(value)
                            }
                        }
                        .pickerStyle(.segmented)
                    }
                    .padding(.vertical, 4)
                }
                
                Button(action: submitWellbeingData) {
                    HStack {
                        Image(systemName: hasDataForToday ? "arrow.clockwise" : "checkmark")
                        Text(hasDataForToday ? "Update Today's Data" : "Submit")
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(answers.contains(0) ? Color.gray : Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(10)
                    .font(.headline)
                }
                .disabled(answers.contains(0))
                .frame(maxWidth: .infinity, alignment: .center)
            }
            .navigationTitle("Wellbeing Scale")
        }
        .onAppear {
            loadTodayData()
        }
        .alert("Data Saved!", isPresented: $showSaveConfirmation) {
            Button("OK") { }
        } message: {
            Text(hasDataForToday ? "Your wellbeing data has been updated for today." : "Your wellbeing data has been saved for today.")
        }
    }
    
    // MARK: - Functions
    
    private func submitWellbeingData() {
        dataManager.saveWellbeingEntry(answers: answers)
        showSaveConfirmation = true
    }
    
    private func loadTodayData() {
        if let todayEntry = dataManager.getTodayEntry(),
           let wellbeingEntry = todayEntry.wellbeingEntry {
            answers = wellbeingEntry.answers
        }
    }
}

// Preview
struct WellbeingView_Previews: PreviewProvider {
    static var previews: some View {
        WellbeingView()
    }
} 
