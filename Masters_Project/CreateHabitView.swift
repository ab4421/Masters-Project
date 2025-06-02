import SwiftUI
import RoomPlan

struct CreateHabitView: View {
    let roomData: CapturedRoom?
    let editingHabit: Habit? // nil for creating new habit
    
    @Environment(\.dismiss) private var dismiss
    @ObservedObject private var customHabitManager = CustomHabitManager.shared
    
    // Form state
    @State private var selectedIcon: String = "star.fill"
    @State private var habitName: String = ""
    @State private var habitDescription: String = ""
    @State private var associatedObject: String = ""
    @State private var selectedFurnitureTypes: Set<CapturedRoom.Object.Category> = []
    @State private var importanceValue: Double = 7.0
    
    // UI state
    @State private var showingIconPicker = false
    @State private var showingError = false
    @State private var errorMessage = ""
    @State private var showingHelpGuide = false
    
    // Available furniture types from room data
    private var availableFurnitureTypes: [CapturedRoom.Object.Category] {
        guard let roomData = roomData else { return [] }
        return Array(Set(roomData.objects.map { $0.category })).sorted { String(describing: $0) < String(describing: $1) }
    }
    
    // Common SF Symbol icons for habits
    private let habitIcons = [
        "star.fill", "heart.fill", "leaf.fill", "drop.fill", "flame.fill",
        "moon.fill", "sun.max.fill", "figure.walk", "figure.run", "dumbbell.fill",
        "book.fill", "cup.and.saucer.fill", "fork.knife", "bed.double.fill",
        "tv.fill", "music.note", "camera.fill", "paintbrush.fill", "pencil",
        "checkmark.circle.fill", "target", "timer", "bell.fill", "house.fill",
        "tray.fill", "bag.fill", "cart.fill", "gamecontroller.fill"
    ]
    
