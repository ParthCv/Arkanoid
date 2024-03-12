//
//  Arkanoid.swift
//  Arkanoid
//
//  Created by Parth Chaturvedi on 2024-03-08.
//

var ball = 1

import SceneKit

class Arkanoid: SCNScene {
    
    //private var box2D: CBox2D!
    
//    let b2gravity:b2Vec2 = b2Vec2(0, 0)
//    
//    var box2d: b2World?
//    
//    var ballBodyDef: b2BodyDef?
//
//    var ballBody: OpaquePointer?

    var ballNode: SCNNode = SCNNode()
    
    var cameraNode : SCNNode = SCNNode()
    
    var brickNodes: [[SCNNode]] = [[SCNNode]]()
    
    var paddleNode: SCNNode = SCNNode()
    
    var box2DWrapper: CBox2D!
        
    override init() {
        super.init()
        
        for _ in 1...BRICK_ROWS {
            var row = [SCNNode]()
            for _ in 1...BRICK_COLS {
                row.append(SCNNode())
            }
            brickNodes.append(row)
        }
        
        createBallNode()
        createCamera()
        box2DWrapper = CBox2D()
        createBricks()
        createPaddle()
        
        let gameLoop = CADisplayLink(target: self, selector: #selector(update))
        gameLoop.preferredFrameRateRange = CAFrameRateRange(minimum: 120.0, maximum: 120.0, preferred: 120.0)
        gameLoop.add(to: RunLoop.main, forMode: RunLoop.Mode.default)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @objc
    private func update(displayLink: CADisplayLink) {
        
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
        ballNode.position = SCNVector3Make(Float(BALL_POS_X),
                                           Float(BALL_POS_Y),
                                           0)
        rootNode.addChildNode(ballNode)
    }
    
    func createPaddle() {
        let paddleGeo = SCNBox(width: CGFloat(PADDLE_WIDTH), height: CGFloat(PADDLE_HEIGHT), length: 0.5, chamferRadius: 0.5)
        let paddleMat = SCNMaterial()
        paddleMat.diffuse.contents = UIColor.gray
        paddleGeo.materials = [paddleMat]
        
        paddleNode = SCNNode(geometry: paddleGeo)
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
                
                self.rootNode.addChildNode(brickNode)
                
                brickNodes[Int(row)][Int(col)] = brickNode
            }
            
        }
    }
    
    @MainActor
    func handlePaddleMovement(offset: CGSize) {
        let paddlePosX = paddleNode.position.x
        paddleNode.position.x = paddlePosX + Float(offset.height)/10
        print("paddle pos - ", paddleNode.position)
    }

    
}
