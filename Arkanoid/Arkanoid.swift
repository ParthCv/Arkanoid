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
    
    var box2DWrapper: CBox2D!
        
    override init() {
        super.init()
        
//        box2d = b2World(b2gravity)
//        ballBodyDef = b2BodyDef()
//        ballBodyDef!.type = b2_dynamicBody
//        ballBodyDef!.position.Set(0.0, 0.0)
//        
//        ballBody = box2d?.CreateBody(UnsafePointer<b2BodyDef>(&ballBodyDef!))
//        
//        var circle: b2CircleShape = b2CircleShape()
//        circle.m_p.Set(2.0, 3.0)
//        circle.m_radius = 0.5
//        
//        var ballFixture: b2FixtureDef = b2FixtureDef()
//        
//        var circleAsShape  = circle as! b2Shape
//        ballFixture.shape = UnsafePointer<b2Shape>(&circleAsShape)
//        print(ballFixture.shape)
//        //ballBody.pointee.CreateFixture(&ballFixture)
        
        createBallNode()
        createCamera()
        box2DWrapper = CBox2D()
        
        let gameLoop = CADisplayLink(target: self, selector: #selector(update))
        gameLoop.preferredFrameRateRange = CAFrameRateRange(minimum: 120.0, maximum: 120.0, preferred: 120.0)
        gameLoop.add(to: RunLoop.main, forMode: RunLoop.Mode.default)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @objc
    private func update(displayLink: CADisplayLink) {
        print("Balls")
    }
    
    func createCamera() {
        let camera = SCNCamera()
        cameraNode.camera = camera
        
        cameraNode.position = SCNVector3(0, 50, 100)
        cameraNode.eulerAngles = SCNVector3(0, 0, 0)
        rootNode.addChildNode(cameraNode)
    }
    
    func createBallNode() {
        let ballGeo = SCNSphere(radius: 5)
        ballNode = SCNNode(geometry: ballGeo)
        ballNode.geometry?.firstMaterial?.diffuse.contents = UIColor.red
        ballNode.position = SCNVector3Make(0, 0, 0)
        rootNode.addChildNode(ballNode)
    }
    
}
