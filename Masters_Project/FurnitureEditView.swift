import SwiftUI
import RoomPlan
import simd
import SceneKit

struct FurnitureEditView: View {
    @Binding var isPresented: Bool
    @Binding var associatedFurnitureTypes: [CapturedRoom.Object.Category]
    @Binding var associatedFurnitureIndices: [Int]
    let allDetectedObjects: [CapturedRoom.Object]
    let capturedRoom: CapturedRoom?
    let pathPoints: [PathPoint]
    let habit: Habit

    @State private var selectedIndices: Set<Int>
    @State private var highlightedObjectIndex: Int? // For temporary "locate" highlighting
    @State private var showingPreview: Bool = false
    
    private let configurationManager = HabitConfigurationManager.shared

    init(isPresented: Binding<Bool>, associatedFurnitureTypes: Binding<[CapturedRoom.Object.Category]>, associatedFurnitureIndices: Binding<[Int]>, allDetectedObjects: [CapturedRoom.Object], capturedRoom: CapturedRoom?, pathPoints: [PathPoint], habit: Habit) {
        self._isPresented = isPresented
        self._associatedFurnitureTypes = associatedFurnitureTypes
        self._associatedFurnitureIndices = associatedFurnitureIndices
        self.allDetectedObjects = allDetectedObjects
        self.capturedRoom = capturedRoom
        self.pathPoints = pathPoints
        self.habit = habit
        
        let matchingIndices = allDetectedObjects.enumerated().compactMap { index, object in
            associatedFurnitureTypes.wrappedValue.contains(object.category) ? index : nil
        }
        self._selectedIndices = State(initialValue: Set(matchingIndices))
    }

