// RoomScannerView.swift
import SwiftUI
import RoomPlan
import UIKit // Needed for UIViewControllerRepresentable

struct RoomScannerView: UIViewControllerRepresentable {
    // Binding to pass the capturedRoom data back to ContentView
    @Binding var capturedRoom: CapturedRoom?
    // Binding to control navigation/presentation of recommendations
    @Binding var showRecommendations: Bool

    func makeUIViewController(context: Context) -> RoomCaptureViewControllerSwiftUI {
        let viewController = RoomCaptureViewControllerSwiftUI()
        viewController.delegate = context.coordinator // Set the coordinator as the delegate
        return viewController
    }

    func updateUIViewController(_ uiViewController: RoomCaptureViewControllerSwiftUI, context: Context) {
        // No updates needed from SwiftUI to the ViewController in this simple case
    }

    // Coordinator to handle delegate callbacks from RoomCaptureViewControllerSwiftUI
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    class Coordinator: NSObject, RoomCaptureControllerDelegate {
        var parent: RoomScannerView

        init(_ parent: RoomScannerView) {
            self.parent = parent
        }

        // Delegate method to receive the captured room
        func roomCaptureDidFinish(with room: CapturedRoom?, error: Error?) {
            if let error = error {
                print("Error capturing room: \(error.localizedDescription)")
                // Handle error appropriately in a real app (e.g., show an alert)
                return
            }
            if let room = room {
                print("Room capture finished successfully in Coordinator!")
                parent.capturedRoom = room
                parent.showRecommendations = true // Trigger showing recommendations
            }
        }
        
        func roomCaptureDidCancel() {
            print("Room capture was cancelled by the user.")
            // Reset any state if needed, e.g., navigate back or clear data
            parent.showRecommendations = false // Hide recommendations if scan is cancelled
            parent.capturedRoom = nil
        }
    }
}

// Protocol for the delegate
protocol RoomCaptureControllerDelegate: AnyObject {
    func roomCaptureDidFinish(with room: CapturedRoom?, error: Error?)
    func roomCaptureDidCancel()
}

// This is our adapted UIKit ViewController that will host RoomCaptureView
class RoomCaptureViewControllerSwiftUI: UIViewController, RoomCaptureViewDelegate, RoomCaptureSessionDelegate {

    weak var delegate: RoomCaptureControllerDelegate?

    private var roomCaptureView: RoomCaptureView!
    private var roomCaptureSessionConfig: RoomCaptureSession.Configuration = RoomCaptureSession.Configuration()
    private var isScanning: Bool = false
    private var finalResults: CapturedRoom?
    
    // UI Elements (programmatic as it's simpler for this wrapper)
    private var doneButton: UIBarButtonItem!
    private var cancelButton: UIBarButtonItem! // Added for cancellation
    private var activityIndicator: UIActivityIndicatorView!

    override func viewDidLoad() {
        super.viewDidLoad()
        setupRoomCaptureView()
        setupNavigationBar() // Setup nav bar items programmatically
        
        activityIndicator = UIActivityIndicatorView(style: .large)
        activityIndicator.center = view.center
        activityIndicator.hidesWhenStopped = true
        view.addSubview(activityIndicator)
        activityIndicator.stopAnimating()
    }

    private func setupNavigationBar() {
        // Programmatically create bar button items
        doneButton = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(doneScanning(_:)))
        cancelButton = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(cancelScanning(_:)))
        
        self.navigationItem.rightBarButtonItem = doneButton
        self.navigationItem.leftBarButtonItem = cancelButton // Add cancel button
        self.title = "Scanning Room" // Set a title
    }

    private func setupRoomCaptureView() {
        roomCaptureView = RoomCaptureView(frame: view.bounds)
        roomCaptureView.captureSession.delegate = self
        roomCaptureView.delegate = self
        view.insertSubview(roomCaptureView, at: 0) // Ensure it's behind other UI if any
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        startSession()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        // Only stop session if it's truly disappearing, not just covered by an alert etc.
        // The sample code stops it unconditionally. You might want more control.
        // For now, we keep it simple:
        if isScanning { // If we are leaving and still scanning, treat as cancel
            roomCaptureView?.captureSession.stop()
            isScanning = false
            // If disappearing while scanning without explicit done/cancel,
            // it might be good to notify delegate about cancellation
            // self.delegate?.roomCaptureDidCancel()
        }
    }

    private func startSession() {
        isScanning = true
        roomCaptureView?.captureSession.run(configuration: roomCaptureSessionConfig)
        updateNavBarForActiveScan(isActive: true)
    }

    private func stopSessionAndProcess() {
        if isScanning {
            activityIndicator?.startAnimating() // Show activity while processing
            roomCaptureView?.captureSession.stop() // This will trigger processing
            // The result will come via captureView(didPresent:error:)
        }
        isScanning = false // Set scanning to false as we initiated stop
        updateNavBarForActiveScan(isActive: false) // Update nav bar immediately
    }

    // RoomCaptureViewDelegate
    func captureView(shouldPresent roomDataForProcessing: CapturedRoomData, error: Error?) -> Bool {
        // This is called when RoomPlan has enough data and asks if it should process it.
        // The sample returns true, so we will too.
        return true
    }

    func captureView(didPresent processedResult: CapturedRoom, error: Error?) {
        activityIndicator?.stopAnimating()
        updateNavBarForActiveScan(isActive: false) // Scan is complete
        
        if let error = error {
            print("Error processing final results: \(error.localizedDescription)")
            delegate?.roomCaptureDidFinish(with: nil, error: error)
            return
        }
        finalResults = processedResult
        print("Processed result received in RoomCaptureViewControllerSwiftUI")
        delegate?.roomCaptureDidFinish(with: finalResults, error: nil)
        
        // In the original sample, export was an option.
        // Here, we directly pass data via delegate.
        // If you want an export button, you can add it and use similar logic.
    }

    @objc func doneScanning(_ sender: UIBarButtonItem) {
        if isScanning {
            stopSessionAndProcess() // This will stop and trigger processing
        }
        // The actual "done" (data ready) is handled by the delegate callback
    }
    
    @objc func cancelScanning(_ sender: UIBarButtonItem) {
        if isScanning {
            roomCaptureView?.captureSession.stop() // Stop the session immediately
            isScanning = false
        }
        delegate?.roomCaptureDidCancel()
        // Dismiss if presented modally (which it is, effectively, by SwiftUI)
        // This dismissal should be handled by the SwiftUI side if needed,
        // or by how you structure the navigation. For a tab, it just stays.
        // If you were presenting this view controller modally, you'd dismiss it here.
    }
    
    // Helper to update nav bar appearance
    private func updateNavBarForActiveScan(isActive: Bool) {
        if isActive {
            doneButton.title = "Done" // Or keep as icon
            // You can customize colors like in the sample if desired
        } else {
            doneButton.title = "Scan Finished" // Or disable, or change text
            // Enable/show export or other options if needed
        }
        // The sample had an export button, we're not including it by default here
        // to simplify and directly use the delegate pattern.
    }
}