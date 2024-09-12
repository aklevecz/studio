//
//  ViewModel.swift
//  studio
//
//  Created by Ariel Klevecz on 9/7/24.
//
import RealityKit
import RealityKitContent
import ARKit
import Combine
import Observation
import UIKit

private extension ModelEntity {
    class func createFingertip() -> ModelEntity {
        let entity = ModelEntity(
            mesh: .generateSphere(radius:0.01),
            materials: [UnlitMaterial(color: .red)],
            collisionShape: .generateSphere(radius:0.01),
            mass: 0.0
        )
        
        entity.components.set(OpacityComponent(opacity:1.0))
        entity.components.set(CollisionComponent(shapes: [.generateSphere(radius:0.01)], mode: .trigger))
        entity.components.set(InputTargetComponent())
        entity.name = "FingerTip"
        
        return entity
    }
}

// This could be abstracted into different models
// Like bubble model
// and hand + scene model --- I think? because they could all share the same root entity and such
@Observable @MainActor
final class ViewModel {
    var contentEntity: Entity?
    private let arKitSession = ARKitSession()
    
    private let handTracking = HandTrackingProvider()
    private let sceneReconstruction = SceneReconstructionProvider()
    private var objectTracking: ObjectTrackingProvider!
    
    private let fingerEntities: [HandAnchor.Chirality: ModelEntity] = [
        .left: .createFingertip(),
        .right: .createFingertip()
    ]
    
    private var mushroomEntity: Entity?
    
    private var meshEntities = [UUID: ModelEntity]()
    private var objectEntities = [String: Entity]()

    var bubble: Entity?
    
//    func generateDistinctCGColor() -> CGColor {
//        let hue = CGFloat.random(in: 0...1)
//        let saturation = CGFloat.random(in: 0.5...1) // Ensure some level of saturation
//        let brightness = CGFloat.random(in: 0.5...1) // Ensure some level of brightness
//        
//        return UIColor(hue: hue, saturation: saturation, brightness: brightness, alpha: 1.0).cgColor
//    }
    
    
    func generateDistinctCGColor() -> CGColor {
        let red = CGFloat.random(in: 0.5...1)
        let green = CGFloat.random(in: 0.5...1)
        let blue = CGFloat.random(in: 0.5...1)
        
        return UIColor(red: red, green: green, blue: blue, alpha: 1.0).cgColor
    }
    
