//
//  RoomScannerView.swift
//  Masters_Project
//
//  Created by Arnav Bhatia on 08/05/2025.
//


// RoomScannerView.swift
import SwiftUI
import RoomPlan
import UIKit // Needed for UIViewControllerRepresentable
import SceneKit // Add this import for 3D preview
import UniformTypeIdentifiers // Add this for file type handling
import simd // Add this for vector operations
import ARKit // Add this for AR session access

public class PathTrackingManager {
    private var pathPoints: [PathPoint] = []
    private var lastUpdateTime: TimeInterval = 0
    private let updateInterval: TimeInterval = 2.0 // Update every 2 seconds
    private let minDistanceThreshold: Float = 0.1 // Minimum distance between points (10cm)
    
    public init() {} // Add public initializer
    
    public func updatePath(with position: SIMD3<Float>, confidence: Float) {
        let currentTime = CACurrentMediaTime()
        // Always add the very first point
        if pathPoints.isEmpty {
            pathPoints.append(PathPoint(position: position, timestamp: currentTime, confidence: confidence))
            lastUpdateTime = currentTime
            return
        }
        // Check if enough time has passed
        guard currentTime - lastUpdateTime >= updateInterval else { return }
        // Check if we have enough distance from the last point
        if let lastPoint = pathPoints.last {
            let distance = simd_distance(position, lastPoint.position)
            guard distance >= minDistanceThreshold else { return }
        }
        // Add new point
        pathPoints.append(PathPoint(
            position: position,
            timestamp: currentTime,
            confidence: confidence
        ))
        lastUpdateTime = currentTime
    }
    
    public func getPathPoints() -> [PathPoint] {
        return pathPoints
    }
    
    public func clearPath() {
        pathPoints.removeAll()
        lastUpdateTime = 0
    }
    
    // New method for directly setting path points during import
    public func setPathPoints(_ points: [PathPoint]) {
        pathPoints = points
        if let lastPoint = points.last {
            lastUpdateTime = lastPoint.timestamp
        }
    }
}

// Protocol for the delegate
protocol RoomCaptureControllerDelegate: AnyObject {
    func roomCaptureDidFinish(with room: CapturedRoom?, error: Error?)
    func roomCaptureDidCancel()
}

enum ScanState {
    case intro
    case scanning
    case preview
}

struct RoomScannerView: View {
    @Binding var capturedRoom: CapturedRoom?
    @Binding var scanAttempted: Bool
    let isRoomPlanSupported: Bool
    let onPathPointsUpdated: ([PathPoint]) -> Void
    let onRoomDataLoaded: (() -> Void)? // Add callback for when new room data is loaded
    
    @State private var scanState: ScanState = .intro
    @State private var isImporting: Bool = false
    @State private var showImportError: Bool = false
    @State private var importError: String = ""
    @State private var documentPickerDelegate: ImportDocumentPickerDelegate?
    @State var pathTrackingManager = PathTrackingManager()
    @StateObject private var roomDataManager = RoomDataManager.shared

