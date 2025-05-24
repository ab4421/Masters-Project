import SwiftUI
import RoomPlan
import simd

struct FurnitureEditView: View {
    @Binding var isPresented: Bool
    @Binding var associatedFurnitureTypes: [CapturedRoom.Object.Category]
    let allDetectedObjects: [CapturedRoom.Object]

    @State private var selectedTypes: Set<CapturedRoom.Object.Category>

    init(isPresented: Binding<Bool>, associatedFurnitureTypes: Binding<[CapturedRoom.Object.Category]>, allDetectedObjects: [CapturedRoom.Object]) {
        self._isPresented = isPresented
        self._associatedFurnitureTypes = associatedFurnitureTypes
        self.allDetectedObjects = allDetectedObjects
        self._selectedTypes = State(initialValue: Set(associatedFurnitureTypes.wrappedValue))
    }

    private var availableCategories: [CapturedRoom.Object.Category] {
        Array(Set(allDetectedObjects.map { $0.category })).sorted { String(describing: $0) < String(describing: $1) }
    }

    var body: some View {
        NavigationView {
            List {
                ForEach(availableCategories, id: \.self) { category in
                    Button(action: {
                        toggleSelection(for: category)
                    }) {
                        HStack {
                            Text(String(describing: category).capitalized)
                            Spacer()
                            if selectedTypes.contains(category) {
                                Image(systemName: "checkmark")
                                    .foregroundColor(.blue)
                            }
                        }
                    }
                    .foregroundColor(.primary)
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
                        associatedFurnitureTypes = Array(selectedTypes)
                        isPresented = false
                    }
                }
            }
        }
    }

    private func toggleSelection(for category: CapturedRoom.Object.Category) {
        if selectedTypes.contains(category) {
            selectedTypes.remove(category)
        } else {
            selectedTypes.insert(category)
        }
    }
}

#Preview {
    struct PreviewWrapper: View {
        @State var isPresented = true
        @State var associatedTypes: [CapturedRoom.Object.Category] = [CapturedRoom.Object.Category.chair]
        
        var body: some View {
            FurnitureEditView(
                isPresented: $isPresented,
                associatedFurnitureTypes: $associatedTypes,
                allDetectedObjects: [] // Empty array to avoid initialization issues
            )
        }
    }
    return PreviewWrapper()
} 