    func setupContentEntity() {
        guard let contentEntity else { return }
        
        for entity in fingerEntities.values {
            contentEntity.addChild(entity)
        }
        
        bubble = contentEntity.findEntity(named: "Bubble")
            if let bubble = bubble {
                print("Bubble found")

            
                for _ in 1...100 {
                    let bubbleClone = bubble.clone(recursive: true)
//                    guard var bubbleComponent = bubbleClone.components[BubbleComponent.self] else { return }
//                    bubbleComponent.direction = [
//                        Float.random(in: -1...1),
//                        Float.random(in: -1...1),
//                        Float.random(in: -1...1)
//                    ]
//                    bubbleClone.components[BubbleComponent.self] = bubbleComponent
                    
//                    var pb = PhysicsBodyComponent()
//                    pb.linearDamping = 0
//                    pb.isAffectedByGravity = false
//                    
//                    bubbleClone.components[PhysicsBodyComponent.self] = pb
//                    
//                    let velocityRange = Float.random(in: -0.01...0.01)
//                    let linearVelocity = SIMD3<Float>(
//                        x: velocityRange,
//                        y: velocityRange,
//                        z: velocityRange
//                    )
//                    
//                    let pm = PhysicsMotionComponent(linearVelocity: linearVelocity)
//                    bubbleClone.components[PhysicsMotionComponent.self] = pm
                    
                    bubbleClone.position = SIMD3<Float>(
                        x: Float.random(in: -2...2),
                        y: Float.random(in: 0...5),
                        z: Float.random(in: -4...4)
                    )
                    
                    guard var mat = bubbleClone.components[ModelComponent.self]?.materials.first as? ShaderGraphMaterial else {
                        print("Error: Unable to get ShaderGraphMaterial in bubble clone setup")
                        return
                    }
                    
                    let randomVec3 = SIMD3<Float>(
                        x: Float.random(in: 0.0...0.25),
                        y: Float.random(in: 0.0...0.25),
                        z: Float.random(in: 0.0...0.25)
                    )
                    
                    let noiseOffset1 = SIMD3<Float>(
                        x: Float.random(in: 0.0...0.25),
                        y: Float.random(in: 0.0...0.25),
                        z: Float.random(in: 0.0...0.25)
                    )
                    
                    let noiseOffset2 = SIMD3<Float>(
                        x: Float.random(in: 0.0...0.25),
                        y: Float.random(in: 0.0...0.25),
                        z: Float.random(in: 0.0...0.25)
                    )
                    
                    let noiseOffset3 = SIMD3<Float>(
                        x: Float.random(in: 0.0...0.25),
                        y: Float.random(in: 0.0...0.25),
                        z: Float.random(in: 0.0...0.25)
                    )
                    
                    let randomGeometryAnimationSpeed = Float.random(in: 0.0...0.5)
                    
                    let randomAnimationSpeed = Float.random(in: 0.01...0.05)
                    
                    let randomColor1 = generateDistinctCGColor()
                    let randomColor2 = generateDistinctCGColor()
                    let randomColor3 = generateDistinctCGColor()
                    
//                    let randomDiffuseColor = generateDistinctCGColor()
                    
                    do {
                        try mat.setParameter(name: "GeometryTimeOffset", value: .simd3Float(randomVec3))
                        try mat.setParameter(name: "GeometryAnimationSpeed", value: .float(randomGeometryAnimationSpeed))
                        
                        try mat.setParameter(name: "NoiseOffset1", value: .simd3Float(noiseOffset1))
                        try mat.setParameter(name: "NoiseOffset2", value: .simd3Float(noiseOffset2))
                        try mat.setParameter(name: "NoiseOffset3", value: .simd3Float(noiseOffset3))
                        
                        try mat.setParameter(name: "AnimationSpeed", value: .float(randomAnimationSpeed))
                        try mat.setParameter(name: "Color1", value: .color(randomColor1))
                        try mat.setParameter(name: "Color2", value: .color(randomColor2))
                        try mat.setParameter(name: "Color3", value: .color(randomColor3))
                        
//                        try mat.setParameter(name: "DiffuseColor", value: .color(randomDiffuseColor))
                        bubbleClone.components[ModelComponent.self]?.materials = [mat]
                    } catch {
                        print("Error setting parameters: \(error)")
                    }
                    
                    let randomNoiseScale = Float.random(in: 10.0...100.0)
                    
                    do {
                        try mat.setParameter(name: "NoiseScale", value: .float(randomNoiseScale))
                        bubbleClone.components[ModelComponent.self]?.materials = [mat]
                    } catch {
                        print("Error setting parameters: \(error)")
                    }
                    
                    contentEntity.addChild(bubbleClone)
                }
        }
    }
    
    func loadRefObject(name: String) async -> ReferenceObject? {
        guard let refObjURL = Bundle.main.url(forResource: name, withExtension: ".referenceobject") else {
            print("Failed to find reference object file")
            return nil
        }
        
        do {
            let refObject = try await ReferenceObject(from: refObjURL)
            
            guard let usdzFileURL = refObject.usdzFile else {
                print("Failed to load USZD file from reference object")
                return nil
            }
            var entity = try await Entity(contentsOf: usdzFileURL)
            if (name == "mushroom-model") {
                print("Found a mushroom")
                if let mushroomEntity = contentEntity?.findEntity(named: "Mushroom") {
                    print("setting entity to mushroom thing")
                    entity = mushroomEntity
                    print(entity)
                }
            }
            objectEntities[name] = entity
            return refObject
        } catch {
            print("Error loading entity: \(error)")
        }
        return nil
    }
    
    func runArSessions() async {
        do {
            // Maybe not kill the whole AR Session if these don't load
            guard let boneRefObject = await loadRefObject(name: "Bone") else {
                print("Eror loading reference object: Bone")
                return
            }
            
            guard let mushroomRefObject = await loadRefObject(name: "mushroom-model") else {
                print("Error loading reference object: mushroom-model")
                return
            }
            
            guard let purpRefObject = await loadRefObject(name: "Purp") else {
                print("Error loading reference object: Purp")
                return
            }
            // Set up object tracking
            objectTracking = ObjectTrackingProvider(referenceObjects: [boneRefObject, mushroomRefObject, purpRefObject])
            
            // Run ARKitSession with hand tracking, scene reconstruction, and object tracking
            try await arKitSession.run([handTracking, sceneReconstruction, objectTracking])
            
            // Set up and run SpatialTrackingSession
//            let spatialTrackingConfig = SpatialTrackingSession.Configuration(tracking: [.object, .world, .hand])
//            try await spatialTrackingSession.run(spatialTrackingConfig)
            
            print("Both ARKitSession and SpatialTrackingSession started successfully")
        } catch {
            print("Failed to start sessions with error: \(error)")
        }
    }
    
