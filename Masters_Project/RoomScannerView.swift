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

    var body: some View {
        switch scanState {
        case .intro:
            VStack(spacing: 32) {
                Spacer()
                Text("RoomPlan")
                    .font(.largeTitle).bold()
                Text("To scan your room, point your device at all the walls, windows, doors and furniture in your space until your scan is complete.\n\nYou can see a preview of your scan at the bottom of the screen so you can make sure your scan is correct.")
                    .multilineTextAlignment(.center)
                    .font(.body)
                Spacer()
                Button(action: { scanState = .scanning }) {
                    Text("Start Scanning")
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.blue)
                        .cornerRadius(20)
                        .padding(.horizontal, 40)
                }
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
                } else {
                    Text("No scan data available.")
                        .foregroundColor(.gray)
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

// UIViewRepresentable for RoomPlan's RoomView preview
struct RoomPreviewView: UIViewRepresentable {
    let capturedRoom: CapturedRoom
    func makeUIView(context: Context) -> SCNView {
        let scnView = SCNView()
        scnView.scene = makeScene(for: capturedRoom)
        scnView.autoenablesDefaultLighting = true
        scnView.allowsCameraControl = true
        return scnView
    }
    func updateUIView(_ uiView: SCNView, context: Context) {
        uiView.scene = makeScene(for: capturedRoom)
    }
    // Placeholder: create a simple box for now
    private func makeScene(for room: CapturedRoom) -> SCNScene {
        let scene = SCNScene()
        // You can add more detailed geometry based on room data here
        let box = SCNBox(width: 2, height: 1, length: 2, chamferRadius: 0.05)
        let node = SCNNode(geometry: box)
        node.position = SCNVector3(0, 0.5, 0)
        scene.rootNode.addChildNode(node)
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