    var body: some View {
        Group {
            switch scanState {
            case .intro:
                VStack(spacing: 32) {
                    Spacer()
                    
                    // Show saved room data prominently if available
                    if roomDataManager.hasPersistedRoom {
                        VStack(spacing: 16) {
                            HStack {
                                Image(systemName: "checkmark.circle.fill")
                                    .font(.title)
                                    .foregroundColor(.green)
                                Text("Saved Room Found!")
                                    .font(.title2)
                                    .fontWeight(.bold)
                                    .foregroundColor(.green)
                            }
                            
                            Text("You have a previously saved room scan. You can load it to continue where you left off, or scan a new room.")
                                .multilineTextAlignment(.center)
                                .font(.body)
                                .foregroundColor(.secondary)
                            
                            Button(action: {
                                loadPersistedRoom()
                            }) {
                                HStack {
                                    Image(systemName: "arrow.clockwise")
                                    Text("Load Saved Room")
                                }
                                .font(.headline)
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color.green)
                                .cornerRadius(20)
                            }
                            .padding(.horizontal, 20)
                        }
                        .padding()
                        .background(Color.green.opacity(0.1))
                        .cornerRadius(16)
                        .padding(.horizontal, 20)
                    } else {
                        // Normal intro text when no saved room
                        Text("RoomPlan")
                            .font(.largeTitle).bold()
                        
                        if isRoomPlanSupported {
                            Text("To scan your room, point your device at all the walls, windows, doors and furniture in your space until your scan is complete.\n\nYou can see a preview of your scan at the bottom of the screen so you can make sure your scan is correct.\n\n💡 Tip: After scanning, use the Export button to save your scan for future use.")
                                .multilineTextAlignment(.center)
                                .font(.body)
                        } else {
                            Text("Your phone does not support scanning, but you can import a previously saved scan.\n\n💡 Tip: If you have exported scans from other devices, you can import them here.")
                                .multilineTextAlignment(.center)
                                .font(.body)
                                .foregroundColor(.orange)
                        }
                    }
                    
                    Spacer()
                    
                    HStack(spacing: 20) {
                        Button(action: { scanState = .scanning }) {
                            Text(roomDataManager.hasPersistedRoom ? "Scan New Room" : "Start Scanning")
                                .font(.headline)
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(isRoomPlanSupported ? Color.blue : Color.gray)
                                .cornerRadius(20)
                        }
                        .disabled(!isRoomPlanSupported)
                        
                        Button(action: { importRoomData() }) {
                            HStack {
                                Image(systemName: "square.and.arrow.down")
                                Text("Import")
                            }
                            .font(.headline)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.blue)
                            .cornerRadius(20)
                        }
                    }
                    .padding(.horizontal, 40)
                    Spacer(minLength: 32)
                }
            case .scanning:
                RoomScannerRepresentable(
                    capturedRoom: $capturedRoom,
                    scanAttempted: $scanAttempted,
                    pathTrackingManager: pathTrackingManager,
                    onCancel: {
                        scanState = .intro
                        capturedRoom = nil
                        pathTrackingManager.clearPath()
                    },
                    onDone: {
                        // Auto-save when scan completes
                        if let room = capturedRoom {
                            roomDataManager.saveRoomData(room: room, pathPoints: pathTrackingManager.getPathPoints())
                            onPathPointsUpdated(pathTrackingManager.getPathPoints())
                            print("Auto-saved new room scan with \(room.walls.count) walls")
                        }
                        scanState = .preview
                    },
                    onRoomDataLoaded: {
                        // This callback is for when new room data is scanned/loaded
                        if let room = capturedRoom {
                            roomDataManager.saveRoomData(room: room, pathPoints: pathTrackingManager.getPathPoints())
                            print("Saved room data from scan completion")
                        }
                        onRoomDataLoaded?()
                    }
                )
                .edgesIgnoringSafeArea(.all)
            case .preview:
                VStack {
                    Text("Scan Preview")
                        .font(.title2).bold()
                        .padding(.top)
                    if let room = capturedRoom {
                        RoomPreviewView(
                            capturedRoom: room,
                            pathPoints: pathTrackingManager.getPathPoints(),
                            visualElements: [],
                            recommendedObjectIndex: nil,
                            secondBestObjectIndex: nil,
                            candidateObjectIndices: [],
                            candidateColor: .purple,
                            recommendedColor: .red,
                            secondBestColor: .orange
                        )
                        .frame(height: 350)
                        .padding()
                        
                        // Add export button
                        Button(action: {
                            exportRoomData(room: room)
                        }) {
                            HStack {
                                Image(systemName: "square.and.arrow.up")
                                Text("Export Scan")
                            }
                            .font(.headline)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.blue)
                            .cornerRadius(20)
                            .padding(.horizontal, 40)
                        }
                    } else {
                        Text("No scan data available.")
                            .foregroundColor(.gray)
                    }
                    
                    // Add import button
                    Button(action: {
                        importRoomData()
                    }) {
                        HStack {
                            Image(systemName: "square.and.arrow.down")
                            Text("Import Scan")
                        }
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.blue)
                        .cornerRadius(20)
                        .padding(.horizontal, 40)
                    }
                    
