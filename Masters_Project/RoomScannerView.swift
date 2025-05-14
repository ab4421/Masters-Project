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
    @State private var scanState: ScanState = .intro
    @State private var isImporting: Bool = false
    @State private var showImportError: Bool = false
    @State private var importError: String = ""
    @State private var documentPickerDelegate: ImportDocumentPickerDelegate?
    let isRoomPlanSupported: Bool

    var body: some View {
        switch scanState {
        case .intro:
            VStack(spacing: 32) {
                Spacer()
                Text("RoomPlan")
                    .font(.largeTitle).bold()
                if isRoomPlanSupported {
                    Text("To scan your room, point your device at all the walls, windows, doors and furniture in your space until your scan is complete.\n\nYou can see a preview of your scan at the bottom of the screen so you can make sure your scan is correct.")
                        .multilineTextAlignment(.center)
                        .font(.body)
                } else {
                    Text("Your phone does not support scanning, but you can import a scan.")
                        .multilineTextAlignment(.center)
                        .font(.body)
                        .foregroundColor(.orange)
                }
                Spacer()
                HStack(spacing: 20) {
                    Button(action: { scanState = .scanning }) {
                        Text("Start Scanning")
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
                onCancel: {
                    scanState = .intro
                    capturedRoom = nil
                },
                onDone: {
                    scanState = .preview
                }
            )
            .edgesIgnoringSafeArea(.all)
        case .preview:
            VStack {
                Text("Scan Preview")
                    .font(.title2).bold()
                    .padding(.top)
                if let room = capturedRoom {
                    RoomPreviewView(capturedRoom: room)
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

    // Add export functionality
    private func exportRoomData(room: CapturedRoom) {
        let destinationFolderURL = FileManager.default.temporaryDirectory.appending(path: "Export")
        let destinationURL = destinationFolderURL.appending(path: "Room.usdz")
        let capturedRoomURL = destinationFolderURL.appending(path: "Room.json")
        
        do {
            try FileManager.default.createDirectory(at: destinationFolderURL, withIntermediateDirectories: true)
            
            // Export JSON data
            let jsonEncoder = JSONEncoder()
            let jsonData = try jsonEncoder.encode(room)
            try jsonData.write(to: capturedRoomURL)
            
            // Export USDZ file
            try room.export(to: destinationURL, exportOptions: .parametric)
            
            // Present share sheet
            let activityVC = UIActivityViewController(activityItems: [destinationFolderURL], applicationActivities: nil)
            
            // Get the current window scene
            if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
               let window = windowScene.windows.first,
               let rootViewController = window.rootViewController {
                activityVC.modalPresentationStyle = .popover
                rootViewController.present(activityVC, animated: true)
            }
        } catch {
            print("Error exporting room data: \(error)")
            // TODO: Show error alert to user
        }
    }

    // Add import functionality
    private func importRoomData() {
        // Create and store the delegate
        let delegate = ImportDocumentPickerDelegate(
            onImport: { url in
                self.handleImportedFile(at: url)
            },
            onError: { error in
                self.importError = error
                self.showImportError = true
            }
        )
        
        // Store the delegate to prevent deallocation
        documentPickerDelegate = delegate
        
        // Define the JSON type explicitly
        let jsonType = UTType.json
        let documentPicker = UIDocumentPickerViewController(forOpeningContentTypes: [jsonType])
        documentPicker.delegate = delegate
        
        // Get the current window scene
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let window = windowScene.windows.first,
           let rootViewController = window.rootViewController {
            // Present the picker on the main thread
            DispatchQueue.main.async {
                rootViewController.present(documentPicker, animated: true)
            }
        }
    }
    
    private func handleImportedFile(at url: URL) {
        // Ensure we're on the main thread for UI updates
        DispatchQueue.main.async {
            self.isImporting = true
        }
        
        do {
            // Read the file data
            let data = try Data(contentsOf: url)
            
            // Validate that we have data
            guard !data.isEmpty else {
                throw ImportError.emptyFile
            }
            
            // Try to decode the JSON
            let decoder = JSONDecoder()
            let importedRoom = try decoder.decode(CapturedRoom.self, from: data)
            
            // Validate the imported room has basic required elements
            guard !importedRoom.walls.isEmpty else {
                throw ImportError.invalidRoomData("No walls found in the imported room")
            }
            
            // Update the state on the main thread
            DispatchQueue.main.async {
                self.capturedRoom = importedRoom
                self.scanAttempted = true
                self.scanState = .preview // Move to preview state after successful import
                self.isImporting = false
            }
            
        } catch let error as ImportError {
            DispatchQueue.main.async {
                self.importError = error.localizedDescription
                self.showImportError = true
                self.isImporting = false
            }
        } catch {
            DispatchQueue.main.async {
                self.importError = "Failed to import file: \(error.localizedDescription)"
                self.showImportError = true
                self.isImporting = false
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
    var onCancel: () -> Void
    var onDone: () -> Void

    func makeUIViewController(context: Context) -> UINavigationController {
        let viewController = RoomCaptureViewControllerSwiftUI()
        viewController.delegate = context.coordinator
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
        directionalNode.position = SCNVector3(x: 5, y: 5, z: 5)
        scnView.scene?.rootNode.addChildNode(directionalNode)
        
        // Set up camera
        let camera = SCNCamera()
        camera.zFar = 100
        let cameraNode = SCNNode()
        cameraNode.camera = camera
        cameraNode.position = SCNVector3(x: 0, y: 2, z: 5)
        scnView.scene?.rootNode.addChildNode(cameraNode)
        
        return scnView
    }
    
    func updateUIView(_ uiView: SCNView, context: Context) {
        uiView.scene = createScene(from: capturedRoom)
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
        for object in room.objects {
            let geometry = SCNBox(width: CGFloat(object.dimensions.x),
                                height: CGFloat(object.dimensions.y),
                                length: CGFloat(object.dimensions.z),
                                chamferRadius: 0)
            geometry.firstMaterial?.diffuse.contents = UIColor.systemGreen.withAlphaComponent(0.6)
            let node = SCNNode(geometry: geometry)
            
            // Calculate offset based on transform
            let transform = object.transform
            let offset = simd_float3(0, 0, 0.04) // Largest offset for objects
            var newTransform = transform
            newTransform.columns.3.x += offset.x
            newTransform.columns.3.y += offset.y
            newTransform.columns.3.z += offset.z
            
            node.simdTransform = newTransform
            scene.rootNode.addChildNode(node)
            
            // Add text label for the object
            let labelText = String(describing: object.category)
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
        
        return scene
    }
}

// This is our adapted UIKit ViewController that will host RoomCaptureView
class RoomCaptureViewControllerSwiftUI: UIViewController, RoomCaptureViewDelegate, RoomCaptureSessionDelegate {

    weak var delegate: RoomCaptureControllerDelegate?

    private var roomCaptureView: RoomCaptureView!
    private var roomCaptureSessionConfig: RoomCaptureSession.Configuration = RoomCaptureSession.Configuration()
    private var isScanning: Bool = false
    // No need to store finalResults here if we pass it directly via delegate
    
    // UI Elements (programmatic as it's simpler for this wrapper)
    private var doneButton: UIBarButtonItem!
    private var cancelButton: UIBarButtonItem!
    private var activityIndicator: UIActivityIndicatorView!

    var onCancel: () -> Void = {}
    var onDone: () -> Void = {}

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set a background color to see the view bounds if needed during debugging
        // view.backgroundColor = .systemGray5
        
        setupRoomCaptureView()
        setupNavigationBar()
        
        activityIndicator = UIActivityIndicatorView(style: .large)
        activityIndicator.translatesAutoresizingMaskIntoConstraints = false // For programmatic constraints
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
        roomCaptureView = RoomCaptureView(frame: view.bounds)
        roomCaptureView.autoresizingMask = [.flexibleWidth, .flexibleHeight] // Ensure it resizes
        roomCaptureView.captureSession.delegate = self
        roomCaptureView.delegate = self
        view.insertSubview(roomCaptureView, at: 0)
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
        roomCaptureView?.captureSession.run(configuration: roomCaptureSessionConfig)
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
    
    // RoomCaptureSessionDelegate
    func captureSession(_ session: RoomCaptureSession, didUpdate room: CapturedRoom) {
        // This delegate provides live updates *during* the scan.
        // You can use this for live feedback if desired, but not essential for MVP.
        // print("captureSession:didUpdate - Live room model updated.")
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
        
        // Start accessing the security-scoped resource
        guard url.startAccessingSecurityScopedResource() else {
            onError("Permission denied to access the file")
            return
        }
        
        defer {
            url.stopAccessingSecurityScopedResource()
        }
        
        onImport(url)
    }
    
    func documentPickerWasCancelled(_ controller: UIDocumentPickerViewController) {
        // Handle cancellation if needed
    }
    
    func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentAt url: URL) {
        // This is the correct method name, but we're already handling it in didPickDocumentsAt
        // So we can leave this empty or remove it
    }
}

#Preview {
    RoomScannerView(
        capturedRoom: .constant(nil),
        scanAttempted: .constant(false),
        isRoomPlanSupported: true // or false to preview unsupported UI
    )
}