    private var groupedObjects: [(category: CapturedRoom.Object.Category, objects: [(index: Int, object: CapturedRoom.Object)])] {
        let grouped = Dictionary(grouping: allDetectedObjects.enumerated()) { _, object in
            object.category
        }
        
        return grouped.map { category, indexedObjects in
            (category: category, objects: indexedObjects.map { (index: $0.offset, object: $0.element) })
        }.sorted { String(describing: $0.category) < String(describing: $1.category) }
    }

    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // 3D Room Preview Section
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Text("Room Preview")
                            .font(.headline)
                            .padding(.horizontal)
                        Spacer()
                        Button(action: {
                            withAnimation(.easeInOut(duration: 0.3)) {
                                showingPreview.toggle()
                            }
                        }) {
                            Image(systemName: showingPreview ? "chevron.up" : "chevron.down")
                                .foregroundColor(.blue)
                                .padding(.trailing)
                        }
                        .disabled(capturedRoom == nil)
                    }
                    .padding(.top)
                    
                    if showingPreview {
                        if let room = capturedRoom {
                            RoomPreviewView(
                                capturedRoom: room,
                                pathPoints: pathPoints,
                                visualElements: [],
                                recommendedObjectIndex: highlightedObjectIndex,
                                candidateObjectIndices: Array(selectedIndices),
                                candidateColor: .blue,
                                recommendedColor: .yellow
                            )
                            .frame(height: 250)
                            .background(Color(.systemGray6))
                            .cornerRadius(12)
                            .padding(.horizontal)
                            .transition(.opacity.combined(with: .scale(scale: 0.95)))
                            
                            // Legend
                            HStack(spacing: 20) {
                                HStack(spacing: 4) {
                                    RoundedRectangle(cornerRadius: 4)
                                        .fill(Color.blue.opacity(0.7))
                                        .frame(width: 16, height: 16)
                                    Text("Selected")
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                }
                                
                                if highlightedObjectIndex != nil {
                                    HStack(spacing: 4) {
                                        RoundedRectangle(cornerRadius: 4)
                                            .fill(Color.yellow.opacity(0.7))
                                            .frame(width: 16, height: 16)
                                        Text("Located")
                                            .font(.caption)
                                            .foregroundColor(.secondary)
                                    }
                                }
                                
                                Spacer()
                            }
                            .padding(.horizontal)
                            .padding(.bottom, 8)
                        } else {
                            Text("Room preview not available")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                                .frame(height: 100)
                                .frame(maxWidth: .infinity)
                                .background(Color(.systemGray6))
                                .cornerRadius(12)
                                .padding(.horizontal)
                        }
                    }
                }
                .background(Color(.systemBackground))
                
                Divider()
                
                // Furniture List Section
                List {
                    ForEach(groupedObjects, id: \.category) { categoryGroup in
                        Section(header: Text(String(describing: categoryGroup.category).capitalized)) {
                            ForEach(categoryGroup.objects, id: \.index) { indexedObject in
                                HStack {
                                    // Main selection area - entire row tappable
                                    HStack {
                                        let displayName = categoryGroup.objects.count > 1 ? 
                                            "\(String(describing: categoryGroup.category).capitalized) \(categoryGroup.objects.firstIndex { $0.index == indexedObject.index }! + 1)" :
                                            String(describing: categoryGroup.category).capitalized
                                        
                                        Text(displayName)
                                        Spacer()
                                        if selectedIndices.contains(indexedObject.index) {
                                            Image(systemName: "checkmark.circle.fill")
                                                .foregroundColor(.blue)
                                        } else {
                                            Image(systemName: "circle")
                                                .foregroundColor(.gray)
                                        }
                                    }
                                    .contentShape(Rectangle())
                                    .onTapGesture {
                                        toggleSelection(for: indexedObject.index)
                                    }
                                    
                                    // Locate button - separate tappable area
                                    Button(action: {
                                        locateObject(at: indexedObject.index)
                                    }) {
                                        Image(systemName: "location")
                                            .font(.system(size: 16, weight: .medium))
                                            .foregroundColor(highlightedObjectIndex == indexedObject.index ? .yellow : .blue)
                                            .frame(width: 32, height: 32)
                                            .background(
                                                Circle()
                                                    .fill(highlightedObjectIndex == indexedObject.index ? Color.yellow.opacity(0.1) : Color.blue.opacity(0.1))
                                            )
                                    }
                                    .buttonStyle(PlainButtonStyle())
                                }
                            }
                        }
                    }
                }
            }
            .navigationTitle("Select Furniture")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        isPresented = false
                    }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        associatedFurnitureIndices = Array(selectedIndices)
                        let selectedCategories = selectedIndices.compactMap { index in
                            index < allDetectedObjects.count ? allDetectedObjects[index].category : nil
                        }
                        associatedFurnitureTypes = Array(Set(selectedCategories))
                        
                        // Save configuration to persistence
                        var updatedHabit = habit
                        updatedHabit.associatedFurnitureTypes = associatedFurnitureTypes
                        updatedHabit.associatedFurnitureIndices = associatedFurnitureIndices
                        configurationManager.saveConfiguration(for: updatedHabit)
                        
                        isPresented = false
                    }
                }
            }
        }
        .onAppear {
            // Auto-expand preview if there are selections to show
            if !selectedIndices.isEmpty {
                withAnimation(.easeInOut(duration: 0.3).delay(0.5)) {
                    showingPreview = true
                }
            }
        }
    }

    private func toggleSelection(for index: Int) {
        withAnimation(.easeInOut(duration: 0.2)) {
            if selectedIndices.contains(index) {
                selectedIndices.remove(index)
            } else {
                selectedIndices.insert(index)
            }
        }
        
        // Auto-expand preview when first item is selected
        if selectedIndices.count == 1 && !showingPreview {
            withAnimation(.easeInOut(duration: 0.3)) {
                showingPreview = true
            }
        }
    }
    
    private func locateObject(at index: Int) {
        // Only auto-expand preview if room data is available
        if !showingPreview && capturedRoom != nil {
            withAnimation(.easeInOut(duration: 0.3)) {
                showingPreview = true
            }
        }
        
        // Highlight the object temporarily
        withAnimation(.easeInOut(duration: 0.2)) {
            if highlightedObjectIndex == index {
                highlightedObjectIndex = nil
            } else {
                highlightedObjectIndex = index
            }
        }
    }
}

#Preview {
    struct PreviewWrapper: View {
        @State var isPresented = true
        @State var associatedTypes: [CapturedRoom.Object.Category] = [CapturedRoom.Object.Category.chair]
        @State var associatedIndices: [Int] = []
        
        var body: some View {
            FurnitureEditView(
                isPresented: $isPresented,
                associatedFurnitureTypes: $associatedTypes,
                associatedFurnitureIndices: $associatedIndices,
                allDetectedObjects: [], // Empty array to avoid initialization issues
                capturedRoom: nil, // No room data available in preview
                pathPoints: [],
                habit: Habit(
                    id: UUID(uuidString: "00000000-0000-0000-0000-000000000000")!,
                    name: "Sample Habit",
                    description: "Sample description",
                    category: .activity,
                    associatedObject: "Sample Object",
                    iconName: "star.fill",
                    associatedFurnitureTypes: [],
                    associatedFurnitureIndices: []
                )
            )
        }
    }
    return PreviewWrapper()
} 