                    Button(action: {
                        scanState = .intro
                        capturedRoom = nil
                    }) {
                        Text("Start New Scan")
                            .font(.headline)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.blue)
                            .cornerRadius(20)
                            .padding(.horizontal, 40)
                    }
                    Spacer()
                }
                .alert("Import Error", isPresented: $showImportError) {
                    Button("OK", role: .cancel) { }
                } message: {
                    Text(importError)
                }
            }
        }
        .onChange(of: capturedRoom == nil) { _, isNil in
            // Reset to intro state when room data is cleared (becomes nil)
            if isNil && scanState == .preview {
                scanState = .intro
                pathTrackingManager.clearPath()
            }
        }
    }

    // MARK: - Private Methods
    
    private func loadPersistedRoom() {
        roomDataManager.loadRoomData()
        if let room = roomDataManager.currentRoom {
            capturedRoom = room
            pathTrackingManager.setPathPoints(roomDataManager.currentPathPoints)
            onPathPointsUpdated(roomDataManager.currentPathPoints)
            scanAttempted = true
            scanState = .preview
            onRoomDataLoaded?()
            print("Successfully loaded saved room with \(room.walls.count) walls and \(room.objects.count) objects")
        } else {
            print("Failed to load saved room data")
        }
    }

    // Add export functionality
    private func exportRoomData(room: CapturedRoom) {
        // Ensure room data is in memory for export
        if !roomDataManager.isRoomDataInMemory() {
            roomDataManager.saveRoomData(room: room, pathPoints: pathTrackingManager.getPathPoints())
        }
        
        if let folderURL = ExportService.shared.exportRoomDataOnly() {
            // Present share sheet
            let activityVC = UIActivityViewController(activityItems: [folderURL], applicationActivities: nil)
            
            // Get the current window scene
            if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
               let window = windowScene.windows.first,
               let rootViewController = window.rootViewController {
                activityVC.modalPresentationStyle = .popover
                rootViewController.present(activityVC, animated: true)
            }
        } else {
            print("Error exporting room data via ExportService")
            // TODO: Show error alert to user
        }
    }

    // Add import functionality
    private func importRoomData() {
        // Create and store the delegate
        let delegate = ImportDocumentPickerDelegate(
            onImport: { url in
                // Add a small delay to ensure document picker is properly dismissed
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                    self.handleImportedFile(at: url)
                }
            },
            onError: { error in
                DispatchQueue.main.async {
                    self.importError = error
                    self.showImportError = true
                }
            }
        )
        
        // Store the delegate to prevent deallocation
        documentPickerDelegate = delegate
        
        // Define the JSON type explicitly
        let jsonType = UTType.json
        let documentPicker = UIDocumentPickerViewController(forOpeningContentTypes: [jsonType])
        documentPicker.delegate = delegate
        documentPicker.modalPresentationStyle = .pageSheet // More reliable presentation style
        
        // Get the current window scene and present more safely
        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let window = windowScene.windows.first,
              let rootViewController = window.rootViewController else {
            DispatchQueue.main.async {
                self.importError = "Unable to present file picker"
                self.showImportError = true
            }
            return
        }
        
        // Present the picker on the main thread
        DispatchQueue.main.async {
            rootViewController.present(documentPicker, animated: true)
        }
    }
    
    private func handleImportedFile(at url: URL) {
        // Ensure we're on the main thread for UI updates
        DispatchQueue.main.async {
            self.isImporting = true
        }
        
        // Perform file operations on background queue
        DispatchQueue.global(qos: .userInitiated).async {
            do {
                // Ensure we have access to the file
                guard url.startAccessingSecurityScopedResource() else {
                    throw ImportError.invalidRoomData("Cannot access file")
                }
                
                defer {
                    url.stopAccessingSecurityScopedResource()
                }
                
                // Read the file data
                let data = try Data(contentsOf: url)
                
                // Validate that we have data
                guard !data.isEmpty else {
                    throw ImportError.emptyFile
                }
                
                // Try to decode the JSON
                let decoder = JSONDecoder()
                let importedData = try decoder.decode(RoomExportData.self, from: data)
                
                // Validate the imported room has basic required elements
                guard !importedData.room.walls.isEmpty else {
                    throw ImportError.invalidRoomData("No walls found in the imported room")
                }
                
                // Update the state on the main thread
                DispatchQueue.main.async {
                    // Auto-save imported data through RoomDataManager
                    self.roomDataManager.saveRoomData(room: importedData.room, pathPoints: importedData.pathPoints)
                    
                    self.capturedRoom = importedData.room
                    self.pathTrackingManager.setPathPoints(importedData.pathPoints)
                    self.onPathPointsUpdated(importedData.pathPoints)
                    self.scanAttempted = true
                    self.scanState = .preview // Move to preview state after successful import
                    self.isImporting = false
                    
                    // Notify that new room data was loaded successfully
                    self.onRoomDataLoaded?()
                    
                    // Clear the delegate reference after successful import
                    self.documentPickerDelegate = nil
                }
                
            } catch let error as ImportError {
                DispatchQueue.main.async {
                    self.importError = error.localizedDescription
                    self.showImportError = true
                    self.isImporting = false
                    self.documentPickerDelegate = nil
                }
            } catch {
                DispatchQueue.main.async {
                    self.importError = "Failed to import file: \(error.localizedDescription)"
                    self.showImportError = true
                    self.isImporting = false
                    self.documentPickerDelegate = nil
                }
            }
        }
    }
    
    // Define specific import errors
    enum ImportError: LocalizedError {
        case emptyFile
        case invalidRoomData(String)
        
        var errorDescription: String? {
            switch self {
            case .emptyFile:
                return "The selected file is empty"
            case .invalidRoomData(let message):
                return "Invalid room data: \(message)"
            }
        }
    }
}

// The existing UIViewControllerRepresentable is now renamed and used internally
struct RoomScannerRepresentable: UIViewControllerRepresentable {
    @Binding var capturedRoom: CapturedRoom?
    @Binding var scanAttempted: Bool
    var pathTrackingManager: PathTrackingManager
    var onCancel: () -> Void
    var onDone: () -> Void
    var onRoomDataLoaded: (() -> Void)? // Add callback for room data loaded

    func makeUIViewController(context: Context) -> UINavigationController {
        let viewController = RoomCaptureViewControllerSwiftUI()
        viewController.delegate = context.coordinator
        viewController.pathTrackingManager = pathTrackingManager
        viewController.onCancel = onCancel
        viewController.onDone = onDone
        let navController = UINavigationController(rootViewController: viewController)
        navController.navigationBar.isTranslucent = true
        return navController
    }

    func updateUIViewController(_ uiViewController: UINavigationController, context: Context) {}

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    class Coordinator: NSObject, RoomCaptureControllerDelegate {
        var parent: RoomScannerRepresentable
        init(_ parent: RoomScannerRepresentable) { self.parent = parent }
        func roomCaptureDidFinish(with room: CapturedRoom?, error: Error?) {
            parent.scanAttempted = true
            if let error = error {
                print("Error capturing room: \(error.localizedDescription)")
                parent.capturedRoom = nil
                return
            }
            if let room = room {
                parent.capturedRoom = room
                parent.onRoomDataLoaded?() // Notify that new room data was loaded
                parent.onDone()
            } else {
                parent.capturedRoom = nil
            }
        }
        func roomCaptureDidCancel() {
            parent.scanAttempted = true
            parent.capturedRoom = nil
            parent.onCancel()
        }
    }
}

