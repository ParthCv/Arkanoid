//====================================================================
//
// (c) Borna Noureddin
// COMP 8051   British Columbia Institute of Technology
// Objective-C++ wrapper for Box2D library
//
//====================================================================

#include <Box2D/Box2D.h>
#include "CBox2D.h"
#include <stdio.h>
#include <map>
#include <string>
#include <cstring>
#include <math.h>


// Some Box2D engine paremeters
const float MAX_TIMESTEP = 1.0f/60.0f;
const int NUM_VEL_ITERATIONS = 10;
const int NUM_POS_ITERATIONS = 3;


#pragma mark - Box2D contact listener class

// This C++ class is used to handle collisions
class CContactListener : public b2ContactListener
{
    
public:
    
    void BeginContact(b2Contact* contact) {};
    
    void EndContact(b2Contact* contact) {};
    
    void PreSolve(b2Contact* contact, const b2Manifold* oldManifold)
    {
        
        b2WorldManifold worldManifold;
        contact->GetWorldManifold(&worldManifold);
        b2PointState state1[2], state2[2];
        b2GetPointStates(state1, state2, oldManifold, contact->GetManifold());
        
        if (state2[0] == b2_addState)
        {
            
            // Use contact->GetFixtureA()->GetBody() to get the body that was hit
            b2Fixture* bodyA = contact->GetFixtureA();
            
            //bodyA->m_userData;
            
            // Get the PhysicsObject as the user data, and then the CBox2D object in that struct
            // This is needed because this handler may be running in a different thread and this
            //  class does not know about the CBox2D that's running the physics
            struct PhysicsObject *objData = (struct PhysicsObject *)(bodyA->GetBody()->GetUserData());
            
            CBox2D *parentObj = (__bridge CBox2D *)(objData->box2DObj);
            b2Body *shapePtr = ((b2Body *)objData->b2ShapePtr);
            //void* b2 = (objData->b2ShapePtr);
            
            char *name = ((char *)bodyA->GetUserData());
            
            if (objData->objType == ObjTypeBox) {
                // Call RegisterHit (assume CBox2D object is in user data)
                [parentObj RegisterHit:name];    // assumes RegisterHit is a callback function to register collision
            }
            
        }
        
    }
    
    void PostSolve(b2Contact* contact, const b2ContactImpulse* impulse) {};
    
};


#pragma mark - CBox2D

@interface CBox2D ()
{
    
    // Box2D-specific objects
    b2Vec2 *gravity;
    b2World *world;
    CContactListener *contactListener;
    float totalElapsedTime;
    
    // Map to keep track of physics object to communicate with the renderer
    std::map<std::string, struct PhysicsObject *> physicsObjects;

    // Logit for this particular "game"
    bool ballHitBrick;  // register that the ball hit the break
    bool ballLaunched;  // register that the user has launched the ball
    
    PhysicsObject* objectToBeDeleted;
    
}
@end

@implementation CBox2D

- (instancetype)init
{
    
    self = [super init];
    
    if (self) {
        // Initialize Box2D
        gravity = new b2Vec2(0.0f, 0.0f);
        world = new b2World(*gravity);

        contactListener = new CContactListener();
        world->SetContactListener(contactListener);
        
        totalElapsedTime = 0;
        ballHitBrick = false;
        ballLaunched = false;
        objectToBeDeleted = nil;
    }
    
    return self;
    
}

- (void)createBallBody {
    struct PhysicsObject *newObj = new struct PhysicsObject;
    newObj = new struct PhysicsObject;
    newObj->loc.x = BALL_POS_X;
    newObj->loc.y = BALL_POS_Y;
    newObj->objType = ObjTypeCircle;
    char* objName = strdup("Ball");
    [self AddObject:objName newObject:newObj isDynamic:true userData:objName];
}

- (void)createPaddleBody {
    struct PhysicsObject *newObj = new struct PhysicsObject;
    
    newObj = new struct PhysicsObject;
    newObj->loc.x = PADDLE_POS_X;
    newObj->loc.y = PADDLE_POS_Y;
    newObj->objType = ObjTypePaddle;
    char* objName = strdup("Paddle");
    [self AddObject:objName newObject:newObj isDynamic:false userData:objName];

}

