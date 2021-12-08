//
//  HomeViewController.swift
//  Relax Your Neck
//
//  Created by xuan zhai on 11/27/21.
//

import UIKit

class HomeViewController: UIViewController, GameViewControllerDelegate{
    
    private let serverHandler = ServerHalder()

    @IBOutlet weak var resultLabel: UILabel!
    
    
    @IBAction func playGame(_ sender: UIButton) {
    }
    
    
    var scoregoal = Int()
    // A goal for playing the game, can be set/reset by the user
    var ispassed = Bool()
    // A boolean for tracking whether the player has passe dthe game
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        scoregoal = 5   // The goal for game is initialized as 5


        // Do any additional setup after loading the view.
    }
    

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let vc = segue.destination as? GameViewController{
            vc.delegate = self          // A function for passing delegate
        }
    }
    
    
    func CatchResult(controller: GameViewController, data: Int) {
        // Catch the result from the game
        if(data >= scoregoal){      // If reaches the goal
            ispassed = true
            DispatchQueue.main.async {
                self.resultLabel.text = "You won the game"  // Update the label
            }
            // update the backend
            self.serverHandler.UpdateScore(score: data, achieved: "1")
        }
        else{                   // If not reaches the goal
            ispassed = false
            DispatchQueue.main.async {
                self.resultLabel.text = "You lost the game"
            }
            self.serverHandler.UpdateScore(score: data, achieved: "0")
        }

    }

}