    func createSphereEntity() -> Entity {
        let entity = ModelEntity(
            mesh: .generateSphere(radius: 0.1),
            materials: [SimpleMaterial(color: .cyan, isMetallic: true)],
            collisionShape: .generateSphere(radius: 0.1),
            mass: 0.0)
        
        let physicsBodyComponent = PhysicsBodyComponent(
            massProperties: .default,
            material: .default,
            mode: .static
        )
            entity.components.set(physicsBodyComponent)
        entity.components.set(CollisionComponent(shapes: [.generateSphere(radius: 0.1)], mode: .trigger))
        entity.components.set(InputTargetComponent())
        entity.name = "Spherething"
        entity.position = [0, 1, -0.5]
        return entity
    }
    
    func processObjectTracking() async {
        while objectTracking == nil {
            await Task.yield()
        }
        
        guard let objectTracking = objectTracking else {
            print("ObjectTrackingProvider not initialized")
            return
        }
        for await anchorUpdate in objectTracking.anchorUpdates {
            let anchor = anchorUpdate.anchor
            let id = anchor.id
            let objectTransform = anchor.originFromAnchorTransform

            switch anchorUpdate.event {
            case .added:
                print("Anchor Added")
                print(anchor)
                print(anchor.referenceObject.name)
                print(anchor.id)
                
                guard let entity = objectEntities[anchor.referenceObject.name] else {
                    print("Mesh entity with name \(anchor.referenceObject.name) not available")
                    return
                }
                
                guard let contentEntity = contentEntity else {
                    print("Content entity not available")
                    return
                }
                
                entity.setTransformMatrix(objectTransform, relativeTo: nil)
                contentEntity.addChild(entity)
                
                // Find the actual model within the USDZ hierarchy
                let modelEntity = findModelEntity(in: entity)
                
                // Set initial scale to make the animation more noticeable
                modelEntity.scale = [1.1, 1.1, 1.1]
                
                // Animate to full scale
                let fullScale: Float = 2.0
                let animationDuration: TimeInterval = 1.0
                
                modelEntity.move(
                    to: Transform(scale: [fullScale, fullScale, fullScale]),
                    relativeTo: modelEntity.parent,
                    duration: animationDuration,
                    timingFunction: .easeInOut
                )
                
                print("Animation started for \(anchor.referenceObject.name)")
            case .updated:
                guard let entity = objectEntities[anchor.referenceObject.name] else {
                    print("Mesh entity with name \(anchor.referenceObject.name) not available")
                    return
                }
                entity.setTransformMatrix(objectTransform, relativeTo: nil)
            case .removed:
                  print("Anchor removed")
            }
        }
    }

    func processHandUpdates() async {
        for await update in handTracking.anchorUpdates {
            let handAnchor = update.anchor
            
            guard handAnchor.isTracked else { continue }
            guard let fingertip = handAnchor.handSkeleton?.joint(.indexFingerTip) else { continue }
            guard fingertip.isTracked else { continue }
            
            let originFromAnchor = handAnchor.originFromAnchorTransform
            let anchorFromIndexTip = fingertip.anchorFromJointTransform
            let originFromIndexTip = originFromAnchor * anchorFromIndexTip
            
            let fingertipEntity = fingerEntities[handAnchor.chirality]!
            await fingertipEntity.setTransformMatrix(originFromIndexTip, relativeTo: nil)
        }
    }
    
    func processReconstructionUpdates() async {
        for await update in sceneReconstruction.anchorUpdates {
            let meshAnchor = update.anchor
            
            guard let shape = try? await ShapeResource.generateStaticMesh(from: meshAnchor) else {continue}
            
            switch update.event {
            case .added:
                guard let contentEntity else { return }
                let entity = ModelEntity()
                entity.transform = Transform(matrix: meshAnchor.originFromAnchorTransform)
                entity.collision = CollisionComponent(shapes: [shape], isStatic:true)
                entity.physicsBody = PhysicsBodyComponent(shapes: [shape], mass: 0.0 )
                entity.components.set(InputTargetComponent())
                entity.name="room"
                meshEntities[meshAnchor.id] = entity
                contentEntity.addChild(entity)
            case .updated:
                guard let entity = meshEntities[meshAnchor.id] else { fatalError("...") }
                entity.transform = Transform(matrix: meshAnchor.originFromAnchorTransform)
                entity.collision?.shapes = [shape]
            case .removed:
                meshEntities[meshAnchor.id]?.removeFromParent()
                meshEntities.removeValue(forKey: meshAnchor.id)
            @unknown default:
                fatalError("Unsupported anchor event")
            }
        }
        
    }
}

func findModelEntity(in entity: Entity) -> Entity {
    if entity is ModelEntity {
        return entity
    }
    for child in entity.children {
        let foundEntity = findModelEntity(in: child)
        if foundEntity is ModelEntity {
            return foundEntity
        }
    }
    return entity  // Fallback to the original entity if no ModelEntity is found
}
