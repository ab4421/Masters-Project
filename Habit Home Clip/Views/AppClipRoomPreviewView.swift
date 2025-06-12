import SwiftUI
import RoomPlan
import SceneKit

// App Clip version of RoomPreviewView
struct AppClipRoomPreviewView: UIViewRepresentable {
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
            let offset = simd_float3(0, 0, 0.02) // Medium offset in Z direction
            var newTransform = transform
            newTransform.columns.3.x += offset.x
            newTransform.columns.3.y += offset.y
            newTransform.columns.3.z += offset.z
            
            node.simdTransform = newTransform
            scene.rootNode.addChildNode(node)
        }
        
        // Add doors with offset and labels
        for door in room.doors {
            let geometry = SCNBox(width: CGFloat(door.dimensions.x),
                                height: CGFloat(door.dimensions.y),
                                length: CGFloat(door.dimensions.z),
                                chamferRadius: 0)
            geometry.firstMaterial?.diffuse.contents = UIColor.systemBrown.withAlphaComponent(0.6)
            let node = SCNNode(geometry: geometry)
            
            // Calculate offset based on transform
            let transform = door.transform
            let offset = simd_float3(0, 0, 0.03) // Large offset in Z direction
            var newTransform = transform
            newTransform.columns.3.x += offset.x
            newTransform.columns.3.y += offset.y
            newTransform.columns.3.z += offset.z
            
            node.simdTransform = newTransform
            scene.rootNode.addChildNode(node)
            
            // Add "Door" label
            let textGeometry = SCNText(string: "Door", extrusionDepth: 0.01)
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
        
        // Add camera path visualization (copied from main app's working implementation)
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

                // Quaternion-based rotation (improved implementation from main app)
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