//
//  ImmersiveView.swift
//  studio
//
//  Created by Ariel Klevecz on 9/6/24.
//

import SwiftUI
import RealityKit
import RealityKitContent

struct ImmersiveView: View {
    var model = ViewModel()
    
    @State private var bubble: Entity?
    
    @State var predicate = QueryPredicate<Entity>.has(ModelComponent.self)
    @State var timer: Timer?
    
    
    
    var body: some View {
        RealityView { content in
            do {
                let immersiveContentEntity = try await Entity(named: "BubbleScene", in: realityKitContentBundle)
                model.contentEntity = immersiveContentEntity
                content.add(immersiveContentEntity)
                model.setupContentEntity()
                
                content.subscribe(to: CollisionEvents.Began.self) { event in
                    print("Entity A \(event.entityA.name) Entity B \(event.entityB.parent!.name)")
                    
                    if (event.entityA.name == "FingerTip" && event.entityB.name == "Bubble")
//                        || (event.entityA.name == "Bubble" && event.entityB.name == "FingerTip")
                    {
                        let bubbleEntity = event.entityA.name == "Bubble" ? event.entityA : event.entityB
                        animateAndRemoveEntity(bubbleEntity)
                    }
                    
                    if (event.entityB.name == "Mesh" && event.entityA.name == "FingerTip") {
                        event.entityB.applyTapForBehaviors()
                    }
                    
                }
                
            } catch {
                print("Error loading BubbleScene: \(error)")
            }
        }
        .task {
            await model.runArSessions()
        }
        .task {
            await model.processHandUpdates()
        }
        .task {
            await model.processObjectTracking()
        }
//        .gesture(SpatialTapGesture().targetedToEntity(where: predicate).onEnded({ value in
//            let entity = value.entity
//            if entity.name == "FingerTip" { return }
//            animateAndRemoveEntity(entity)
//        }))
//        .gesture(TapGesture().targetedToAnyEntity().onEnded({value in
//            _ = value.entity.applyTapForBehaviors()
//        }))
    }
    
    func animateAndRemoveEntity(_ entity: Entity) {
        guard var mat = entity.components[ModelComponent.self]?.materials.first as? ShaderGraphMaterial else {
            print("Error: Unable to get ShaderGraphMaterial in animate remove")
            return
        }
        
        // Play the sound
        if let audioResource = try? AudioFileResource.load(named: "backagain.aiff") {
            entity.playAudio(audioResource)
        } else {
            print("Failed to load audio resource")
        }
        
        let frameRate: TimeInterval = 1.0/120.0
        let duration: TimeInterval = 0.5
        let targetValue: Float = 1
        let totalFrames = Int(duration / frameRate)
        
        var currentFrame = 0
        var popValue: Float = 0
        
        timer?.invalidate()
        
        timer = Timer.scheduledTimer(withTimeInterval: frameRate, repeats: true) { timer in
            currentFrame += 1
            let progress = Float(currentFrame) / Float(totalFrames)
            
            popValue = progress * targetValue
            
            do {
                try mat.setParameter(name: "Pop", value: .float(popValue))
                entity.components[ModelComponent.self]?.materials = [mat]
            } catch {
                print("Error setting parameter: \(error)")
            }
            
            if currentFrame >= totalFrames {
                timer.invalidate()
                entity.removeFromParent()
                entity.stopAllAudio()
            }
        }
    }
}

#Preview(immersionStyle: .mixed) {
    ImmersiveView()
        .environment(AppModel())
}
