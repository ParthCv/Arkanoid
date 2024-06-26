//
//  Arkanoid.swift
//  Arkanoid
//
//  Created by Parth Chaturvedi on 2024-03-08.
//

import SceneKit
import SwiftUI

class Arkanoid: SCNScene, ObservableObject {
    
    var ballNode: SCNNode = SCNNode()
    
    var cameraNode : SCNNode = SCNNode()
    
    var brickNodes: [[SCNNode]] = [[SCNNode]]()
    
    var paddleNode: SCNNode = SCNNode()
    
    var box2DWrapper: CBox2D!
    
    var lastTime = CFTimeInterval(floatLiteral: 0)
    
    @Published var ballsLeft = 5
    
    @Published var score = 0
    
    override init() {
        
        super.init()
        
        box2DWrapper = CBox2D()
        buildGame()
        
        let gameLoop = CADisplayLink(target: self, selector: #selector(update))
        gameLoop.preferredFrameRateRange = CAFrameRateRange(minimum: 120.0, maximum: 120.0, preferred: 120.0)
        gameLoop.add(to: RunLoop.main, forMode: RunLoop.Mode.default)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @MainActor
    @objc
    private func update(displayLink: CADisplayLink) {
        if (lastTime != CFTimeInterval(floatLiteral: 0)) {  // if it's the first frame, just update lastTime
            let elapsedTime = displayLink.targetTimestamp - lastTime    // calculate elapsed time
            updateGameObjects(elapsedTime: elapsedTime) // update all the game objects
        }
        lastTime = displayLink.targetTimestamp
    }
    
    @MainActor
    private func updateGameObjects(elapsedTime: CFTimeInterval) {
        // Update Box2D physics simulation
        box2DWrapper.update(Float(elapsedTime))
        
        // Get ball position and update ball node
        let ballPos = UnsafePointer(box2DWrapper.getObject("Ball"))
        
        ballNode.position.x = (ballPos?.pointee.loc.x)!
        ballNode.position.y = (ballPos?.pointee.loc.y)!
        
        for i in 0..<BRICK_ROWS {
            for j in 0..<BRICK_COLS {
                let brick = UnsafePointer(box2DWrapper.getObject("Brick_\(j)_\(i)"))
                if (brick == nil && !brickNodes[Int(i)][Int(j)].isHidden) {
                    brickNodes[Int(i)][Int(j)].isHidden = true
                    incrementScore()
                }
            }
        }
        
        let paddlePos = UnsafePointer(box2DWrapper.getObject("Paddle"))
        paddleNode.position.x = (paddlePos?.pointee.loc.x)!
        paddleNode.position.y = (paddlePos?.pointee.loc.y)!
        
        // Check y pos of ball
        if(ballNode.position.y < KILL_ZONE){
            ballsLeft = ballsLeft - 1
            if ballsLeft == 0 {
                print("Game Over!")
                print("Total score was:  \(score)")
                resetGame()
            }
            resetBall()
        }
    }
    
    
    func createCamera() {
        let camera = SCNCamera()
        cameraNode.camera = camera
        cameraNode.position = SCNVector3(0, 50, 100)
        cameraNode.eulerAngles = SCNVector3(0, 0, 0)
        rootNode.addChildNode(cameraNode)
    }
    
    func createBallNode() {
        let ballGeo = SCNSphere(radius: CGFloat(BALL_RADIUS))
        ballNode = SCNNode(geometry: ballGeo)
        ballNode.geometry?.firstMaterial?.diffuse.contents = UIColor.red
        ballNode.position = SCNVector3Make(
            Float(BALL_POS_X),
            Float(BALL_POS_Y),
            0
        )
        ballNode.name = "Ball"
        box2DWrapper.createBallBody()
        rootNode.addChildNode(ballNode)
    }
    
    func createPaddle() {
        let paddleGeo = SCNBox(width: CGFloat(PADDLE_WIDTH), height: CGFloat(PADDLE_HEIGHT), length: 0.5, chamferRadius: 0.5)
        let paddleMat = SCNMaterial()
        paddleMat.diffuse.contents = UIColor.gray
        paddleGeo.materials = [paddleMat]
        paddleNode = SCNNode(geometry: paddleGeo)
        paddleNode.position = SCNVector3Make(
            Float(PADDLE_POS_X),
            Float(PADDLE_POS_Y),
            0
        )
        paddleNode.name = "Paddle"
        box2DWrapper.createPaddleBody()
        self.rootNode.addChildNode(paddleNode)
    }
    
    func createBricks() {
        let brickGeo = SCNBox(width: CGFloat(BRICK_WIDTH), height: CGFloat(BRICK_HEIGHT), length: 0.5, chamferRadius: 0)
        let brickMat = SCNMaterial()
        brickMat.diffuse.contents = UIColor.green
        brickGeo.materials = [brickMat]
        
        for row in 0..<BRICK_ROWS {
            for col in 0..<BRICK_COLS {
                let brickNode = SCNNode(geometry: brickGeo)
                brickNode.position = SCNVector3(
                    Float(col) * (BRICK_WIDTH + BRICK_SPACING) + Float(BRICK_POS_X),
                    Float(row) * (BRICK_HEIGHT + BRICK_SPACING) + Float(BRICK_POS_Y),
                    0
                )
                var objName = "Brick_\(row)_\(col)"
                brickNode.name = objName
                box2DWrapper.createBrick(row, andCol: col, andName: &objName)
                self.rootNode.addChildNode(brickNode)
                brickNodes[Int(row)][Int(col)] = brickNode
            }
            
        }
    }
    
    func createWalls(){
        let wallGeo = SCNBox(width: CGFloat(WALL_WIDTH), height:CGFloat(WALL_HEIGHT), length: 0.1, chamferRadius: 0.0)
        let wallMat = SCNMaterial()
        wallMat.diffuse.contents = UIColor.brown
        wallGeo.materials = [wallMat]
        
        let wallLeft = SCNNode(geometry: wallGeo)
        let wallRight = SCNNode(geometry: wallGeo)
        let wallTop = SCNNode(geometry: wallGeo)
        
        wallLeft.position = SCNVector3(WALL_LEFT_POS_X, WALL_POS_Y, 0)
        wallRight.position = SCNVector3(WALL_RIGHT_POX_X, WALL_POS_Y, 0)
        wallTop.position = SCNVector3(WALL_LEFT_POS_X, WALL_POS_Y, 0)
        wallTop.eulerAngles = SCNVector3(0,0,Float.pi/2)
        
        box2DWrapper.createWallBodies()
        
        self.rootNode.addChildNode(wallLeft)
        self.rootNode.addChildNode(wallRight)
        self.rootNode.addChildNode(wallTop)
    }
    
    @MainActor
    func handlePaddleMovement(offset: CGSize) {
        let newXPos = Float(offset.width) * 0.005
        box2DWrapper.updatePaddle(newXPos)
    }
    
    //  @MainActor
    func resetBall(){
        box2DWrapper.reset()
    }
    
    @MainActor
    func incrementScore(){
        DispatchQueue.main.async {
            self.score += 100
            // print(String(self.score))
        }
        
    }
    
    func buildGame(){
        for _ in 1...BRICK_ROWS {
            var row = [SCNNode]()
            for _ in 1...BRICK_COLS {
                row.append(SCNNode())
            }
            brickNodes.append(row)
        }
        createCamera()
        createWalls()
        createBricks()
        createPaddle()
        createBallNode()
    }
    
    @MainActor
    func resetGame(){
        box2DWrapper.resetGame()
        for row in 0..<BRICK_ROWS {
            for col in 0..<BRICK_COLS {
                brickNodes[Int(row)][Int(col)].removeFromParentNode()
            }
            
        }
        brickNodes.removeAll()
        ballNode.removeFromParentNode()
        paddleNode.removeFromParentNode()
        buildGame()
        score = 0
        ballsLeft = 5
    }
}
