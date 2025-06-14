import SwiftUI
import RoomPlan
import SceneKit

struct AppClipHabitRecommendationView: View {
    @State var habit: Habit
    let roomData: CapturedRoom?
    let pathPoints: [PathPoint]
    
    @State internal var biasPosition: Double = 7.0
    @State internal var hasChangedFromDefault: Bool = false
    @State internal var showingAbout: Bool = false
    @State internal var recommendation: SurfaceRecommendation?
    @State internal var secondBestRecommendation: SurfaceRecommendation?
    @State internal var visualElements: [SCNNode] = []
    @State internal var isLoading: Bool = false
    @State internal var errorMessage: String?
    @State internal var hasGeneratedRecommendation: Bool = false
    @State internal var candidateIndices: [Int] = []
    @State internal var recommendedGlobalIndex: Int? = nil
    @State internal var secondBestGlobalIndex: Int? = nil
    @State internal var isEditingFurniture: Bool = false
    @State internal var displayedFurnitureNamesList: [String] = []
    
    internal let recommendationEngine = RecommendationEngine()
    internal let visualizer = RecommendationVisualizer()
    @StateObject internal var configurationManager = AppClipConfigurationManager.shared
    
    // Computed properties for weights based on bias position
    internal var pathWeight: Double {
        return (10.0 - biasPosition) / 10.0
    }
    
    internal var furnitureWeight: Double {
        return biasPosition / 10.0
    }
    
    private var biasDescription: String {
        switch biasPosition {
        case 0:
            return "100% Camera Path"
        case 1:
            return "90% Camera Path"
        case 2:
            return "80% Camera Path"
        case 3:
            return "70% Camera Path"
        case 4:
            return "60% Camera Path"
        case 5:
            return "Balanced (50/50)"
        case 6:
            return "60% Furniture"
        case 7:
            return "70% Furniture"
        case 8:
            return "80% Furniture"
        case 9:
            return "90% Furniture"
        case 10:
            return "100% Furniture"
        default:
            return "Custom (\(Int(furnitureWeight * 100))% Furniture)"
        }
    }
    
    // Computed property for star state
    private var isStarred: Bool {
        configurationManager.isHabitStarred(habit.id)
    }
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                // App Clip Header
                VStack(alignment: .leading, spacing: 12) {
                    HStack {
                        Image(systemName: "app.badge")
                            .foregroundColor(.blue)
                        Text("App Clip Preview")
                            .font(.headline)
                            .foregroundColor(.blue)
                    }
                    
                    Text("This is a sample room demonstration. Download the full app to scan your own space and create custom habits.")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .padding(.horizontal)
                        .padding(.vertical, 8)
                        .background(Color.blue.opacity(0.1))
                        .cornerRadius(8)
                    
                    Button(action: {
                        if let url = URL(string: "https://testflight.apple.com/join/QFxE86b8") {
                            UIApplication.shared.open(url)
                        }
                    }) {
                        HStack {
                            Text("Get Full App")
                            Image(systemName: "arrow.up.right")
                        }
                        .font(.subheadline)
                        .foregroundColor(.blue)
                    }
                }
                .padding(.horizontal)
                
                // Habit Header
                HStack {
                    Image(systemName: habit.iconName)
                        .font(.system(size: 40))
                        .foregroundColor(.blue)
                        .frame(width: 60, height: 60)
                        .background(Color.blue.opacity(0.1))
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                    
                    VStack(alignment: .leading, spacing: 4) {
                        HStack {
                            Text(habit.name)
                                .font(.title2)
                                .bold()
                            
                            Button(action: toggleStar) {
                                Image(systemName: isStarred ? "star.fill" : "star")
                                    .font(.title3)
                                    .foregroundColor(isStarred ? .yellow : .gray)
                            }
                        }
                        Text(habit.associatedObject)
                            .font(.subheadline)
                            .foregroundColor(.gray)
                    }
                }
                .padding(.horizontal)
                
