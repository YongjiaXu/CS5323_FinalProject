//
//  GameScene.swift
//  Relax Your Neck
//
//  Created by xuan zhai on 11/26/21.
//
// The game part is inspired by https://www.youtube.com/watch?v=D7ntzPFvMf0

import SpriteKit
import GameplayKit
import UIKit
import AVFoundation
import Accelerate


struct PhysicsCat {         // Physics body
    static let Character : UInt32 = 0x1 << 1
    static let Ground : UInt32 = 0x1 << 2
    static let Wall : UInt32 = 0x1 << 3
    static let Score : UInt32 = 0x1 << 4
}


class GameScene: SKScene, SKPhysicsContactDelegate{
    
    var videoManager: VideoAnalgesic! = nil // OpenCV manager
    let bridge = OpenCVBridge()         // OpenCV processor
    var height = CGFloat()              // The current height of the mustang
    var detected = Bool()               // Is face detected?
    var detecttolerance = Int()     // The tolernce of undetected, max is 5.
    
    
    var wallPair = SKNode()     // A pair of top and bottom wall
    var Ground = SKSpriteNode()     // The ground
    var Character = SKSpriteNode()      // The character that user control
    var moveAndRemove = SKAction()  // An action for wall pair
    var score = Int()                   // The score that user get
    let scoreLbl = SKLabelNode()        // A label for presenting the score
    let sitUpLbl = SKLabelNode()
    let moveHeadLbl = SKLabelNode()
    let tapBeginLbl = SKLabelNode()
    var endBTN = SKSpriteNode()         // The game over buttom/label
    var pausedBTN = SKLabelNode()           // The pause button/label
    var gameStatus = String()
    // A string for trakcing the game status
    // nostart == the game is not start
    // start == the game is processing
    // paused == the game is paused
    // end == the game is over
    weak var gamevc : GameViewController?
    // A reference of view controller, for dismissing when leave
    
    func BacktoHome(){      // The game is over, going back to home page
        self.removeAllChildren()
        self.removeAllActions()     // Remove all the actions and nodes
        gameStatus = "end"          // Reset the game status
        self.videoManager.stop()
        GameViewController.scoreresult = self.score // Reset the static data
        self.gamevc?.dismiss(animated: true) // Discard the scene
    }
    
    
    // ===================== Set the Opencv there ========================
    // Initialize the Scene
    func CreateScene(){
        self.physicsWorld.contactDelegate = self
        
        // Set the background
        for i in 0..<2{
            let background = SKSpriteNode(imageNamed: "Background")
            background.position = CGPoint( x: CGFloat(i) * self.frame.width-self.frame.width, y: -self.frame.width)
            background.anchorPoint = CGPoint(x: 0,y: 0)
            background.name = "background"
            background.size = (self.view?.bounds.size)!
            background.zPosition = -1
            self.addChild(background)
        }
        gameStatus = "notstart"     // Initialize the game status
        
        // Set the Score Label
        scoreLbl.position = CGPoint(x: 0, y: 0+self.frame.height/3.5)
//        scoreLbl.text = "test"
        scoreLbl.zPosition = 4
        scoreLbl.fontName = "04b_19"
        scoreLbl.fontSize = 60
        self.addChild(scoreLbl)

        // Set the sitUp Label
        sitUpLbl.position = CGPoint(x: 0, y: 0+self.frame.height/3.5)
        sitUpLbl.text = "Sit up Straight"
        sitUpLbl.zPosition = 4
        sitUpLbl.fontName = "04b_19"
        sitUpLbl.fontSize = 40
        self.addChild(sitUpLbl)
        
        // Set the move head Label
        moveHeadLbl.position = CGPoint(x: 0, y: 0+self.frame.height/4.5)
        moveHeadLbl.text = "Move your head up and down"
        moveHeadLbl.zPosition = 4
        moveHeadLbl.fontName = "04b_19"
        moveHeadLbl.fontSize = 25
        self.addChild(moveHeadLbl)
      
        // Set the move head Label
        tapBeginLbl.position = CGPoint(x: 0, y: Ground.frame.height/2-self.frame.height/3)
        tapBeginLbl.text = "(Tap To Begin)"
        tapBeginLbl.zPosition = 4
        tapBeginLbl.fontName = "04b_19"
        tapBeginLbl.fontSize = 40
        self.addChild(tapBeginLbl)
        
        // Set the Ground
        Ground = SKSpriteNode(imageNamed: "Ground")
        Ground.setScale(0.5)
        Ground.position =  CGPoint(x: 0, y: Ground.frame.height/2-self.frame.height/2)
        Ground.physicsBody = SKPhysicsBody(rectangleOf: Ground.size)
        Ground.physicsBody?.categoryBitMask =  PhysicsCat.Ground
        Ground.physicsBody?.collisionBitMask = PhysicsCat.Character
        Ground.physicsBody?.contactTestBitMask = PhysicsCat.Character
        Ground.physicsBody?.affectedByGravity = false
        Ground.physicsBody?.isDynamic = false
        Ground.zPosition = 3
        self.addChild(Ground)
        
        // Set the character that user controls
        Character = SKSpriteNode(imageNamed: "mustang")
        Character.size = CGSize(width: 110, height: 55)
        Character.position = CGPoint(x: 0 - Character.frame.width, y: 0)
        Character.physicsBody = SKPhysicsBody(circleOfRadius: Character.frame.height/2)
        Character.physicsBody?.categoryBitMask = PhysicsCat.Character
        Character.physicsBody?.collisionBitMask = PhysicsCat.Ground | PhysicsCat.Wall
        Character.physicsBody?.contactTestBitMask = PhysicsCat.Ground | PhysicsCat.Wall | PhysicsCat.Score
        Character.physicsBody?.affectedByGravity = false
        Character.physicsBody?.isDynamic = true
        Character.zPosition = 2
        self.addChild(Character)
    }
    
    
    // Initialize the nose  detection
    func CreateDetection(){
        self.detecttolerance = 0;   // Set all variables to init
        self.detected = false
        self.bridge.loadHaarCascade(withFilename: "nose")   // Load the data for nose
        self.videoManager = VideoAnalgesic()
        self.videoManager.setCameraPosition(position: AVCaptureDevice.Position.front) // Use front camera
        self.videoManager.setProcessingBlock(newProcessBlock: self.processImageSwift)
        
        if !videoManager.isRunning{
            self.videoManager.setFPS(desiredFrameRate: 60)
            videoManager.start()        // Start the videoManager
        }
    }
    
    
    // Proess the image captured
    func processImageSwift(inputImage:CIImage) -> CIImage{
        var retImage = inputImage
        self.bridge.setTransforms(self.videoManager.transform)
        self.bridge.setImage(retImage, withBounds: inputImage.extent, andContext: self.videoManager.getCIContext())
        
        
        let result = self.bridge.processNose()      // Find the result of processing nose
        if Int(result![0]) == 0{            // If not detected
            detecttolerance = detecttolerance + 1       // Update the tolerance
            if(detecttolerance > 3){            // If reach the maximum
                detected = false            // Mark it as not detected
            }
        }
        else{                               // If detected
            let newheight = self.frame.height  - 2*self.frame.height*CGFloat(result![1])/CGFloat(result![2])
            if abs(height-newheight) > 200 && height != 0 && detecttolerance == 0 {
                // If the height has dramatically changed, and it's not at the beginning
                // Maybe it got wrong detection, we choose to discard it.
            }
            else{
                height = newheight+100  // Else update the height for character
            }
            detecttolerance = 0     // Update the detecttolerance, mark it as detected.
            detected = true
        }
        
        retImage = self.bridge.getImageComposite()
        return retImage
    }
    
    
    
    
    
    
    
    
    
