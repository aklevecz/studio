//
//  BubbleSystem.swift
//  studio
//
//  Created by Ariel Klevecz on 9/6/24.
//
import RealityKit
import RealityKitContent
class BubbleSystem: System {
    private let query = EntityQuery(where: .has(BubbleComponent.self))
    private let speed: Float = 0.1
    required init(scene:Scene) {
        
    }
    
    func update(context: SceneUpdateContext) {
        context.scene.performQuery(query).forEach { bubble in
            guard let bubbleComponent = bubble.components[BubbleComponent.self] else { return }
            bubble.position += bubbleComponent.direction * speed
        }
    }
    
}
