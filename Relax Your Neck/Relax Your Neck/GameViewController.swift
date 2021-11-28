//
//  GameViewController.swift
//  Relax Your Neck
//
//  Created by xuan zhai on 11/26/21.
//

import UIKit
import SpriteKit
import GameplayKit

// A delegate function for passing result back
protocol GameViewControllerDelegate  : NSObject{
    func CatchResult(controller:GameViewController, data:Int)
}


class GameViewController: UIViewController {
    var delegate : GameViewControllerDelegate?
    static var scoreresult = 0
    // It's the result it got, it is static so that can be accessed between class.
        
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let view = self.view as! SKView? {
            // Load the SKScene from 'GameScene.sks'
            
                // Set the scale mode to scale to fit the window
            if let scene = GameScene(fileNamed: "GameScene") {
                // Set the scale mode to scale to fit the window
                scene.scaleMode = .aspectFill
                scene.gamevc = self
                // Set the gamevc as itself for latter popping
                scene.scaleMode = .aspectFill
                scene.size = self.view.bounds.size
                // Present the scene
                view.presentScene(scene)
            }
            
            view.ignoresSiblingOrder = true
            
            view.showsFPS = true
            view.showsNodeCount = true
        }
    }

    override func viewDidDisappear(_ animated: Bool) {
        if(delegate != nil){        // Catch the result and send back
            let result = GameViewController.scoreresult
            delegate?.CatchResult(controller: self, data: result)
            self.navigationController?.popViewController(animated: true)
        }
    }
    
    
    override var shouldAutorotate: Bool {
        return true
    }

    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        if UIDevice.current.userInterfaceIdiom == .phone {
            return .allButUpsideDown
        } else {
            return .all
        }
    }

    override var prefersStatusBarHidden: Bool {
        return true
    }
}
