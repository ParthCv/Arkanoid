//
//  ContentView.swift
//  Arkanoid
//
//  Created by Parth Chaturvedi on 2024-03-08.
//

import SwiftUI
import SceneKit

struct ContentView: View {
    
    @ObservedObject var scene = Arkanoid()
    var body: some View {
        // sets a state variable to change whenever the score manager's score changes
        @State var scoreToPost = scene.score
        SceneView(scene: scene, pointOfView: scene.cameraNode)
            .onTapGesture(count: 2, perform: {
                scene.box2DWrapper.launchBall()
            })
            .gesture(
                DragGesture().onChanged({ gesture in
                    scene.handlePaddleMovement(offset: gesture.translation)
                })
            )
        HStack{
            Text("Score: \(scoreToPost)")
            Button(action: {scene.incrementScore()}){
                Text("Increment Score")
            }.padding()
        }
    }
}

#Preview {
    ContentView()
}