- (void)createWallBodies {
    struct PhysicsObject *newObj = new struct PhysicsObject;
    
    newObj = new struct PhysicsObject;
    newObj->loc.x = WALL_LEFT_POS_X;
    newObj->loc.y = WALL_POS_Y;
    newObj->objType = ObjTypeWall;
    char* objName = strdup("Wall_left");
    [self AddObject:objName newObject:newObj isDynamic:false userData:objName];

    newObj = new struct PhysicsObject;
    newObj->loc.x = WALL_RIGHT_POX_X;
    newObj->loc.y = WALL_POS_Y;
    newObj->objType = ObjTypeWall;
    objName = strdup("Wall_right");
    [self AddObject:objName newObject:newObj isDynamic:false userData:objName];
    
    newObj = new struct PhysicsObject;
    newObj->loc.x = WALL_LEFT_POS_X;
    newObj->loc.y = WALL_POS_Y;
    newObj->loc.theta = M_PI/2;
    newObj->objType = ObjTypeWall;
    objName = strdup("Wall_top");
    [self AddObject:objName newObject:newObj isDynamic:false userData:objName];
}

- (void)createBrick:(int)row andCol:(int)col andName:(char *)name {
    struct PhysicsObject *newObj = new struct PhysicsObject;
    newObj = new struct PhysicsObject;
    newObj->loc.x = row * (BRICK_WIDTH + BRICK_SPACING) + BRICK_POS_X;
    newObj->loc.y = col * (BRICK_HEIGHT + BRICK_SPACING) + BRICK_POS_Y;
    newObj->objType = ObjTypeBox;
    char * objName = strdup(name);
    [self AddObject:objName newObject:newObj isDynamic:false userData:objName];
}

- (void)dealloc
{
    if (gravity) delete gravity;
    if (world) delete world;
    if (contactListener) delete contactListener;
}

-(void)Update:(float)elapsedTime
{
    
    // Get pointers to the ball physics objects
    struct PhysicsObject *theBall = physicsObjects["Ball"];
    
    // Check if it is time yet to drop the brick, and if so call SetAwake()
    totalElapsedTime += elapsedTime;   
    
    // If the last collision test was positive, stop the ball and destroy the brick
    if (ballHitBrick)
    {
        
        ballHitBrick = false;   // until a reset and re-launch
        
    }
    
    if (world)
    {
        
        while (elapsedTime >= MAX_TIMESTEP)
        {
            world->Step(MAX_TIMESTEP, NUM_VEL_ITERATIONS, NUM_POS_ITERATIONS);
            elapsedTime -= MAX_TIMESTEP;
        }
        
        if (elapsedTime > 0.0f)
        {
            world->Step(elapsedTime, NUM_VEL_ITERATIONS, NUM_POS_ITERATIONS);
        }
        
    }
    
    if (objectToBeDeleted != nil) {
        ((b2Body *)objectToBeDeleted->b2ShapePtr)->SetAwake(false);
        ((b2Body *)objectToBeDeleted->b2ShapePtr)->SetActive(false);
        objectToBeDeleted = nil;
    }
    
    // Update each node based on the new position from Box2D
    for (auto const &b:physicsObjects) {
        if (b.second && b.second->b2ShapePtr) {
            b.second->loc.x = ((b2Body *)b.second->b2ShapePtr)->GetPosition().x;
            b.second->loc.y = ((b2Body *)b.second->b2ShapePtr)->GetPosition().y;
        }
    }
    
}

-(void)RegisterHit:(char *)objName
{
    // Set some flag here for processing later...
    ballHitBrick = false;
    
    objectToBeDeleted = physicsObjects[objName];
    physicsObjects.erase(objName);
}

-(void)LaunchBall
{
    // Check here if we need to launch the ball
    //  and if so, use ApplyLinearImpulse() and SetActive(true)
    if (!ballLaunched)
    {
        struct PhysicsObject *theBall = physicsObjects["Ball"];
        // Apply a force (since the ball is set up not to be affected by gravity)
        ((b2Body *)theBall->b2ShapePtr)->ApplyLinearImpulse(b2Vec2(0, -BALL_VELOCITY),
                                                            ((b2Body *)theBall->b2ShapePtr)->GetPosition(),
                                                            true);
        ((b2Body *)theBall->b2ShapePtr)->SetActive(true);

        // Set some flag here for processing later...
        ballLaunched = true;
    }
}