    var body: some View {
        NavigationView {
            Form {
                // Help Section
                Section {
                    Button(action: {
                        showingHelpGuide = true
                    }) {
                        HStack {
                            Image(systemName: "questionmark.circle.fill")
                                .font(.title3)
                                .foregroundColor(.blue)
                            
                            Text("How to Create Effective Habits")
                                .foregroundColor(.blue)
                            
                            Spacer()
                            
                            Image(systemName: "chevron.right")
                                .font(.caption)
                                .foregroundColor(.gray)
                        }
                    }
                }
                
                // Icon Selection Section
                Section("Icon") {
                    HStack {
                        Image(systemName: selectedIcon)
                            .font(.title2)
                            .foregroundColor(.blue)
                            .frame(width: 30)
                        
                        Button("Choose Icon") {
                            showingIconPicker = true
                        }
                        .foregroundColor(.blue)
                        
                        Spacer()
                    }
                }
                
                // Basic Information Section
                Section("Habit Details") {
                    TextField("Habit Name", text: $habitName)
                    TextField("Associated Object", text: $associatedObject)
                        .help("What physical item is associated with this habit?")
                }
                
                // Description Section
                Section("Description") {
                    TextField("Description", text: $habitDescription, axis: .vertical)
                        .lineLimit(3...6)
                }
                
                // Furniture Selection Section
                Section("Associated Furniture") {
                    if availableFurnitureTypes.isEmpty {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("No furniture detected in room scan")
                                .foregroundColor(.gray)
                                .italic()
                            
                            Text("Please scan a room first to create custom habits with furniture associations.")
                                .font(.caption)
                                .foregroundColor(.orange)
                        }
                    } else {
                        ForEach(availableFurnitureTypes, id: \.self) { furnitureType in
                            HStack {
                                Image(systemName: selectedFurnitureTypes.contains(furnitureType) ? "checkmark.circle.fill" : "circle")
                                    .foregroundColor(selectedFurnitureTypes.contains(furnitureType) ? .blue : .gray)
                                
                                Text(String(describing: furnitureType).capitalized)
                                
                                Spacer()
                            }
                            .contentShape(Rectangle())
                            .onTapGesture {
                                toggleFurnitureSelection(furnitureType)
                            }
                        }
                        
                        if selectedFurnitureTypes.isEmpty {
                            Text("Please select at least one furniture type")
                                .foregroundColor(.red)
                                .font(.caption)
                        }
                    }
                }
                
                // Importance Section
                Section("Default Importance") {
                    VStack(alignment: .leading) {
                        HStack {
                            Text("Importance Level")
                            Spacer()
                            Text("\(Int(importanceValue))")
                                .foregroundColor(.blue)
                        }
                        
                        Slider(value: $importanceValue, in: 1...10, step: 1)
                            .accentColor(.blue)
                        
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
                    }
                }
            }
            .navigationTitle(editingHabit == nil ? "Create Habit" : "Edit Habit")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(editingHabit == nil ? "Create" : "Save") {
                        saveHabit()
                    }
                    .disabled(!isFormValid)
                }
            }
            .sheet(isPresented: $showingIconPicker) {
                IconPickerView(selectedIcon: $selectedIcon)
            }
            .sheet(isPresented: $showingHelpGuide) {
                HabitCreationGuideView()
            }
            .alert("Error", isPresented: $showingError) {
                Button("OK") { }
            } message: {
                Text(errorMessage)
            }
        }
        .onAppear {
            setupFormForEditing()
        }
    }
    
    // MARK: - Form Validation
    
    private var isFormValid: Bool {
        !habitName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty &&
        !associatedObject.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty &&
        !habitDescription.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty &&
        !selectedFurnitureTypes.isEmpty &&
        !availableFurnitureTypes.isEmpty // Ensure room data is available
    }
    
    // MARK: - Helper Methods
    
    private func toggleFurnitureSelection(_ furnitureType: CapturedRoom.Object.Category) {
        if selectedFurnitureTypes.contains(furnitureType) {
            selectedFurnitureTypes.remove(furnitureType)
        } else {
            selectedFurnitureTypes.insert(furnitureType)
        }
    }
    
    private func setupFormForEditing() {
        guard let habit = editingHabit else { return }
        
        selectedIcon = habit.iconName
        habitName = habit.name
        habitDescription = habit.description
        associatedObject = habit.associatedObject
        selectedFurnitureTypes = Set(habit.associatedFurnitureTypes)
        
        // Try to get saved importance value from configurations
        if let configuration = HabitConfigurationManager.shared.getConfiguration(for: habit.id) {
            importanceValue = configuration.biasPosition
        }
    }
    
    private func saveHabit() {
        let trimmedName = habitName.trimmingCharacters(in: .whitespacesAndNewlines)
        let trimmedObject = associatedObject.trimmingCharacters(in: .whitespacesAndNewlines)
        let trimmedDescription = habitDescription.trimmingCharacters(in: .whitespacesAndNewlines)
        
        let habit = Habit(
            id: editingHabit?.id ?? UUID(),
            name: trimmedName,
            description: trimmedDescription,
            category: .custom,
            associatedObject: trimmedObject,
            iconName: selectedIcon,
            associatedFurnitureTypes: Array(selectedFurnitureTypes),
            associatedFurnitureIndices: [] // Will be populated when habit is used
        )
        
        if editingHabit == nil {
            // Creating new habit
            customHabitManager.addHabit(habit)
        } else {
            // Updating existing habit
            customHabitManager.updateHabit(habit)
        }
        
        // Save importance configuration
        HabitConfigurationManager.shared.saveConfiguration(for: habit, biasPosition: importanceValue)
        
        dismiss()
    }
}

// MARK: - Icon Picker View

struct IconPickerView: View {
    @Binding var selectedIcon: String
    @Environment(\.dismiss) private var dismiss
    
    private let habitIcons = [
        "star.fill", "heart.fill", "leaf.fill", "drop.fill", "flame.fill",
        "moon.fill", "sun.max.fill", "figure.walk", "figure.run", "dumbbell.fill",
        "book.fill", "cup.and.saucer.fill", "fork.knife", "bed.double.fill",
        "tv.fill", "music.note", "camera.fill", "paintbrush.fill", "pencil",
        "checkmark.circle.fill", "target", "timer", "bell.fill", "house.fill",
        "tray.fill", "bag.fill", "cart.fill", "gamecontroller.fill"
    ]
    
    private let columns = Array(repeating: GridItem(.flexible()), count: 6)
    
