//====================================================================
//
// (c) Borna Noureddin
// COMP 8051   British Columbia Institute of Technology
// Objective-C++ wrapper for Box2D library
//
//====================================================================

#ifndef MyGLGame_CBox2D_h
#define MyGLGame_CBox2D_h

#import <Foundation/NSObject.h>


// Set up brick and ball physics parameters here:
//   position, width+height (or radius), velocity,
//   and how long to wait before dropping brick

#define BRICK_ROWS      7
#define BRICK_COLS      7
#define BRICK_SPACING   0.50f
#define BRICK_POS_X     -25.5
#define BRICK_POS_Y     80
#define BRICK_WIDTH     8.0f
#define BRICK_HEIGHT    2.0f
#define BRICK_WAIT      1.0f
#define BALL_POS_X      0
#define BALL_POS_Y      10
#define BALL_RADIUS     2.0f
#define BALL_VELOCITY   1000.0f
#define PADDLE_WIDTH    12.0f
#define PADDLE_HEIGHT   1.5f
#define PADDLE_POS_X    0
#define PADDLE_POS_Y    0
#define WALL_WIDTH      1.0f
#define WALL_HEIGHT     300.0f
#define WALL_POS_Y      105.0f
#define WALL_LEFT_POS_X -30.0f
#define WALL_RIGHT_POX_X 30.0f
#define KILL_ZONE       -20.0f


// You can define other object types here
typedef enum { ObjTypeBox=0, ObjTypeCircle=1, ObjTypeWall=3 , ObjTypePaddle=4} ObjectType;


// Location of each object in our physics world
struct PhysicsLocation {
    float x, y, theta;
};


// Information about each physics object
struct PhysicsObject {

    struct PhysicsLocation loc; // location
    ObjectType objType;         // type
    void *b2ShapePtr;           // pointer to Box2D shape definition
    void *box2DObj;             // pointer to the CBox2D object for use in callbacks
};


// Wrapper class
@interface CBox2D : NSObject
-(void) LaunchBall;                                                         // launch the ball
-(void) Update:(float)elapsedTime;                                          // update the Box2D engine
-(void) RegisterHit:(char *)objName;                                     // Register when the ball hits the brick
-(void) AddObject:(char *)name newObject:(struct PhysicsObject *)newObj isDynamic:(bool)isDynamic userData:(char *)userData;    // Add a new physics object
-(struct PhysicsObject *) GetObject:(const char *)name;                     // Get a physics object by name
-(void) UpdatePaddle:(const float) pos;
-(void) Reset;  
-(void) ResetGame; 
-(void)createBallBody;
-(void)createPaddleBody;
-(void)createWallBodies;
-(void)createBrick:(int)row andCol:(int)col andName:(char *)name;

@end

#endif
