//
//  HomeViewController.swift
//  Relax Your Neck
//
//  Created by xuan zhai on 11/27/21.
//

import UIKit
import CoreMotion

class HomeViewController: UIViewController, GameViewControllerDelegate{
    
    private let serverHandler = ServerHalder()
//    let activityManager = CMMotionActivityManager()
    let pedometer = CMPedometer()
    var stepsWalked = 0
    @IBOutlet weak var playBtn: UIButton!
    
    @IBOutlet weak var resultLabel: UILabel!
    
    @IBOutlet weak var playLabel: UILabel!
    
    @IBAction func playGame(_ sender: UIButton) {
    }
    
    
    var scoregoal = Int()
    // A goal for playing the game, can be set/reset by the user
    var ispassed = Bool()
    // A boolean for tracking whether the player has passed the game
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        updatePedometer()
        playBtnInit()
        resultLabel.font = UIFont(name: "04b_19", size: 30)
        playLabel.font = UIFont(name: "04b_19", size: 30)
    }
    
    func playBtnInit() {
        playBtn.layer.masksToBounds = true
        playBtn.layer.cornerRadius = 3
        playBtn.titleLabel?.minimumScaleFactor = 0.5
        playBtn.titleLabel?.numberOfLines = 0
        playBtn.titleLabel?.adjustsFontSizeToFitWidth = true
    }
    
    func updatePedometer(){
        let sem = DispatchSemaphore(value: 0)
        serverHandler.GetStepGoal()
        if CMPedometer.isStepCountingAvailable(){
            let startToday = Calendar.current.startOfDay(for: Date())
            pedometer.queryPedometerData(from: startToday, to: Date())
            {(pedData:CMPedometerData?, error:Error?)->Void in
                if let data = pedData {
                    self.stepsWalked = data.numberOfSteps.intValue
                }
                sem.signal()
            }
        }
        sem.wait()
        // send update data to server
        serverHandler.UpdateStep(step: self.stepsWalked)
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let vc = segue.destination as? GameViewController{
            vc.delegate = self          // A function for passing delegate
        }
    }
    
    
    func CatchResult(controller: GameViewController, data: Int) {
        // get game goal from the server
        serverHandler.GetGameGoal()
        scoregoal = serverHandler.gameGoal
        DispatchQueue.main.async {
            self.resultLabel.text = "Score: \(data)"
        }
        // Catch the result from the game
        if(data >= scoregoal){      // If reaches the goal
            ispassed = true
            // update the backend
            self.serverHandler.UpdateScore(score: data)
        }
        else{                   // If not reaches the goal
            ispassed = false
            self.serverHandler.UpdateScore(score: data)
        }

    }

}
