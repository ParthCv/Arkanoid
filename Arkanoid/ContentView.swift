//
//  ContentView.swift
//  Arkanoid
//
//  Created by Parth Chaturvedi on 2024-03-08.
//

import SwiftUI
import SceneKit

struct ContentView: View {
    var body: some View {
        let scene = Arkanoid()
        SceneView(scene: scene, pointOfView: scene.cameraNode)
            .onTapGesture {
                
            }
            .gesture(
                DragGesture().onChanged({ gesture in
                    scene.handlePaddleMovement(offset: gesture.translation)
                })
            )
    }
}

#Preview {
    ContentView()
}
