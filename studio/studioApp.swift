//
//  studioApp.swift
//  studio
//
//  Created by Ariel Klevecz on 9/6/24.
//

import SwiftUI

@main
struct studioApp: App {

    @State private var appModel = AppModel()
    
    init() {
        BubbleSystem.registerSystem()
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(appModel)
        }

        ImmersiveSpace(id: appModel.immersiveSpaceID) {
            ImmersiveView()
                .environment(appModel)
                .onAppear {
                    appModel.immersiveSpaceState = .open
                }
                .onDisappear {
                    appModel.immersiveSpaceState = .closed
                }
        }
        .immersionStyle(selection: .constant(.mixed), in: .mixed)
     }
}