    var body: some View {
        NavigationView {
            ScrollView {
                LazyVGrid(columns: columns, spacing: 20) {
                    ForEach(habitIcons, id: \.self) { iconName in
                        Button(action: {
                            selectedIcon = iconName
                            dismiss()
                        }) {
                            Image(systemName: iconName)
                                .font(.title2)
                                .foregroundColor(selectedIcon == iconName ? .white : .blue)
                                .frame(width: 44, height: 44)
                                .background(
                                    Circle()
                                        .fill(selectedIcon == iconName ? Color.blue : Color.gray.opacity(0.1))
                                )
                        }
                        .buttonStyle(PlainButtonStyle())
                    }
                }
                .padding()
            }
            .navigationTitle("Choose Icon")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
    }
}

// MARK: - Habit Creation Guide View

struct HabitCreationGuideView: View {
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    // Header
                    VStack(alignment: .leading, spacing: 8) {
                        HStack {
                            Image(systemName: "lightbulb.fill")
                                .font(.title2)
                                .foregroundColor(.yellow)
                            Text("Creating Effective Habits")
                                .font(.title2)
                                .bold()
                        }
                        
                        Text("Follow these guidelines to create habits that work best with your space and movement patterns.")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                    
                    // Guideline 1
                    VStack(alignment: .leading, spacing: 12) {
                        HStack {
                            Image(systemName: "1.circle.fill")
                                .font(.title3)
                                .foregroundColor(.blue)
                            Text("Choose Table-Friendly Objects")
                                .font(.headline)
                        }
                        
                        Text("Select habits that involve objects you can place on table surfaces, like:")
                            .foregroundColor(.secondary)
                        
                        VStack(alignment: .leading, spacing: 4) {
                            HStack {
                                Image(systemName: "checkmark")
                                    .foregroundColor(.green)
                                    .font(.caption)
                                Text("Books, water bottles, vitamins")
                                    .font(.subheadline)
                            }
                            HStack {
                                Image(systemName: "checkmark")
                                    .foregroundColor(.green)
                                    .font(.caption)
                                Text("Keys, wallet, phone charger")
                                    .font(.subheadline)
                            }
                            HStack {
                                Image(systemName: "checkmark")
                                    .foregroundColor(.green)
                                    .font(.caption)
                                Text("Notebooks, pens, reading glasses")
                                    .font(.subheadline)
                            }
                        }
                        
                    }
                    .padding()
                    .background(Color.blue.opacity(0.05))
                    .cornerRadius(12)
                    
                    // Guideline 2
                    VStack(alignment: .leading, spacing: 12) {
                        HStack {
                            Image(systemName: "2.circle.fill")
                                .font(.title3)
                                .foregroundColor(.blue)
                            Text("Select 1-3 Furniture Types")
                                .font(.headline)
                        }
                        
                        Text("Choose furniture that's relevant to your habit. More isn't always better - focus on the most important pieces.")
                            .foregroundColor(.secondary)
                        
                        VStack(alignment: .listRowSeparatorLeading) {
        
                            HStack {
                                Image(systemName: "bed.double")
                                    .foregroundColor(.purple)
                                    .font(.caption)
                                Text("Bedtime routines → Bed")
                                    .font(.subheadline)
                            }
                            HStack {
                                Image(systemName: "fork.knife")
                                    .foregroundColor(.orange)
                                    .font(.caption)
                                    .offset(x:-3)
                                Text("Meal prep → Oven + Stove")
                                    .font(.subheadline)
                            }
                            HStack {
                                Image(systemName: "book")
                                    .foregroundColor(.brown)
                                    .font(.caption)
                                Text("Reading → Sofa + Chair")
                                    .font(.subheadline)
                            }
                        }
                        
                    }
                    .padding()
                    .background(Color.blue.opacity(0.05))
                    .cornerRadius(12)
                    
                    // Guideline 3
                    VStack(alignment: .leading, spacing: 12) {
                        HStack {
                            Image(systemName: "3.circle.fill")
                                .font(.title3)
                                .foregroundColor(.blue)
                            Text("Set Your Movement Preference")
                                .font(.headline)
                        }
                        
                        Text("The importance slider helps the app understand how you prefer to perform this habit:")
                            .foregroundColor(.secondary)
                        
                        VStack(alignment: .leading, spacing: 8) {
                            HStack {
                                Image(systemName: "camera")
                                    .foregroundColor(.blue)
                                    .font(.caption)
                                VStack(alignment: .leading, spacing: 2) {
                                    Text("Camera Path (Left)")
                                        .font(.subheadline)
                                        .bold()
                                    Text("For habits you do while moving around or passing by")
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                }
                            }
                            
                            HStack {
                                Image(systemName: "sofa")
                                    .foregroundColor(.blue)
                                    .font(.caption)
                                VStack(alignment: .leading, spacing: 2) {
                                    Text("Furniture (Right)")
                                        .font(.subheadline)
                                        .bold()
                                    Text("For habits you do while seated or stationary near furniture")
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                }
                            }
                        }
                        
                    }
                    .padding()
                    .background(Color.blue.opacity(0.05))
                    .cornerRadius(12)
                }
                .padding()
            }
            .navigationTitle("Habit Creation Guide")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
    }
}

#Preview {
    CreateHabitView(roomData: nil, editingHabit: nil)
} 
