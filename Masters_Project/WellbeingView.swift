import SwiftUI

struct WellbeingView: View {
    @State private var answers: [Int] = Array(repeating: 0, count: 12)
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

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Description outside the form
            Text("This is the Residential Eudaimonic Need Satisfaction Scale (RENSS), which measures how well your psychological needs are being met at home.")
                .font(.callout)
                .fontWeight(.regular)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.leading)
                .padding([.horizontal, .top])
                .padding(.bottom, 8)

            Form {
                // Instruction and legend at the top of the form, no extra section
                Text("Please indicate how often you feel the following when you are at home. When I am at home, I feel...")
                    .font(.callout)
                    .foregroundColor(.primary)
                    .padding(.bottom, 0)
                Text(legend)
                    .font(.footnote)
                    .foregroundColor(.secondary)
                    .padding(.bottom, 4)

                ForEach(0..<questions.count, id: \ .self) { i in
                    VStack(alignment: .leading, spacing: 8) {
                        Text("\(i+1). \(questions[i])")
                            .font(.body)
                        Picker("Response", selection: $answers[i]) {
                            ForEach(1...5, id: \ .self) { value in
                                Text("\(value)").tag(value)
                            }
                        }
                        .pickerStyle(.segmented)
                    }
                    .padding(.vertical, 4)
                }
                Button("Submit") {
                    // Handle submission logic here
                }
                .disabled(answers.contains(0))
                .frame(maxWidth: .infinity, alignment: .center)
            }
            .navigationTitle("RENSS")
        }
    }
}

// Preview
struct WellbeingView_Previews: PreviewProvider {
    static var previews: some View {
        WellbeingView()
    }
} 
