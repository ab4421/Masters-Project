import SwiftUI
import RoomPlan
import SceneKit

struct HabitRecommendationView: View {
    @State var habit: Habit
    let roomData: CapturedRoom?
    let pathPoints: [PathPoint]
    
    @State private var pathWeight: Double = 0.5
    @State private var furnitureWeight: Double = 0.5
    @State private var recommendation: SurfaceRecommendation?
    @State private var visualElements: [SCNNode] = []
    @State private var isLoading: Bool = false
    @State private var errorMessage: String?
    @State private var hasGeneratedRecommendation: Bool = false
    @State private var candidateIndices: [Int] = []
    @State private var recommendedGlobalIndex: Int? = nil
    @State private var isEditingFurniture: Bool = false
    @State private var displayedFurnitureNamesList: [String] = []
    
    private let recommendationEngine = RecommendationEngine()
    private let visualizer = RecommendationVisualizer()
    
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
                
                // Associated Furniture Types
                if !habit.associatedFurnitureTypes.isEmpty || !habit.associatedFurnitureIndices.isEmpty {
                    VStack(alignment: .leading) {
                        Text("Associated Furniture")
                            .font(.headline)
                            .padding(.bottom, 2)
                        
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 10) {
                                ForEach(displayedFurnitureNamesList.indices, id: \.self) { index in
                                    let displayText = displayedFurnitureNamesList[index]
                                    Text(displayText)
                                        .font(.callout)
                                        .padding(.horizontal, 12)
                                        .padding(.vertical, 8)
                                        .background(Color.gray.opacity(0.1))
                                        .clipShape(RoundedRectangle(cornerRadius: 8))
                                }
                            }
                        }
                    }
                    .padding(.bottom)
                }
                
                // Room Preview
                if let room = roomData {
                    Text("Room Preview")
                        .font(.headline)
                    
                    ZStack {
                        RoomPreviewView(
                            capturedRoom: room,
                            pathPoints: pathPoints,
                            visualElements: visualElements,
                            recommendedObjectIndex: recommendedGlobalIndex,
                            candidateObjectIndices: candidateIndices
                        )
                        .frame(height: 300)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                        
                        if isLoading {
                            ProgressView()
                                .scaleEffect(1.5)
                                .frame(maxWidth: .infinity, maxHeight: .infinity)
                                .background(Color.black.opacity(0.2))
                                .cornerRadius(12)
                        }
                    }
                } else {
                    Text("No room scan available")
                        .foregroundColor(.gray)
                }
                
                // Error Message
                if let error = errorMessage {
                    Text(error)
                        .foregroundColor(.red)
                        .padding()
                        .background(Color.red.opacity(0.1))
                        .cornerRadius(8)
                }
                
                // Weight Adjustment Sliders
                VStack(alignment: .leading, spacing: 16) {
                    Text("Adjust Recommendation Weights")
                        .font(.headline)
                    
                    VStack(alignment: .leading) {
                        Text("Camera Path Weight: \(Int(pathWeight * 100))%")
                        Slider(value: $pathWeight, in: 0...1)
                            .onChange(of: pathWeight, initial: false) {
                                if hasGeneratedRecommendation {
                                    updateRecommendation()
                                }
                            }
                    }
                    
                    VStack(alignment: .leading) {
                        Text("Furniture Weight: \(Int(furnitureWeight * 100))%")
                        Slider(value: $furnitureWeight, in: 0...1)
                            .onChange(of: furnitureWeight, initial: false) {
                                if hasGeneratedRecommendation {
                                    updateRecommendation()
                                }
                            }
                    }
                }
                .padding()
                .background(Color.gray.opacity(0.1))
                .cornerRadius(12)
            }
            .padding()
        }
        .navigationTitle("Placement Guide")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button("Edit") {
                    isEditingFurniture = true
                }
            }
        }
        .sheet(isPresented: $isEditingFurniture) {
            if let room = roomData {
                FurnitureEditView(
                    isPresented: $isEditingFurniture,
                    associatedFurnitureTypes: $habit.associatedFurnitureTypes,
                    associatedFurnitureIndices: $habit.associatedFurnitureIndices,
                    allDetectedObjects: room.objects
                )
            } else {
                Text("Room data is not available to edit furniture.")
            }
        }
        .onChange(of: habit.associatedFurnitureTypes) {
            if hasGeneratedRecommendation {
                updateRecommendation()
            }
            updateDisplayedFurnitureList()
        }
        .onChange(of: habit.associatedFurnitureIndices) {
            if hasGeneratedRecommendation {
                updateRecommendation()
            }
            updateDisplayedFurnitureList()
        }
        .onAppear {
            updateDisplayedFurnitureList()
            if !hasGeneratedRecommendation {
                hasGeneratedRecommendation = true
                updateRecommendation()
            }
        }
    }
    
    private func updateDisplayedFurnitureList() {
        if !habit.associatedFurnitureIndices.isEmpty, let room = roomData {
            var categoryCounts: [CapturedRoom.Object.Category: Int] = [:]
            var items: [String] = []
            
            for index in habit.associatedFurnitureIndices.sorted() {
                guard index < room.objects.count else { continue }
                let object = room.objects[index]
                let currentCount = categoryCounts[object.category, default: 0]
                categoryCounts[object.category] = currentCount + 1
                
                let displayText: String
                if currentCount == 0 {
                    displayText = String(describing: object.category).capitalized
                } else {
                    displayText = "\(String(describing: object.category).capitalized) \(currentCount + 1)"
                }
                items.append(displayText)
            }
            self.displayedFurnitureNamesList = items
        } else {
            self.displayedFurnitureNamesList = habit.associatedFurnitureTypes.map { String(describing: $0).capitalized }
        }
    }
    
    private func updateRecommendation() {
        guard let room = roomData else {
            errorMessage = "No room data available"
            return
        }
        
        isLoading = true
        errorMessage = nil
        
        var settings = RecommendationSettings()
        settings.pathWeight = Float(pathWeight)
        settings.furnitureWeight = Float(furnitureWeight)
        settings.normalizeWeights()
        
        let surfaces = extractSurfaces(from: room)
        if surfaces.isEmpty {
            errorMessage = "No suitable surfaces found in the room"
            isLoading = false
            return
        }
        
        let furniture = extractAssociatedFurniture(from: room, for: habit)
        if furniture.isEmpty {
            print("Warning: No associated furniture found in the room")
        }
        
        let newRecommendation = recommendationEngine.findBestSurface(
            pathPoints: pathPoints,
            associatedFurniture: furniture,
            surfaces: surfaces,
            settings: settings
        )
        
        print(">>> DEBUG: New recommendation for habit '\\(habit.name)': \\(String(describing: newRecommendation))")

        recommendation = newRecommendation
        
        if recommendation == nil {
            errorMessage = "Could not find a suitable surface for placement"
        }
        
        updateVisualElements()
        isLoading = false
    }
    
    private func updateVisualElements() {
        guard let room = roomData else { return }
        visualElements.removeAll()
        let surfaces = extractSurfaces(from: room)
        let furniture = extractAssociatedFurniture(from: room, for: habit)
        
        // Compute candidate object indices for highlighting
        let indices = surfaces.compactMap { node -> Int? in
            guard let name = node.name,
                  name.hasPrefix("object_"),
                  let idx = Int(name.components(separatedBy: "_")[1])
            else { return nil }
            return idx
        }
        candidateIndices = indices
        // Compute global recommended index from surfaces-array index
        if let rec = recommendation, rec.objectIndex < candidateIndices.count {
            recommendedGlobalIndex = candidateIndices[rec.objectIndex]
        } else {
            recommendedGlobalIndex = nil
        }
        print("[Candidate Indices] \(indices)")
        
        // Log recommendation details and draw connection lines
        if let recommendation = recommendation {
            print("[Recommended Surface] Index: \(recommendation.objectIndex), Score: \(recommendation.score), DistanceFromPath: \(recommendation.distanceFromPath), DistanceFromFurniture: \(recommendation.distanceFromFurniture)")
            // Removed line drawing to reduce visual clutter
            // let pathLines = visualizer.createPathLines(
            //     from: pathPoints,
            //     to: recommendation.surface
            // )
            // visualElements.append(contentsOf: pathLines)
            // let furnitureLines = visualizer.createFurnitureLines(
            //     from: furniture,
            //     to: recommendation.surface
            // )
            // visualElements.append(contentsOf: furnitureLines)
        }
        
        // Log associated furniture
        for (idx, furn) in furniture.enumerated() {
            print("[Associated Furniture] Index: \(idx), Name: \(furn.name ?? "N/A"), Position: \(furn.position)")
        }
    }
    
    private func extractSurfaces(from room: CapturedRoom) -> [SCNNode] {
        var surfaces: [SCNNode] = []
        let eyeLevel: Float = 1.524 // 5 ft in meters
        // Compute approximate floor Y from lowest object bottom
        let floorBaseline: Float = room.objects.map { object in
            let originY = object.transform.columns.3.y
            return originY - (object.dimensions.y / 2)
        }.min() ?? 0
        print("\nFloor baseline Y: \(floorBaseline) m")
        print("=== Surface Detection Debug ===")
        print("Total objects in room: \(room.objects.count)")
        for (index, object) in room.objects.enumerated() {
            print("\nObject \(index + 1):")
            print("Category: \(object.category)")
            print("Dimensions: x=\(object.dimensions.x), y=\(object.dimensions.y), z=\(object.dimensions.z)")
            // Only allow table/storage surfaces
            if object.category == .table || object.category == .storage {
                let surfaceHeight: Float = 0.02 // thickness of the surface indicator
                // Local center Y above object origin
                let localCenterY = object.dimensions.y / 2 - surfaceHeight / 2
                // World-space surface Y
                let originY = object.transform.columns.3.y
                let worldSurfaceY = originY + localCenterY
                // Adjust relative to floor
                let relSurfaceY = worldSurfaceY - floorBaseline
                print("--> World top-surface rel. to floor Y: \(relSurfaceY) m")
                if relSurfaceY <= eyeLevel {
                    print("✓ Identified as surface-capable under eye level")
                    let geometry = SCNBox(
                        width: CGFloat(object.dimensions.x),
                        height: CGFloat(surfaceHeight),
                        length: CGFloat(object.dimensions.z),
                        chamferRadius: 0
                    )
                    let material = SCNMaterial()
                    material.diffuse.contents = UIColor.blue.withAlphaComponent(0.3)
                    material.isDoubleSided = true
                    geometry.materials = [material]
                    let surfaceNode = SCNNode(geometry: geometry)
                    let parentNode = SCNNode()
                    parentNode.simdTransform = object.transform
                    surfaceNode.position = SCNVector3(
                        0,
                        localCenterY,
                        0
                    )
                    parentNode.name = "object_\(index)"
                    parentNode.addChildNode(surfaceNode)
                    surfaces.append(parentNode)
                    print("✓ Added top surface for object_\(index)")
                } else {
                    print("✗ Skipping surface above eye level (relY=\(relSurfaceY))")
                }
            } else {
                print("✗ Not identified as surface-capable category")
            }
        }
        print("\nTotal surfaces found: \(surfaces.count)")
        print("=== End Surface Detection ===\n")
        return surfaces
    }
    
    private func extractAssociatedFurniture(from room: CapturedRoom, for habit: Habit) -> [SCNNode] {
        var furniture: [SCNNode] = []
        print("\n=== Associated Furniture Detection Debug ===")
        print("Total objects in room: \(room.objects.count)")
        
        // Use individual object indices if available, otherwise fall back to categories
        if !habit.associatedFurnitureIndices.isEmpty {
            print("Using individual object indices: \(habit.associatedFurnitureIndices)")
            for index in habit.associatedFurnitureIndices {
                guard index < room.objects.count else {
                    print("⚠️ Object index \(index) out of range (max: \(room.objects.count - 1))")
                    continue
                }
                
                let object = room.objects[index]
                print("\nObject \(index + 1) (selected):")
                print("Category: \(object.category)")
                print("Dimensions: x=\(object.dimensions.x), y=\(object.dimensions.y), z=\(object.dimensions.z)")
                print("✓ Added as associated furniture")
                
                let geometry = SCNBox(
                    width: CGFloat(object.dimensions.x),
                    height: CGFloat(object.dimensions.y),
                    length: CGFloat(object.dimensions.z),
                    chamferRadius: 0
                )
                let node = SCNNode(geometry: geometry)
                node.simdTransform = object.transform
                furniture.append(node)
            }
        } else {
            print("Using category-based selection: \(habit.associatedFurnitureTypes)")
            for (index, object) in room.objects.enumerated() {
                print("\nObject \(index + 1):")
                print("Category: \(object.category)")
                print("Dimensions: x=\(object.dimensions.x), y=\(object.dimensions.y), z=\(object.dimensions.z)")
                if habit.associatedFurnitureTypes.contains(object.category) {
                    print("✓ Identified as associated furniture")
                    let geometry = SCNBox(
                        width: CGFloat(object.dimensions.x),
                        height: CGFloat(object.dimensions.y),
                        length: CGFloat(object.dimensions.z),
                        chamferRadius: 0
                    )
                    let node = SCNNode(geometry: geometry)
                    node.simdTransform = object.transform
                    furniture.append(node)
                } else {
                    print("✗ Not identified as associated furniture")
                }
            }
        }
        
        print("\nTotal associated furniture items found: \(furniture.count)")
        print("=== End Associated Furniture Detection ===\n")
        return furniture
    }
}

#Preview {
    NavigationView {
        HabitRecommendationView(
            habit: Habit.sampleHabits[0],
            roomData: nil,
            pathPoints: []
        )
    }
} 