// UIViewRepresentable for RoomPlan preview display
struct RoomPreviewView: UIViewRepresentable {
    let capturedRoom: CapturedRoom
    let pathPoints: [PathPoint]
    let visualElements: [SCNNode]
    let recommendedObjectIndex: Int?
    let secondBestObjectIndex: Int?
    let candidateObjectIndices: [Int]
    
    // Optional color parameters for different contexts
    let candidateColor: UIColor
    let recommendedColor: UIColor
    let secondBestColor: UIColor
    
    init(capturedRoom: CapturedRoom, pathPoints: [PathPoint], visualElements: [SCNNode], recommendedObjectIndex: Int?, secondBestObjectIndex: Int? = nil, candidateObjectIndices: [Int], candidateColor: UIColor = .purple, recommendedColor: UIColor = .red, secondBestColor: UIColor = .orange) {
        self.capturedRoom = capturedRoom
        self.pathPoints = pathPoints
        self.visualElements = visualElements
        self.recommendedObjectIndex = recommendedObjectIndex
        self.secondBestObjectIndex = secondBestObjectIndex
        self.candidateObjectIndices = candidateObjectIndices
        self.candidateColor = candidateColor
        self.recommendedColor = recommendedColor
        self.secondBestColor = secondBestColor
    }
    
    func makeUIView(context: Context) -> SCNView {
        let scnView = SCNView()
        scnView.scene = createScene(from: capturedRoom)
        scnView.autoenablesDefaultLighting = true
        scnView.allowsCameraControl = true
        scnView.backgroundColor = .systemBackground
        
        // Configure rendering settings
        scnView.antialiasingMode = .multisampling4X
        scnView.defaultCameraController.interactionMode = .orbitTurntable
        scnView.defaultCameraController.target = SCNVector3Zero
        
        // Add ambient light
        let ambientLight = SCNLight()
        ambientLight.type = .ambient
        ambientLight.intensity = 100
        let ambientNode = SCNNode()
        ambientNode.light = ambientLight
        scnView.scene?.rootNode.addChildNode(ambientNode)
        
        // Add directional light
        let directionalLight = SCNLight()
        directionalLight.type = .directional
        directionalLight.intensity = 800
        let directionalNode = SCNNode()
        directionalNode.light = directionalLight
        directionalNode.position = SCNVector3(5, 5, 5)
        scnView.scene?.rootNode.addChildNode(directionalNode)
        
        // Set up camera
        let camera = SCNCamera()
        camera.zFar = 100
        let cameraNode = SCNNode()
        cameraNode.camera = camera
        cameraNode.position = SCNVector3(0, 2, 5)
        scnView.scene?.rootNode.addChildNode(cameraNode)
        
        // Add path points
        if pathPoints.count > 1 {
            let first = pathPoints.first!
            let last = pathPoints.last!
            let startSphere = SCNSphere(radius: 0.08)
            startSphere.firstMaterial?.diffuse.contents = UIColor.systemGreen
            let startNode = SCNNode(geometry: startSphere)
            startNode.position = SCNVector3(first.position.x, first.position.y + 0.07, first.position.z)
            scnView.scene?.rootNode.addChildNode(startNode)

            let endSphere = SCNSphere(radius: 0.08)
            endSphere.firstMaterial?.diffuse.contents = UIColor.systemRed
            let endNode = SCNNode(geometry: endSphere)
            endNode.position = SCNVector3(last.position.x, last.position.y + 0.07, last.position.z)
            scnView.scene?.rootNode.addChildNode(endNode)
        }
        
        // Add visual elements
        for element in visualElements {
            scnView.scene?.rootNode.addChildNode(element)
        }
        
        return scnView
    }
    
    func updateUIView(_ uiView: SCNView, context: Context) {
        // Remove old path points and visual elements
        for node in uiView.scene?.rootNode.childNodes ?? [] {
            if node.geometry is SCNSphere || node.geometry is SCNPlane {
                node.removeFromParentNode()
            }
        }
        
        // Update scene
        uiView.scene = createScene(from: capturedRoom)
        
        // Add visual elements
        for element in visualElements {
            uiView.scene?.rootNode.addChildNode(element)
        }
    }
    
