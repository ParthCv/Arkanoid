//
//  ScoreManager.swift
//  Arkanoid
//
//  Created by Vinod Bandla on 2024-03-14.
//

import SwiftUI

class ScoreManager: ObservableObject{
    @Published var score = 0
    
    func incrementScore(){
        score += 100
        print(String(score))
    }
}
