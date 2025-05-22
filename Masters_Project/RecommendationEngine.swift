import Foundation
import SceneKit
import RoomPlan

// Structure to hold surface recommendation data
struct SurfaceRecommendation {
    let surface: SCNNode
    let objectIndex: Int
    let score: Float
    let distanceFromPath: Float
    let distanceFromFurniture: Float
}

// Structure to hold recommendation settings
struct RecommendationSettings {
    var pathWeight: Float = 0.5
    var furnitureWeight: Float = 0.5
    
    // Validate weights sum to 1.0
    mutating func normalizeWeights() {
        let total = pathWeight + furnitureWeight
        pathWeight = pathWeight / total
        furnitureWeight = furnitureWeight / total
    }
}

class RecommendationEngine {
    // Find the best surface for a habit based on path points and associated furniture
    func findBestSurface(
        pathPoints: [PathPoint],
        associatedFurniture: [SCNNode],
        surfaces: [SCNNode],
        settings: RecommendationSettings = RecommendationSettings()
    ) -> SurfaceRecommendation? {
        guard !surfaces.isEmpty else { return nil }
        
        var bestRecommendation: SurfaceRecommendation?
        var bestScore: Float = Float.infinity
        
        for (index, surface) in surfaces.enumerated() {
            // Calculate average distance from path points
            let pathDistance = calculateAveragePathDistance(pathPoints: pathPoints, surface: surface)
            
            // Calculate average distance from furniture
            let furnitureDistance = calculateAverageFurnitureDistance(
                furniture: associatedFurniture,
                surface: surface
            )
            
            // Calculate weighted score (lower is better)
            let score = (pathDistance * settings.pathWeight) + 
                       (furnitureDistance * settings.furnitureWeight)
            
            // ADD THIS LOG
            print("--- Engine evaluating surface index: \(index) (Original Object ID: \(surface.name ?? "N/A")) | PathDist: \(pathDistance) | FurnDist: \(furnitureDistance) | Score: \(score)")
            
            // Update best recommendation if this score is better
            if score < bestScore {
                bestScore = score
                bestRecommendation = SurfaceRecommendation(
                    surface: surface,
                    objectIndex: index,
                    score: score,
                    distanceFromPath: pathDistance,
                    distanceFromFurniture: furnitureDistance
                )
            }
        }
        
        return bestRecommendation
    }
    
    // Calculate average distance from path points to surface
    private func calculateAveragePathDistance(pathPoints: [PathPoint], surface: SCNNode) -> Float {
        guard !pathPoints.isEmpty else { return Float.infinity }
        
        let surfaceCenter = getSurfaceCenter(surface)
        var totalDistance: Float = 0
        
        for point in pathPoints {
            let distance = simd_distance(point.position, surfaceCenter)
            totalDistance += distance
        }
        
        return totalDistance / Float(pathPoints.count)
    }
    
    // Calculate average distance from furniture to surface
    private func calculateAverageFurnitureDistance(furniture: [SCNNode], surface: SCNNode) -> Float {
        guard !furniture.isEmpty else { return Float.infinity }
        
        // ADD THIS LOG
        print("---- Evaluating surface \(surface.name ?? "N/A") against \(furniture.count) furniture items:")
        for (idx, furnItem) in furniture.enumerated() {
            print("----   FurnItem \(idx): \(furnItem.name ?? "Original_\(furnItem.hash)"), Pos: \(furnItem.position)")
        }
        
        let surfaceCenter = getSurfaceCenter(surface)
        var totalDistance: Float = 0
        
        for item in furniture {
            let itemCenter = getNodeCenter(item)
            let distance = simd_distance(itemCenter, surfaceCenter)
            // ADD THIS LOG
            print("----     Calculating dist: surf '\(surface.name ?? "N/A")' center \(surfaceCenter) to furn '\(item.name ?? "Orig_\(item.hash)")' center \(itemCenter) = \(distance)")
            totalDistance += distance
        }
        
        return totalDistance / Float(furniture.count)
    }
    
    // Get the center point of a surface node
    private func getSurfaceCenter(_ surface: SCNNode) -> SIMD3<Float> {
        let boundingBox = surface.boundingBox
        let localCenter = SCNVector3(
            (boundingBox.max.x + boundingBox.min.x) / 2,
            (boundingBox.max.y + boundingBox.min.y) / 2,
            (boundingBox.max.z + boundingBox.min.z) / 2
        )
        let worldCenter = surface.convertPosition(localCenter, to: nil) // Convert to world coordinates
        return SIMD3<Float>(worldCenter.x, worldCenter.y, worldCenter.z)
    }
    
    // Get the center point of any node
    private func getNodeCenter(_ node: SCNNode) -> SIMD3<Float> {
        let boundingBox = node.boundingBox
        let localCenter = SCNVector3(
            (boundingBox.max.x + boundingBox.min.x) / 2,
            (boundingBox.max.y + boundingBox.min.y) / 2,
            (boundingBox.max.z + boundingBox.min.z) / 2
        )
        let worldCenter = node.convertPosition(localCenter, to: nil) // Convert to world coordinates
        return SIMD3<Float>(worldCenter.x, worldCenter.y, worldCenter.z)
    }
} 