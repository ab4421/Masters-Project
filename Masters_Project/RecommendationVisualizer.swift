import Foundation
import SceneKit
import RoomPlan

class RecommendationVisualizer {
    // Create a colored square overlay for the recommended/candidate surface
    func createSurfaceHighlight(for surface: SCNNode, color: UIColor = .red) -> SCNNode {
        let boundingBox = surface.boundingBox
        let width = boundingBox.max.x - boundingBox.min.x
        let length = boundingBox.max.z - boundingBox.min.z
        
        // Create a plane geometry for the highlight
        let plane = SCNPlane(width: CGFloat(width), height: CGFloat(length))
        let material = SCNMaterial()
        material.diffuse.contents = color.withAlphaComponent(0.3)
        material.isDoubleSided = true
        plane.materials = [material]
        
        // Create the highlight node
        let highlightNode = SCNNode(geometry: plane)
        highlightNode.position = SCNVector3(
            (boundingBox.max.x + boundingBox.min.x) / 2,
            boundingBox.max.y + 0.001, // Slightly above the surface
            (boundingBox.max.z + boundingBox.min.z) / 2
        )
        
        // Rotate to match surface orientation
        highlightNode.eulerAngles.x = -.pi / 2
        
        return highlightNode
    }
    
    // Create lines connecting path points to the surface
    func createPathLines(
        from pathPoints: [PathPoint],
        to surface: SCNNode
    ) -> [SCNNode] {
        let surfaceCenter = getSurfaceCenter(surface)
        var lines: [SCNNode] = []
        
        for point in pathPoints {
            let line = createLine(
                from: point.position,
                to: surfaceCenter,
                color: .blue
            )
            lines.append(line)
        }
        
        return lines
    }
    
    // Create lines connecting furniture to the surface
    func createFurnitureLines(
        from furniture: [SCNNode],
        to surface: SCNNode
    ) -> [SCNNode] {
        let surfaceCenter = getSurfaceCenter(surface)
        var lines: [SCNNode] = []
        
        for item in furniture {
            let itemCenter = getNodeCenter(item)
            let line = createLine(
                from: itemCenter,
                to: surfaceCenter,
                color: .green
            )
            lines.append(line)
        }
        
        return lines
    }
    
    // Helper function to create a line between two points
    private func createLine(
        from start: SIMD3<Float>,
        to end: SIMD3<Float>,
        color: UIColor
    ) -> SCNNode {
        let vertices: [SCNVector3] = [
            SCNVector3(start),
            SCNVector3(end)
        ]
        
        let source = SCNGeometrySource(vertices: vertices)
        let element = SCNGeometryElement(
            indices: [0, 1],
            primitiveType: .line
        )
        
        let geometry = SCNGeometry(sources: [source], elements: [element])
        let material = SCNMaterial()
        material.diffuse.contents = color
        geometry.materials = [material]
        
        return SCNNode(geometry: geometry)
    }
    
    // Get the center point of a surface node
    private func getSurfaceCenter(_ surface: SCNNode) -> SIMD3<Float> {
        let boundingBox = surface.boundingBox
        return SIMD3<Float>(
            (boundingBox.max.x + boundingBox.min.x) / 2,
            (boundingBox.max.y + boundingBox.min.y) / 2,
            (boundingBox.max.z + boundingBox.min.z) / 2
        )
    }
    
    // Get the center point of any node
    private func getNodeCenter(_ node: SCNNode) -> SIMD3<Float> {
        let boundingBox = node.boundingBox
        return SIMD3<Float>(
            (boundingBox.max.x + boundingBox.min.x) / 2,
            (boundingBox.max.y + boundingBox.min.y) / 2,
            (boundingBox.max.z + boundingBox.min.z) / 2
        )
    }
    
    // Highlight the top face of a box geometry in the specified color
    func highlightTopFace(of node: SCNNode, color: UIColor = .red) {
        guard let box = node.geometry as? SCNBox else { return }
        var materials = box.materials
        // Ensure there are 6 materials (one per face)
        while materials.count < 6 {
            let mat = SCNMaterial()
            mat.diffuse.contents = UIColor.systemGreen.withAlphaComponent(0.6)
            materials.append(mat)
        }
        let highlightMaterial = SCNMaterial()
        highlightMaterial.diffuse.contents = color.withAlphaComponent(0.7)
        highlightMaterial.isDoubleSided = true
        materials[4] = highlightMaterial // Top face is index 4
        box.materials = materials
    }
} 