-(void) AddObject:(char *)name newObject:(struct PhysicsObject *)newObj isDynamic:(bool)isDynamic userData:(char *)userData
{
    
    // Set up the body definition and create the body from it
    b2BodyDef bodyDef;
    b2Body *theObject;
    bodyDef.type = isDynamic ? b2_dynamicBody: b2_staticBody;
    bodyDef.position.Set(newObj->loc.x, newObj->loc.y);
    bodyDef.angle = newObj->loc.theta;
    theObject = world->CreateBody(&bodyDef);
    if (!theObject) return;
    
    // Setup our physics object and store this object and the shape
    newObj->b2ShapePtr = (void *)theObject;
    newObj->box2DObj = (__bridge void *)self;
    
    // Set the user data to be this object and keep it asleep initially
    theObject->SetUserData(newObj);
    theObject->SetAwake(false);
    
    // Based on the objType passed in, create a box or circle
    b2PolygonShape dynamicBox;
    b2CircleShape circle;
    b2FixtureDef fixtureDef;
    b2PolygonShape polygon;
    b2Vec2 verticies[8];
    
    switch (newObj->objType) {
            
        case ObjTypeBox:
            dynamicBox.SetAsBox(BRICK_WIDTH/2, BRICK_HEIGHT/2);
            fixtureDef.shape = &dynamicBox;
            fixtureDef.density = 1.0f;
            fixtureDef.friction = 0.3f;
            fixtureDef.restitution = 1.0f;
            
            break;
            
        case ObjTypeCircle:
            circle.m_radius = BALL_RADIUS;
            fixtureDef.shape = &circle;
            fixtureDef.density = 1.0f;
            fixtureDef.friction = 0.0f;
            fixtureDef.restitution = 1.0f;
            
            break;
            
        case ObjTypeWall:
            
            dynamicBox.SetAsBox(WALL_WIDTH/2, WALL_HEIGHT/2);
            fixtureDef.shape = &dynamicBox;
            fixtureDef.density = 1.0f;
            fixtureDef.friction = 0.3f;
            fixtureDef.restitution = 1.0f;
                        
            break;
            
        case ObjTypePaddle:
            
            verticies[0].Set(-PADDLE_WIDTH/2, -PADDLE_HEIGHT/2);
            verticies[1].Set(PADDLE_WIDTH/2, -PADDLE_HEIGHT/2);
            verticies[2].Set(-PADDLE_WIDTH/4, PADDLE_HEIGHT/2);
            verticies[3].Set(PADDLE_WIDTH/4, PADDLE_HEIGHT/2);
            verticies[4].Set(-PADDLE_WIDTH/16, PADDLE_HEIGHT/2);
            verticies[5].Set(PADDLE_WIDTH/16, PADDLE_HEIGHT/2);
            verticies[4].Set(-PADDLE_WIDTH/32, PADDLE_HEIGHT);
            verticies[5].Set(PADDLE_WIDTH/32, PADDLE_HEIGHT);
            polygon.Set(verticies, 4);
            
            fixtureDef.shape = &polygon;
            fixtureDef.density = 1.0f;
            fixtureDef.friction = 0.3f;
            fixtureDef.restitution = 1.0f;
            break;
            
        default:
            break;
            
    }
    fixtureDef.userData = userData;
    theObject->SetGravityScale(0.0f);
    // Add the new fixture to the Box2D object and add our physics object to our map
    theObject->CreateFixture(&fixtureDef);
    physicsObjects[name] = newObj;
    
}

-(struct PhysicsObject *) GetObject:(const char *)name
{
    return physicsObjects[name];
}

-(void)Reset
{
    // Look up the ball object and re-initialize the position, etc.
    struct PhysicsObject *theBall = physicsObjects["Ball"];
    theBall->loc.x = BALL_POS_X;
    theBall->loc.y = BALL_POS_Y;
    ((b2Body *)theBall->b2ShapePtr)->SetTransform(b2Vec2(BALL_POS_X, BALL_POS_Y), 0);
    ((b2Body *)theBall->b2ShapePtr)->SetLinearVelocity(b2Vec2(0, 0));
    ((b2Body *)theBall->b2ShapePtr)->SetAngularVelocity(0);
    ((b2Body *)theBall->b2ShapePtr)->SetAwake(true);
    ((b2Body *)theBall->b2ShapePtr)->SetActive(true);
    
    struct PhysicsObject *paddle = physicsObjects["Paddle"];
    paddle->loc.x = PADDLE_POS_X;
    paddle->loc.y = PADDLE_POS_Y;
    ((b2Body *)paddle->b2ShapePtr)->SetTransform(b2Vec2(PADDLE_POS_X, PADDLE_POS_Y), 0);
    
    totalElapsedTime = 0;
    ballHitBrick = false;
    ballLaunched = false;
    
}

- (void) ResetGame{
    physicsObjects.clear();
    
    totalElapsedTime = 0;
    ballHitBrick = false;
    ballLaunched = false;
}

- (void)UpdatePaddle:(const float)pos {
    struct PhysicsObject *paddle = physicsObjects["Paddle"];
    float clampedPos = MIN(MAX(paddle->loc.x + pos, WALL_LEFT_POS_X + PADDLE_WIDTH/2), WALL_RIGHT_POX_X - PADDLE_WIDTH/2);
    ((b2Body *)paddle->b2ShapePtr)->SetTransform(b2Vec2(clampedPos, 0), 0);
}

@end
