import SwiftUI

struct DataExportView: View {
    @StateObject private var dataManager = DataManager.shared
    @State private var showShareSheet = false
    @State private var csvContent = ""
    @State private var csvFileURL: URL?
    
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            // Header
            VStack(alignment: .leading, spacing: 8) {
                Text("Data Export")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                
                Text("Export your habit and wellbeing data to share with researchers.")
                    .font(.body)
                    .foregroundColor(.secondary)
            }
            
            // Data Summary
            VStack(alignment: .leading, spacing: 12) {
                Text("Data Summary")
                    .font(.headline)
                
                HStack {
                    VStack(alignment: .leading) {
                        Text("User ID:")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        Text(dataManager.userData.userID)
                            .font(.system(.body, design: .monospaced))
                    }
                    Spacer()
                }
                
                HStack {
                    VStack(alignment: .leading) {
                        Text("Total Days:")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        Text("\(dataManager.userData.dailyEntries.count)")
                            .font(.title2)
                            .fontWeight(.semibold)
                    }
                    
                    Spacer()
                    
                    VStack(alignment: .leading) {
                        Text("Habit Entries:")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        Text("\(habitEntryCount)")
                            .font(.title2)
                            .fontWeight(.semibold)
                    }
                    
                    Spacer()
                    
                    VStack(alignment: .leading) {
                        Text("Wellbeing Entries:")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        Text("\(wellbeingEntryCount)")
                            .font(.title2)
                            .fontWeight(.semibold)
                    }
                }
                .padding()
                .background(Color(.systemGray6))
                .cornerRadius(10)
            }
            
            // Export Button
            Button(action: exportData) {
                HStack {
                    Image(systemName: "square.and.arrow.up")
                    Text("Export CSV Data")
                }
                .frame(maxWidth: .infinity)
                .padding()
                .background(dataManager.userData.dailyEntries.isEmpty ? Color.gray : Color.blue)
                .foregroundColor(.white)
                .cornerRadius(10)
                .font(.headline)
            }
            .disabled(dataManager.userData.dailyEntries.isEmpty)
            
            // CSV Preview
            if !csvContent.isEmpty {
                VStack(alignment: .leading, spacing: 8) {
                    Text("CSV Preview")
                        .font(.headline)
                    
                    ScrollView {
                        Text(csvContent)
                            .font(.system(.caption, design: .monospaced))
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding()
                            .background(Color(.systemGray6))
                            .cornerRadius(8)
                    }
                    .frame(maxHeight: 200)
                }
            }
            
            Spacer()
        }
        .padding()
        .sheet(isPresented: $showShareSheet) {
            if let csvFileURL = csvFileURL {
                ShareSheet(activityItems: [csvFileURL])
            } else {
                ShareSheet(activityItems: [csvContent])
            }
        }
        .onAppear {
            csvContent = dataManager.generateCSV()
        }
    }
    
    // MARK: - Computed Properties
    
    private var habitEntryCount: Int {
        dataManager.userData.dailyEntries.values.compactMap { $0.habitEntry }.count
    }
    
    private var wellbeingEntryCount: Int {
        dataManager.userData.dailyEntries.values.compactMap { $0.wellbeingEntry }.count
    }
    
    // MARK: - Functions
    
    private func exportData() {
        csvContent = dataManager.generateCSV()
        
        // Create temporary file with custom filename
        let tempDirectory = FileManager.default.temporaryDirectory
        let fileName = "\(dataManager.userData.userID) - data.csv"
        let tempFileURL = tempDirectory.appendingPathComponent(fileName)
        
        do {
            try csvContent.write(to: tempFileURL, atomically: true, encoding: .utf8)
            csvFileURL = tempFileURL
        } catch {
            print("Error creating temporary file: \(error)")
            csvFileURL = nil
        }
        
        showShareSheet = true
    }
}

// MARK: - Share Sheet

struct ShareSheet: UIViewControllerRepresentable {
    let activityItems: [Any]
    
    func makeUIViewController(context: Context) -> UIActivityViewController {
        UIActivityViewController(activityItems: activityItems, applicationActivities: nil)
    }
    
    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
}

// MARK: - Preview

struct DataExportView_Previews: PreviewProvider {
    static var previews: some View {
        DataExportView()
    }
} 