    override func didMove(to view: SKView) {
        CreateDetection()
        CreateScene()       // Create the scene at the begining
    }
    
    
    // Create the game over buttom
    func createBTN(){
        endBTN = SKSpriteNode(imageNamed: "game_over") // Load that image
        endBTN.size = CGSize(width: 200, height: 100)
        endBTN.position = CGPoint(x: 0, y: 0)
        endBTN.zPosition = 5
        endBTN.setScale(0)  // Start with scale 0, for later animation
        self.addChild(endBTN)
        endBTN.run(SKAction.scale(to: 1.0, duration: 0.3)) // Make an animation for that button

    }
    
    
    // A function for tracking collision between bodies
    func didBegin(_ contact: SKPhysicsContact) {
        let bodyone = contact.bodyA
        let bodytwo = contact.bodyB
        
        // If passed the walls
        if bodyone.categoryBitMask == PhysicsCat.Score && bodytwo.categoryBitMask == PhysicsCat.Character || bodyone.categoryBitMask == PhysicsCat.Character && bodytwo.categoryBitMask == PhysicsCat.Score{
            score += 1                      // Update the score
            scoreLbl.text = "\(score)"    // Update the label
        }
        
        // If touch the wall, games over
        if bodyone.categoryBitMask == PhysicsCat.Character && bodytwo.categoryBitMask == PhysicsCat.Wall || bodyone.categoryBitMask == PhysicsCat.Wall && bodytwo.categoryBitMask == PhysicsCat.Character {
            gameStatus = "end"          // Update the game status
            
            enumerateChildNodes(withName: "wallPair", using: ({
                (node, error) in
                node.speed = 0
                self.removeAllActions()         // Let walls stop moving
            }))
            createBTN()             // Create the game over buttom
        }
    }
    
    
    // A function for pausing the game
    func gamePaused(){
        if self.isPaused == false{      // If it is not paused, make it paused
            self.isPaused = true
            self.gameStatus = "paused"
            self.scoreLbl.fontSize = 40
            self.scoreLbl.text = "Game Paused"
        }
        else{               // Else, unfreeze the game
            self.isPaused = false
            self.gameStatus = "start"
            self.scoreLbl.fontSize = 60
            scoreLbl.text = "\(score)"
        }
    }
    
    
    // A function for tracking the touch movements
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        for touch in touches {
            let location = touch.location(in: self) // Find the location of that touch
            if gameStatus == "notstart" {   // If it is the first touch
                gameStatus = "start"        // Wake the game up
                scoreLbl.text = "\(score)"
                sitUpLbl.text = " "
                moveHeadLbl.text = " "
                tapBeginLbl.text = " "
                let spawn = SKAction.run({
                    () in
                    self.createWalls()      // Create walls and let them move
                })
                
                let delay = SKAction.wait(forDuration: 1.6)     // Set delays between wall pairs
                let SpawnDelay = SKAction.sequence([spawn, delay])
                let spawnDelayForever = SKAction.repeatForever(SpawnDelay)
                self.run(spawnDelayForever)     // That will be runned forever
                
                
                let distance = CGFloat(self.frame.width*2 + wallPair.frame.width) // Set the distance for wall's moving
                let movePipes = SKAction.moveBy(x: -distance, y: 0, duration: TimeInterval(0.006 * distance))
                // Wall pairs need to be removed if leave the scene
                let removePipes = SKAction.removeFromParent()
                // The the moving function up
                moveAndRemove = SKAction.sequence([movePipes, removePipes])
                Character.position = CGPoint(x: Character.position.x, y: self.height)
            }
            else if gameStatus == "end"{    // If the game is over
                if endBTN.contains(location){       // By touching the game over button
                    BacktoHome()                // Process that end game
                }
            }
            else if gameStatus == "start"{      // If the user is touching the screen
                gamePaused()            // Processing pause/unpause
            }
            else if gameStatus == "paused" && detected == true{
                gamePaused()        // If the user wants to resume, and the face is ready. Do resume.
            }
        }
    }
    
    
    // Create wall pairs
    func createWalls(){
        
        wallPair = SKNode()
        wallPair.name = "wallPair"
        let topWall = SKSpriteNode(imageNamed: "Wall")      // The top wall and the buttom wall
        let btmWall = SKSpriteNode(imageNamed: "Wall")
        
        topWall.position = CGPoint(x: self.frame.width+25, y: 0 + 350)
        btmWall.position = CGPoint(x: self.frame.width+25, y: 0 - 350)
        
        topWall.setScale(0.5)
        btmWall.setScale(0.5)
        
        // Add the physical info for the wall pair
        topWall.zRotation = CGFloat(Double.pi)
        topWall.physicsBody = SKPhysicsBody(rectangleOf: topWall.size)
        topWall.physicsBody?.categoryBitMask = PhysicsCat.Wall
        topWall.physicsBody?.collisionBitMask = PhysicsCat.Character
        topWall.physicsBody?.contactTestBitMask = PhysicsCat.Character
        topWall.physicsBody?.isDynamic = false
        topWall.physicsBody?.affectedByGravity = false
        
        btmWall.physicsBody = SKPhysicsBody(rectangleOf: btmWall.size)
        btmWall.physicsBody?.categoryBitMask = PhysicsCat.Wall
        btmWall.physicsBody?.collisionBitMask = PhysicsCat.Character
        btmWall.physicsBody?.contactTestBitMask = PhysicsCat.Character
        btmWall.physicsBody?.isDynamic = false
        btmWall.physicsBody?.affectedByGravity = false
        
        // It is the node that means the character is passed
        let scoreNode = SKSpriteNode()
        scoreNode.size = CGSize(width: 3, height: 200)
        scoreNode.position = CGPoint(x: self.frame.width + topWall.size.width/2, y: 0)
        scoreNode.physicsBody = SKPhysicsBody(rectangleOf: scoreNode.size)
        scoreNode.physicsBody?.affectedByGravity = false
        scoreNode.physicsBody?.isDynamic = false
        scoreNode.physicsBody?.categoryBitMask = PhysicsCat.Score
        scoreNode.physicsBody?.collisionBitMask = 0
        scoreNode.physicsBody?.contactTestBitMask = PhysicsCat.Character
        
        wallPair.addChild(topWall)
        wallPair.addChild(btmWall)
        
        // The location of those two walls should be random
        let randomPosition = CGFloat.random(min: -150, max: 100)
        wallPair.position.y = wallPair.position.y + randomPosition
        wallPair.addChild(scoreNode)
        
        wallPair.run(moveAndRemove) // Let the wall pair do moving
        self.addChild(wallPair)
    }
    
    
    // ================= Doing face detection there, openCV should work in every frame.
    // Use the gamePaused function if not detected or redetected.
    override func update(_ currentTime: TimeInterval) {
        if gameStatus == "start"{       // Update the background while the game is processing
            enumerateChildNodes(withName: "background", using: ({
                (node, error) in
                let bg = node as! SKSpriteNode
                bg.position = CGPoint(x: bg.position.x-2, y: bg.position.y)
                if bg.position.x <= -bg.size.width*1.5{
                    bg.position = CGPoint(x: bg.position.x + bg.size.width*2, y: bg.position.y)
                }
            }))
            
            if detected == true{ // If got face detected, update the character's position
                Character.position = CGPoint(x: Character.position.x, y: self.height)
            }
            else{
               gamePaused() // If not detected, pause the game.
            }
        }
    }
}