                // Description
                Text(habit.description)
                    .font(.body)
                    .padding(.horizontal)
                
                // Associated Furniture Types
                if !habit.associatedFurnitureTypes.isEmpty || !habit.associatedFurnitureIndices.isEmpty {
                    VStack(alignment: .leading) {
                        Text("Associated Furniture")
                            .font(.headline)
                            .padding(.bottom, 2)
                            .padding(.horizontal)
                        
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
                            .padding(.horizontal)
                        }
                    }
                    .padding(.bottom)
                }
                
                // Room Preview
                if let room = roomData {
                    Text("Room Preview")
                        .font(.headline)
                        .padding(.horizontal)
                    
                    ZStack {
                        AppClipRoomPreviewView(
                            capturedRoom: room,
                            pathPoints: pathPoints,
                            visualElements: visualElements,
                            recommendedObjectIndex: recommendedGlobalIndex,
                            secondBestObjectIndex: secondBestGlobalIndex,
                            candidateObjectIndices: candidateIndices,
                            candidateColor: UIColor.systemGreen.withAlphaComponent(0.8),
                            recommendedColor: .red,
                            secondBestColor: UIColor.systemYellow.withAlphaComponent(0.9)
                        )
                        .frame(height: 300)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                        .padding(.horizontal)
                        
                        if isLoading {
                            ProgressView()
                                .scaleEffect(1.5)
                                .frame(maxWidth: .infinity, maxHeight: .infinity)
                                .background(Color.black.opacity(0.2))
                                .cornerRadius(12)
                        }
                    }
                    
                    // Legend
                    VStack(alignment: .leading, spacing: 8) {
                        HStack(alignment: .center, spacing: 20) {
                            if recommendedGlobalIndex != nil {
                                HStack(spacing: 4) {
                                    RoundedRectangle(cornerRadius: 4)
                                        .fill(Color.red.opacity(0.7))
                                        .frame(width: 16, height: 16)
                                    if let best = recommendation {
                                        Text("Best Surface (Score: \(String(format: "%.2f", best.score)))")
                                            .font(.caption)
                                            .foregroundColor(.secondary)
                                    } else {
                                        Text("Best Surface")
                                            .font(.caption)
                                            .foregroundColor(.secondary)
                                    }
                                }
                            }
                            
                            if secondBestGlobalIndex != nil {
                                HStack(spacing: 4) {
                                    RoundedRectangle(cornerRadius: 4)
                                        .fill(Color.yellow.opacity(0.8))
                                        .frame(width: 16, height: 16)
                                    if let secondBest = secondBestRecommendation {
                                        Text("2nd Best (Score: \(String(format: "%.2f", secondBest.score)))")
                                            .font(.caption)
                                            .foregroundColor(.secondary)
                                    } else {
                                        Text("2nd Best")
                                            .font(.caption)
                                            .foregroundColor(.secondary)
                                    }
                                }
                            }
                            
                            Spacer()
                        }
                        
                        // Score difference information
                        if let best = recommendation, let secondBest = secondBestRecommendation {
                            let scoreDifference = secondBest.score - best.score
                            let percentageDifference = (scoreDifference / best.score) * 100
                            
                            Text("Score difference: \(String(format: "%.2f", scoreDifference)) (\(String(format: "%.1f", percentageDifference))% higher)")
                                .font(.caption2)
                                .foregroundColor(.secondary)
                                .italic()
                        }
                    }
                    .padding(.horizontal)
                    .padding(.top, 8)
                } else {
                    Text("No room scan available")
                        .foregroundColor(.gray)
                        .padding(.horizontal)
                }
                
                // Error Message
                if let error = errorMessage {
                    Text(error)
                        .foregroundColor(.red)
                        .padding()
                        .background(Color.red.opacity(0.1))
                        .cornerRadius(8)
                        .padding(.horizontal)
                }
                
                // Weight Adjustment Sliders
                VStack(alignment: .leading, spacing: 16) {
                    HStack {
                        Text("Adjust Importance")
                            .font(.headline)
                        
                        Spacer()
                        
                        if hasChangedFromDefault {
                            Button(action: {
                                biasPosition = 7.0
                                hasChangedFromDefault = false
                                if hasGeneratedRecommendation {
                                    updateRecommendation()
                                }
                                configurationManager.saveConfiguration(for: habit, biasPosition: biasPosition)
                            }) {
                                HStack(spacing: 4) {
                                    Image(systemName: "arrow.counterclockwise")
                                    Text("Reset")
                                }
                            }
                            .font(.subheadline)
                            .foregroundColor(.blue)
                        }
                    }
                    
                    VStack(alignment: .leading, spacing: 12) {
                        VStack(spacing: 8) {
                            // Visual ticks above slider
                            HStack {
                                ForEach(0...10, id: \.self) { _ in
                                    Rectangle()
                                        .fill(Color.secondary.opacity(0.4))
                                        .frame(width: 1, height: 8)
                                        .frame(maxWidth: .infinity)
                                }
                            }
                            
                            Slider(value: $biasPosition, in: 0...10, step: 1)
                                .onChange(of: biasPosition, initial: false) { _, _ in
                                    hasChangedFromDefault = (biasPosition != 7.0)
                                    if hasGeneratedRecommendation {
                                        updateRecommendation()
                                    }
                                    configurationManager.saveConfiguration(for: habit, biasPosition: biasPosition)
                                }
                        }
                        
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
                        
                        HStack(alignment: .top, spacing: 8) {
                            Text("Tip: Adjust the slider to see how the recommended surface changes based on the importance of your camera path or the associated furniture.")
                                .font(.caption)
                                .foregroundColor(.secondary)
                                .fixedSize(horizontal: false, vertical: true)
                            
                            Button(action: {
                                showingAbout = true
                            }) {
                                Image(systemName: "info.circle")
                                    .font(.subheadline)
                                    .foregroundColor(.blue)
                            }
                        }
                    }
                }
                .padding()
                .background(Color.gray.opacity(0.1))
                .cornerRadius(12)
                .padding(.horizontal)
            }
            .padding(.bottom)
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
                AppClipFurnitureEditView(
                    isPresented: $isEditingFurniture,
                    associatedFurnitureTypes: $habit.associatedFurnitureTypes,
                    associatedFurnitureIndices: $habit.associatedFurnitureIndices,
                    allDetectedObjects: room.objects,
                    capturedRoom: roomData,
                    pathPoints: pathPoints,
                    habit: habit
                )
            } else {
                Text("Room data is not available to edit furniture.")
            }
        }
        .sheet(isPresented: $showingAbout) {
            NavigationView {
                AppClipAboutView()
                    .navigationBarTitleDisplayMode(.inline)
                    .toolbar {
                        ToolbarItem(placement: .navigationBarTrailing) {
                            Button("Done") {
                                showingAbout = false
                            }
                        }
                    }
            }
        }
        .onChange(of: habit.associatedFurnitureTypes) {
            if hasGeneratedRecommendation {
                updateRecommendation()
            }
            updateDisplayedFurnitureList()
            configurationManager.saveConfiguration(for: habit, biasPosition: biasPosition)
        }
        .onChange(of: habit.associatedFurnitureIndices) {
            if hasGeneratedRecommendation {
                updateRecommendation()
            }
            updateDisplayedFurnitureList()
            configurationManager.saveConfiguration(for: habit, biasPosition: biasPosition)
        }
        .onAppear {
            if let savedBiasPosition = configurationManager.applyConfiguration(to: &habit) {
                biasPosition = savedBiasPosition
            }
            
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
            
            // First pass: count total objects by category to determine if numbering is needed
            var categoryTotals: [CapturedRoom.Object.Category: Int] = [:]
            for index in habit.associatedFurnitureIndices {
                guard index < room.objects.count else { continue }
                let object = room.objects[index]
                categoryTotals[object.category, default: 0] += 1
            }
            
            for index in habit.associatedFurnitureIndices.sorted() {
                guard index < room.objects.count else { continue }
                let object = room.objects[index]
                let currentCount = categoryCounts[object.category, default: 0]
                categoryCounts[object.category] = currentCount + 1
                
                let displayText: String
                let totalForCategory = categoryTotals[object.category, default: 1]
                if totalForCategory > 1 {
                    displayText = "\(String(describing: object.category).capitalized) \(currentCount + 1)"
                } else {
                    displayText = String(describing: object.category).capitalized
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
        
        let recommendationResult = recommendationEngine.findBestSurfaces(
            pathPoints: pathPoints,
            associatedFurniture: furniture,
            surfaces: surfaces,
            settings: settings
        )
        
        recommendation = recommendationResult.best
        secondBestRecommendation = recommendationResult.secondBest
        
        print(">>> DEBUG: Best recommendation for habit '\(habit.name)': \(String(describing: recommendation))")
        print(">>> DEBUG: Second-best recommendation for habit '\(habit.name)': \(String(describing: secondBestRecommendation))")

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
        
        // Compute global second-best index from surfaces-array index
        if let secondBest = secondBestRecommendation, secondBest.objectIndex < candidateIndices.count {
            secondBestGlobalIndex = candidateIndices[secondBest.objectIndex]
        } else {
            secondBestGlobalIndex = nil
        }
        
        print("[Candidate Indices] \(indices)")
        print("[Recommended Global Index] \(String(describing: recommendedGlobalIndex))")
        print("[Second-Best Global Index] \(String(describing: secondBestGlobalIndex))")
        
        // Log recommendation details
        if let recommendation = recommendation {
            print("[Best Surface] Index: \(recommendation.objectIndex), Score: \(recommendation.score), DistanceFromPath: \(recommendation.distanceFromPath), DistanceFromFurniture: \(recommendation.distanceFromFurniture)")
        }
        
        if let secondBest = secondBestRecommendation {
            print("[Second-Best Surface] Index: \(secondBest.objectIndex), Score: \(secondBest.score), DistanceFromPath: \(secondBest.distanceFromPath), DistanceFromFurniture: \(secondBest.distanceFromFurniture)")
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
    
    // MARK: - Star Management
    
    private func toggleStar() {
        if isStarred {
            configurationManager.unstarHabit()
        } else {
            configurationManager.starHabit(habit.id)
        }
    }
}

// MARK: - Simple About View for App Clip

struct AppClipAboutView: View {
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                Text("About Habit Home")
                    .font(.title)
                    .bold()
                
                Text("This App Clip demonstrates our habit recommendation system using a pre-scanned room.")
                    .font(.body)
                
                Text("The algorithm analyzes room layouts and movement patterns to suggest optimal object placement for building healthy habits.")
                    .font(.body)
                
                VStack(alignment: .leading, spacing: 8) {
                    Text("Full App Features:")
                        .font(.headline)
                    
                    Text("• Scan your own rooms with RoomPlan")
                    Text("• Create custom habits")
                    Text("• Save recommendations permanently")
                    Text("• Track habit progress")
                    Text("• Export data for research")
                }
                
                Button(action: {
                    if let url = URL(string: "https://apps.apple.com/app/your-app-id") {
                        UIApplication.shared.open(url)
                    }
                }) {
                    HStack {
                        Text("Download Full App")
                        Image(systemName: "arrow.up.right")
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(12)
                }
                .padding(.top)
            }
            .padding()
        }
        .navigationTitle("About")
    }
}

#Preview {
    NavigationView {
        AppClipHabitRecommendationView(
            habit: Habit.getConfiguredSampleHabits()[0],
            roomData: nil,
            pathPoints: []
        )
    }
} 