    private func createScene(from room: CapturedRoom) -> SCNScene {
        let scene = SCNScene()
        
        // Add walls first
        for wall in room.walls {
            let geometry = SCNBox(width: CGFloat(wall.dimensions.x),
                                height: CGFloat(wall.dimensions.y),
                                length: CGFloat(wall.dimensions.z),
                                chamferRadius: 0)
            geometry.firstMaterial?.diffuse.contents = UIColor.systemGray.withAlphaComponent(0.8)
            geometry.firstMaterial?.transparency = 0.3
            let node = SCNNode(geometry: geometry)
            node.simdTransform = wall.transform
            scene.rootNode.addChildNode(node)
        }
        
        // Add openings with offset
        for opening in room.openings {
            let geometry = SCNBox(width: CGFloat(opening.dimensions.x),
                                height: CGFloat(opening.dimensions.y),
                                length: CGFloat(opening.dimensions.z),
                                chamferRadius: 0)
            geometry.firstMaterial?.diffuse.contents = UIColor.systemYellow.withAlphaComponent(0.4)
            let node = SCNNode(geometry: geometry)
            
            // Calculate offset based on transform
            let transform = opening.transform
            let offset = simd_float3(0, 0, 0.01) // Small offset in Z direction
            var newTransform = transform
            newTransform.columns.3.x += offset.x
            newTransform.columns.3.y += offset.y
            newTransform.columns.3.z += offset.z
            
            node.simdTransform = newTransform
            scene.rootNode.addChildNode(node)
        }
        
        // Add windows with offset
        for window in room.windows {
            let geometry = SCNBox(width: CGFloat(window.dimensions.x),
                                height: CGFloat(window.dimensions.y),
                                length: CGFloat(window.dimensions.z),
                                chamferRadius: 0)
            geometry.firstMaterial?.diffuse.contents = UIColor.systemBlue.withAlphaComponent(0.3)
            let node = SCNNode(geometry: geometry)
            
            // Calculate offset based on transform
            let transform = window.transform
            let offset = simd_float3(0, 0, 0.02) // Slightly larger offset for windows
            var newTransform = transform
            newTransform.columns.3.x += offset.x
            newTransform.columns.3.y += offset.y
            newTransform.columns.3.z += offset.z
            
            node.simdTransform = newTransform
            scene.rootNode.addChildNode(node)

            // Add text label for the window
            let labelText = "Window"
            let textGeometry = SCNText(string: labelText, extrusionDepth: 0.01)
            textGeometry.font = UIFont.systemFont(ofSize: 0.22)
            textGeometry.firstMaterial?.diffuse.contents = UIColor.darkGray
            textGeometry.flatness = 0.2

            let textNode = SCNNode(geometry: textGeometry)
            let billboardConstraint = SCNBillboardConstraint()
            billboardConstraint.freeAxes = .all
            textNode.constraints = [billboardConstraint]

            let (min, max) = textGeometry.boundingBox
            let textWidth = max.x - min.x
            let textHeight = max.y - min.y
            textNode.pivot = SCNMatrix4MakeTranslation((min.x + textWidth / 2), (min.y + textHeight / 2), 0)

            // Position the label just above the window
            let textOffset = simd_float3(0, Float(window.dimensions.y) / 2 + 0.05, 0)
            var textTransform = newTransform
            textTransform.columns.3.x += textOffset.x
            textTransform.columns.3.y += textOffset.y
            textTransform.columns.3.z += textOffset.z
            textNode.simdTransform = textTransform

            scene.rootNode.addChildNode(textNode)
        }
        
        // Add doors with offset
        for door in room.doors {
            let geometry = SCNBox(width: CGFloat(door.dimensions.x),
                                height: CGFloat(door.dimensions.y),
                                length: CGFloat(door.dimensions.z),
                                chamferRadius: 0)
            geometry.firstMaterial?.diffuse.contents = UIColor.brown.withAlphaComponent(0.8)
            let node = SCNNode(geometry: geometry)
            
            // Calculate offset based on transform
            let transform = door.transform
            let offset = simd_float3(0, 0, 0.03) // Even larger offset for doors
            var newTransform = transform
            newTransform.columns.3.x += offset.x
            newTransform.columns.3.y += offset.y
            newTransform.columns.3.z += offset.z
            
            node.simdTransform = newTransform
            scene.rootNode.addChildNode(node)

            // Add text label for the door
            let labelText = "Door"
            let textGeometry = SCNText(string: labelText, extrusionDepth: 0.01)
            textGeometry.font = UIFont.systemFont(ofSize: 0.22)
            textGeometry.firstMaterial?.diffuse.contents = UIColor.darkGray
            textGeometry.flatness = 0.2

            let textNode = SCNNode(geometry: textGeometry)
            let billboardConstraint = SCNBillboardConstraint()
            billboardConstraint.freeAxes = .all
            textNode.constraints = [billboardConstraint]

            let (min, max) = textGeometry.boundingBox
            let textWidth = max.x - min.x
            let textHeight = max.y - min.y
            textNode.pivot = SCNMatrix4MakeTranslation((min.x + textWidth / 2), (min.y + textHeight / 2), 0)

            // Position the label just above the door
            let textOffset = simd_float3(0, Float(door.dimensions.y) / 2 + 0.05, 0)
            var textTransform = newTransform
            textTransform.columns.3.x += textOffset.x
            textTransform.columns.3.y += textOffset.y
            textTransform.columns.3.z += textOffset.z
            textNode.simdTransform = textTransform

            scene.rootNode.addChildNode(textNode)
        }
        
        // Add objects with offset and labels
        let visualizer = RecommendationVisualizer()
        var categoryCounts: [CapturedRoom.Object.Category: Int] = [:]
        
        // First pass: count objects by category to determine if numbering is needed
        var categoryTotals: [CapturedRoom.Object.Category: Int] = [:]
        for object in room.objects {
            categoryTotals[object.category, default: 0] += 1
        }
        
        for (index, object) in room.objects.enumerated() {
            let geometry = SCNBox(width: CGFloat(object.dimensions.x),
                                height: CGFloat(object.dimensions.y),
                                length: CGFloat(object.dimensions.z),
                                chamferRadius: 0)
            geometry.firstMaterial?.diffuse.contents = UIColor.systemGreen.withAlphaComponent(0.6)
            let node = SCNNode(geometry: geometry)
            node.name = "object_\(index)"
            
            // Calculate offset based on transform
            let transform = object.transform
            let offset = simd_float3(0, 0, 0.04) // Largest offset for objects
            var newTransform = transform
            newTransform.columns.3.x += offset.x
            newTransform.columns.3.y += offset.y
            newTransform.columns.3.z += offset.z
            
            node.simdTransform = newTransform
            
            // Highlight objects based on selection state
            // Priority: recommendedObjectIndex > secondBestObjectIndex > candidateObjectIndices
            if let recIdx = recommendedObjectIndex, index == recIdx {
                // Highlighted/recommended object (highest priority)
                visualizer.highlightTopFace(of: node, color: recommendedColor)
            } else if let secondIdx = secondBestObjectIndex, index == secondIdx {
                // Second-best object (second priority)
                visualizer.highlightTopFace(of: node, color: secondBestColor)
            } else if candidateObjectIndices.contains(index) {
                // Candidate/selected objects (lowest priority)
                visualizer.highlightTopFace(of: node, color: candidateColor)
            }
            
            scene.rootNode.addChildNode(node)
            
            // Track category counts and create appropriate label using FurnitureEditView logic
            let currentCount = categoryCounts[object.category, default: 0]
            categoryCounts[object.category] = currentCount + 1
            
            let labelText: String
            let totalForCategory = categoryTotals[object.category, default: 1]
            if totalForCategory > 1 {
                labelText = "\(String(describing: object.category).capitalized) \(currentCount + 1)"
            } else {
                labelText = String(describing: object.category).capitalized
            }
            
            let textGeometry = SCNText(string: labelText, extrusionDepth: 0.01)
            textGeometry.font = UIFont.systemFont(ofSize: 0.22)
            textGeometry.firstMaterial?.diffuse.contents = UIColor.darkGray
            textGeometry.flatness = 0.2

            let textNode = SCNNode(geometry: textGeometry)

            // Add billboarding so the text always faces the camera
            let billboardConstraint = SCNBillboardConstraint()
            billboardConstraint.freeAxes = .all
            textNode.constraints = [billboardConstraint]

            // Center the text geometry in both X and Y
            let (min, max) = textGeometry.boundingBox
            let textWidth = max.x - min.x
            let textHeight = max.y - min.y
            textNode.pivot = SCNMatrix4MakeTranslation((min.x + textWidth / 2), (min.y + textHeight / 2), 0)

            // Position the label just above the object
            let textOffset = simd_float3(0, Float(object.dimensions.y) / 2 + 0.05, 0)
            var textTransform = newTransform
            textTransform.columns.3.x += textOffset.x
            textTransform.columns.3.y += textOffset.y
            textTransform.columns.3.z += textOffset.z
            textNode.simdTransform = textTransform

            scene.rootNode.addChildNode(textNode)
        }
        
        // Add camera path visualization
        if pathPoints.count > 1 {
            // Add start and end nodes
            let startSphere = SCNSphere(radius: 0.08)
            startSphere.firstMaterial?.diffuse.contents = UIColor.systemGreen
            let startNode = SCNNode(geometry: startSphere)
            startNode.position = SCNVector3(
                x: Float(pathPoints.first!.position.x),
                y: Float(pathPoints.first!.position.y) + 0.07,
                z: Float(pathPoints.first!.position.z)
            )
            scene.rootNode.addChildNode(startNode)

            let endSphere = SCNSphere(radius: 0.08)
            endSphere.firstMaterial?.diffuse.contents = UIColor.systemRed
            let endNode = SCNNode(geometry: endSphere)
            endNode.position = SCNVector3(
                x: Float(pathPoints.last!.position.x),
                y: Float(pathPoints.last!.position.y) + 0.07,
                z: Float(pathPoints.last!.position.z)
            )
            scene.rootNode.addChildNode(endNode)

            var vertices: [SCNVector3] = []
            for point in pathPoints {
                let position = SCNVector3(
                    x: Float(point.position.x),
                    y: Float(point.position.y) + 0.1, // Slight offset to avoid z-fighting
                    z: Float(point.position.z)
                )
                vertices.append(position)
            }
            
            // Draw tubes between consecutive points
            for i in 0..<(vertices.count - 1) {
                let start = vertices[i]
                let end = vertices[i + 1]
                let vector = SCNVector3(end.x - start.x, end.y - start.y, end.z - start.z)
                let distance = sqrt(vector.x * vector.x + vector.y * vector.y + vector.z * vector.z)
                if distance < 0.001 { continue } // Filter out zero-length segments
                let midPoint = SCNVector3((start.x + end.x) / 2, (start.y + end.y) / 2, (start.z + end.z) / 2)

                let cylinder = SCNCylinder(radius: 0.025, height: CGFloat(distance))
                let material = SCNMaterial()
                material.diffuse.contents = UIColor.systemBlue
                material.transparency = 0.7
                cylinder.materials = [material]

                let cylinderNode = SCNNode(geometry: cylinder)
                cylinderNode.position = midPoint

                // Quaternion-based rotation
                let up = SCNVector3(0, 1, 0)
                let v = vector
                let vNorm = sqrt(v.x * v.x + v.y * v.y + v.z * v.z)
                let vUnit = SCNVector3(v.x / vNorm, v.y / vNorm, v.z / vNorm)
                let dot = up.x * vUnit.x + up.y * vUnit.y + up.z * vUnit.z
                if abs(dot - 1.0) < 1e-6 {
                    cylinderNode.orientation = SCNQuaternion(0, 0, 0, 1)
                } else if abs(dot + 1.0) < 1e-6 {
                    cylinderNode.orientation = SCNQuaternion(1, 0, 0, Float.pi)
                } else {
                    let axis = SCNVector3(
                        up.y * vUnit.z - up.z * vUnit.y,
                        up.z * vUnit.x - up.x * vUnit.z,
                        up.x * vUnit.y - up.y * vUnit.x
                    )
                    let axisNorm = sqrt(axis.x * axis.x + axis.y * axis.y + axis.z * axis.z)
                    let axisUnit = SCNVector3(axis.x / axisNorm, axis.y / axisNorm, axis.z / axisNorm)
                    let angle = acos(dot)
                    let halfAngle = angle / 2.0
                    let sinHalfAngle = sin(halfAngle)
                    let q = SCNQuaternion(
                        axisUnit.x * sinHalfAngle,
                        axisUnit.y * sinHalfAngle,
                        axisUnit.z * sinHalfAngle,
                        cos(halfAngle)
                    )
                    cylinderNode.orientation = q
                }

                scene.rootNode.addChildNode(cylinderNode)
            }
        }
        
        return scene
    }
}

