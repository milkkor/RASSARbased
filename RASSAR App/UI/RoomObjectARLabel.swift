//
//  RoomObjectARLabel.swift
//  RetroAccess App
//
//  Created by User on 9/1/24.
//

import Foundation
import RealityKit
import ARKit
import UIKit

/// Entity that displays information about a room object in AR space
class RoomObjectARLabel: Entity, HasAnchoring {
    
    // The text entity that displays the object information
    private var textEntity: Entity?
    
    // The background plane for better visibility
    private var backgroundEntity: Entity?
    
    // Track if we need to update the text
    private var needsTextUpdate = true
    
    // Information to display
    private var objectName: String
    private var dimensions: String
    private var floorHeight: String?
    
    /// Creates a new AR label for a room object
    /// - Parameters:
    ///   - name: Object name
    ///   - dimensions: Dimensions as string
    ///   - floorHeight: Optional height from floor
    ///   - position: 3D position for the label
    init(name: String, dimensions: String, floorHeight: String?, position: SIMD3<Float>) {
        self.objectName = name
        self.dimensions = dimensions
        self.floorHeight = floorHeight
        
        super.init()
        
        // Position the label slightly above the object
        self.position = position
        
        // Create a billboard component to make the label always face the camera
        createLabelEntities()
    }
    
    required init() {
        self.objectName = ""
        self.dimensions = ""
        self.floorHeight = nil
        super.init()
    }
    
    /// Creates the visual elements of the label
    private func createLabelEntities() {
        // Create a container entity with billboard component
        let containerEntity = Entity()
        
        // Add billboard constraint to make it always face the camera
        containerEntity.components.set(BillboardComponent())
        
        // Add container to self
        addChild(containerEntity)
        
        // Create background plane
        let backgroundMesh = MeshResource.generatePlane(width: 0.4, height: 0.2)
        let backgroundMaterial = SimpleMaterial(color: UIColor.black.withAlphaComponent(0.8), roughness: 0.5, isMetallic: false)
        let backgroundModelEntity = ModelEntity(mesh: backgroundMesh, materials: [backgroundMaterial])
        
        // Position the background
        backgroundModelEntity.position = [0, 0, 0.01]
        containerEntity.addChild(backgroundModelEntity)
        self.backgroundEntity = backgroundModelEntity
        
        // Create the label content
        generateTextEntity(parent: containerEntity)
    }
    
    /// Generates a text entity with the object information
    private func generateTextEntity(parent: Entity) {
        // Remove existing text if any
        textEntity?.removeFromParent()
        
        // Build text content
        var text = objectName
        text += "\n" + dimensions
        if let height = floorHeight {
            text += "\nHeight from floor: " + height
        }
        
        // Create the image containing our text
        let textImage = self.createTextImage(text: text)
        
        // Create a material with the text image
        let material = createMaterialWithImage(textImage)
        
        // Create a plane to display the text
        let textPlane = MeshResource.generatePlane(
            width: 0.38,
            height: 0.18,
            cornerRadius: 0.02
        )
        
        // Create the text entity with the material
        let entity = ModelEntity(mesh: textPlane, materials: [material])
        entity.position = [0, 0, 0.02] // Slightly in front of background
        
        parent.addChild(entity)
        self.textEntity = entity
        
        needsTextUpdate = false
    }
    
    /// Creates a material with the given UIImage
    private func createMaterialWithImage(_ image: UIImage) -> Material {
        // Convert UIImage to CGImage
        guard let cgImage = image.cgImage else {
            return SimpleMaterial(color: .yellow, roughness: 0, isMetallic: false)
        }
        
        do {
            // Create a temporary URL for saving the image
            let documentDirectory = FileManager.default.temporaryDirectory
            let imagePath = documentDirectory.appendingPathComponent(UUID().uuidString + ".png")
            
            // Save image to file
            try image.pngData()?.write(to: imagePath)
            
            // Load as texture
            let texture = try TextureResource.load(contentsOf: imagePath)
            
            // Create material with texture
            var material = SimpleMaterial(color: .white, roughness: 0, isMetallic: false)
            material.color = .init(tint: .white, texture: .init(texture))
            
            // Delete temporary file
            try FileManager.default.removeItem(at: imagePath)
            
            return material
        } catch {
            print("Error creating material: \(error)")
            return SimpleMaterial(color: .yellow, roughness: 0, isMetallic: false)
        }
    }
    
    /// Creates a UIImage from text for texture-based rendering
    private func createTextImage(text: String) -> UIImage {
        let textColor = UIColor.yellow
        let backgroundColor = UIColor.clear
        let width: CGFloat = 800
        let height: CGFloat = 400
        
        let size = CGSize(width: width, height: height)
        let renderer = UIGraphicsImageRenderer(size: size)
        
        let image = renderer.image { context in
            // Fill background
            backgroundColor.setFill()
            context.fill(CGRect(origin: .zero, size: size))
            
            // Configure text attributes
            let paragraphStyle = NSMutableParagraphStyle()
            paragraphStyle.alignment = .center
            paragraphStyle.lineBreakMode = .byWordWrapping
            
            let attributes: [NSAttributedString.Key: Any] = [
                .font: UIFont.boldSystemFont(ofSize: 48),
                .foregroundColor: textColor,
                .paragraphStyle: paragraphStyle
            ]
            
            // Calculate text rect
            let textRect = CGRect(x: 10, y: 10, width: width - 20, height: height - 20)
            
            // Draw text
            text.draw(in: textRect, withAttributes: attributes)
        }
        
        return image
    }
    
    /// Updates the label content
    /// - Parameters:
    ///   - name: New object name
    ///   - dimensions: New dimensions string
    ///   - floorHeight: New floor height
    func update(name: String, dimensions: String, floorHeight: String?) {
        var needsUpdate = false
        
        if self.objectName != name {
            self.objectName = name
            needsUpdate = true
        }
        
        if self.dimensions != dimensions {
            self.dimensions = dimensions
            needsUpdate = true
        }
        
        if self.floorHeight != floorHeight {
            self.floorHeight = floorHeight
            needsUpdate = true
        }
        
        if needsUpdate {
            // Get the parent entity that has the billboard component
            if let parent = self.children.first {
                generateTextEntity(parent: parent)
            }
        }
    }
    
    /// Perform any updates needed per frame
    func updateIfNeeded() {
        if needsTextUpdate {
            if let parent = self.children.first {
                generateTextEntity(parent: parent)
            }
        }
    }
} 
