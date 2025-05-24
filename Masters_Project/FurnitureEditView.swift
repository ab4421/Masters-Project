import SwiftUI
import RoomPlan
import simd

struct FurnitureEditView: View {
    @Binding var isPresented: Bool
    @Binding var associatedFurnitureTypes: [CapturedRoom.Object.Category]
    @Binding var associatedFurnitureIndices: [Int]
    let allDetectedObjects: [CapturedRoom.Object]

    @State private var selectedIndices: Set<Int>

    init(isPresented: Binding<Bool>, associatedFurnitureTypes: Binding<[CapturedRoom.Object.Category]>, associatedFurnitureIndices: Binding<[Int]>, allDetectedObjects: [CapturedRoom.Object]) {
        self._isPresented = isPresented
        self._associatedFurnitureTypes = associatedFurnitureTypes
        self._associatedFurnitureIndices = associatedFurnitureIndices
        self.allDetectedObjects = allDetectedObjects
        
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
            List {
                ForEach(groupedObjects, id: \.category) { categoryGroup in
                    Section(header: Text(String(describing: categoryGroup.category).capitalized)) {
                        ForEach(categoryGroup.objects, id: \.index) { indexedObject in
                            Button(action: {
                                toggleSelection(for: indexedObject.index)
                            }) {
                                HStack {
                                    let displayName = categoryGroup.objects.count > 1 ? 
                                        "\(String(describing: categoryGroup.category).capitalized) \(categoryGroup.objects.firstIndex { $0.index == indexedObject.index }! + 1)" :
                                        String(describing: categoryGroup.category).capitalized
                                    
                                    Text(displayName)
                                    Spacer()
                                    if selectedIndices.contains(indexedObject.index) {
                                        Image(systemName: "checkmark")
                                            .foregroundColor(.blue)
                                    }
                                }
                            }
                            .foregroundColor(.primary)
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
                        isPresented = false
                    }
                }
            }
        }
    }

    private func toggleSelection(for index: Int) {
        if selectedIndices.contains(index) {
            selectedIndices.remove(index)
        } else {
            selectedIndices.insert(index)
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
                allDetectedObjects: [] // Empty array to avoid initialization issues
            )
        }
    }
    return PreviewWrapper()
} 