// This is our adapted UIKit ViewController that will host RoomCaptureView
class RoomCaptureViewControllerSwiftUI: UIViewController, RoomCaptureViewDelegate, RoomCaptureSessionDelegate, ARSessionDelegate {

    weak var delegate: RoomCaptureControllerDelegate?

    private var roomCaptureView: RoomCaptureView!
    private var roomCaptureSessionConfig: RoomCaptureSession.Configuration = RoomCaptureSession.Configuration()
    private var isScanning: Bool = false
    var pathTrackingManager: PathTrackingManager!
    
    // UI Elements (programmatic as it's simpler for this wrapper)
    private var doneButton: UIBarButtonItem!
    private var cancelButton: UIBarButtonItem!
    private var activityIndicator: UIActivityIndicatorView!

    var onCancel: () -> Void = {}
    var onDone: () -> Void = {}
    
    // Add a property to store the current camera position
    private var currentCameraPosition: SIMD3<Float> = SIMD3<Float>(0, 0, 0)

    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupRoomCaptureView()
        setupNavigationBar()
        
        activityIndicator = UIActivityIndicatorView(style: .large)
        activityIndicator.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(activityIndicator)
        NSLayoutConstraint.activate([
            activityIndicator.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            activityIndicator.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
        activityIndicator.hidesWhenStopped = true
        activityIndicator.stopAnimating()
    }

    private func setupNavigationBar() {
        doneButton = UIBarButtonItem(title: "Done", style: .done, target: self, action: #selector(doneScanning(_:)))
        cancelButton = UIBarButtonItem(title: "Cancel", style: .plain, target: self, action: #selector(cancelScanning(_:)))
        
        self.navigationItem.rightBarButtonItem = doneButton
        self.navigationItem.leftBarButtonItem = cancelButton
        self.navigationItem.title = "Scanning Room..." // Initial title
        updateNavBarForActiveScan(isActive: true) // Set initial state
    }

    private func setupRoomCaptureView() {
        // Create RoomCaptureView
        roomCaptureView = RoomCaptureView(frame: view.bounds)
        roomCaptureView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        roomCaptureView.captureSession.delegate = self
        roomCaptureView.delegate = self
        view.insertSubview(roomCaptureView, at: 0)
        
        // Set up AR session delegate
        roomCaptureView.captureSession.arSession.delegate = self
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        // Check if already scanning to prevent restarting if view appears for other reasons
        if !isScanning {
            startSession()
        }
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        // Consider if you *always* want to stop.
        // If just covered by a system alert, maybe not.
        // For now, if it's disappearing and scanning, let's assume it should stop.
        // if isScanning {
        //     roomCaptureView?.captureSession.stop() // This stops scanning but doesn't trigger processing
        //     isScanning = false
        //     updateNavBarForActiveScan(isActive: false)
        //     // If disappearing without explicit done/cancel, this might be an implicit cancel
        //     // self.delegate?.roomCaptureDidCancel()
        // }
    }

    private func startSession() {
        print("Attempting to start RoomPlan session...")
        isScanning = true
        
        // Configure and start the session
        let configuration = RoomCaptureSession.Configuration()
        roomCaptureView?.captureSession.run(configuration: configuration)
        updateNavBarForActiveScan(isActive: true)
    }

    private func stopSessionAndProcess() {
        if isScanning {
            print("Stopping session and requesting processing...")
            activityIndicator?.startAnimating()
            doneButton.isEnabled = false // Disable while processing
            cancelButton.isEnabled = false
            navigationItem.title = "Processing..."
            roomCaptureView?.captureSession.stop() // This will trigger processing
            // isScanning will be set to false once processing is done or in captureView delegate
        }
    }

    // RoomCaptureViewDelegate
    func captureView(shouldPresent roomDataForProcessing: CapturedRoomData, error: Error?) -> Bool {
        print("captureView:shouldPresent - RoomPlan has enough data.")
        if let error = error {
            print("Error before processing: \(error.localizedDescription)")
            delegate?.roomCaptureDidFinish(with: nil, error: error)
            activityIndicator?.stopAnimating()
            updateNavBarForActiveScan(isActive: false) // Or error state
            isScanning = false
            return false // Don't process if there was an early error
        }
        return true // Yes, please process the data
    }

    func captureView(didPresent processedResult: CapturedRoom, error: Error?) {
        activityIndicator?.stopAnimating()
        isScanning = false // Processing is complete
        updateNavBarForActiveScan(isActive: false) // Update nav bar for completed state
        
        if let error = error {
            print("Error processing final results: \(error.localizedDescription)")
            delegate?.roomCaptureDidFinish(with: nil, error: error)
            return
        }
        print("Processed result received in RoomCaptureViewControllerSwiftUI")
        delegate?.roomCaptureDidFinish(with: processedResult, error: nil)
        onDone() // Notify SwiftUI to show preview
    }
    
    // ARSessionDelegate method to get camera updates
    func session(_ session: ARSession, didUpdate frame: ARFrame) {
        // Get the camera transform from the current frame
        let cameraTransform = frame.camera.transform
        
        // Extract position from the transform matrix
        let position = SIMD3<Float>(
            cameraTransform.columns.3.x,
            cameraTransform.columns.3.y,
            cameraTransform.columns.3.z
        )
        
        // Update the current camera position
        currentCameraPosition = position
        
        // Update the path with the new position
        // Using a default confidence of 1.0 for now
        pathTrackingManager.updatePath(with: position, confidence: 1.0)
        
        // Print the position for testing
        print("Camera position: \(position)")
    }

    // RoomCaptureSessionDelegate
    func captureSession(_ session: RoomCaptureSession, didUpdate room: CapturedRoom) {
        // We'll keep this empty as we're using ARSession for tracking
    }

    func captureSession(_ session: RoomCaptureSession, didEndWith data: CapturedRoomData, error: Error?) {
        // This is called when session.stop() is called *before* shouldPresent processing.
        // If an error occurs here, it means scanning itself failed.
        print("captureSession:didEndWith - Session explicitly stopped.")
        if let error = error {
            print("Error during session stop: \(error.localizedDescription)")
            activityIndicator?.stopAnimating()
            isScanning = false
            updateNavBarForActiveScan(isActive: false)
            delegate?.roomCaptureDidFinish(with: nil, error: error)
        }
        // If no error, processing will be initiated by shouldPresent and didPresent
    }


    @objc func doneScanning(_ sender: UIBarButtonItem) {
        if isScanning {
            stopSessionAndProcess()
        }
        // If not scanning, but "Done" is somehow active, it might mean it's already processed.
        // The delegate call from didPresent is the true "done".
        // Call onDone closure if processing is already done
        // (Handled in delegate, but safe to call here if needed)
    }
    
    @objc func cancelScanning(_ sender: UIBarButtonItem) {
        print("Cancel button tapped.")
        if isScanning {
            roomCaptureView?.captureSession.stop() // Stop the session immediately
            isScanning = false
        }
        activityIndicator?.stopAnimating() // Ensure indicator stops
        updateNavBarForActiveScan(isActive: false) // Reset nav bar
        delegate?.roomCaptureDidCancel()
        onCancel() // Notify SwiftUI to go back to intro
    }
    
    private func updateNavBarForActiveScan(isActive: Bool) {
        if isActive {
            doneButton.isEnabled = true
            cancelButton.isEnabled = true
            navigationItem.title = "Scanning Room..."
        } else {
            doneButton.isEnabled = true // Or change title to "Rescan" / disable
            cancelButton.isEnabled = true // Or change title / disable
            navigationItem.title = "Scan Complete" // Or based on success/failure
        }
    }
}

// Update the ImportDocumentPickerDelegate to be more robust
class ImportDocumentPickerDelegate: NSObject, UIDocumentPickerDelegate {
    let onImport: (URL) -> Void
    let onError: (String) -> Void
    
    init(onImport: @escaping (URL) -> Void, onError: @escaping (String) -> Void) {
        self.onImport = onImport
        self.onError = onError
        super.init()
    }
    
    func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
        guard let url = urls.first else {
            onError("No file selected")
            return
        }
        
        // Validate file extension
        guard url.pathExtension.lowercased() == "json" else {
            onError("Please select a JSON file")
            return
        }
        
        onImport(url)
    }
    
    func documentPickerWasCancelled(_ controller: UIDocumentPickerViewController) {
        // Cancellation is normal behavior, don't treat as error
        print("Document picker was cancelled by user")
    }
}

#Preview {
    RoomScannerView(
        capturedRoom: .constant(nil),
        scanAttempted: .constant(false),
        isRoomPlanSupported: true, // or false to preview unsupported UI
        onPathPointsUpdated: { _ in },
        onRoomDataLoaded: nil
    )
}
