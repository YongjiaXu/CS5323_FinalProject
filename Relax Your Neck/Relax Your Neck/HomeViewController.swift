//
//  HomeViewController.swift
//  Relax Your Neck
//
//  Created by xuan zhai on 11/27/21.
//

import UIKit
import CoreMotion

class HomeViewController: UIViewController, SceneKitViewControllerDelegate{
    
//    private let serverHandler = ServerHalder() -- switched to UserDefaults to store data
//    let activityManager = CMMotionActivityManager()
    let pedometer = CMPedometer()
    var stepsWalked = 0
    let defaults = UserDefaults.standard
    @IBOutlet weak var playBtn: UIButton!
    
    @IBOutlet weak var resultLabel: UILabel!
    
    @IBOutlet weak var playLabel: UILabel!
    
    @IBAction func playGame(_ sender: UIButton) {
    }
    @IBOutlet weak var myPageBtn: UIButton!
    
    @IBOutlet weak var myPageLabel: UILabel!
    
    @IBOutlet weak var runRunLabel: UILabel!
    
    @IBOutlet weak var mustangLabel: UILabel!
    var scoregoal = Int()
    // A goal for playing the game, can be set/reset by the user
    var ispassed = Bool()
    // A boolean for tracking whether the player has passed the game
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
//        _checkUserDefaults()
        updatePedometer()
        playBtnInit()
        myPageBtnInit()
        goalsInit()
        resultLabel.font = UIFont(name: "04b_19", size: 30)
        playLabel.font = UIFont(name: "04b_19", size: 30)
        myPageLabel.font = UIFont(name: "04b_19", size: 30)
        runRunLabel.font = UIFont(name: "04b_19", size: 25)
        mustangLabel.font = UIFont(name: "04b_19", size: 35)
    }
    
    func _checkUserDefaults() {
        print(UserDefaults.standard.dictionaryRepresentation().keys)
        // test data
//        let date = "2021-12-7"
//        let gameGoalKey = "\(date)-gameGoal"
//        let stepGoalKey = "\(date)-stepGoal"
//        let scoreKey = "\(date)-score"
//        let stepKey = "\(date)-step"
//
//        defaults.set(10, forKey: gameGoalKey)
//        defaults.set(0, forKey: scoreKey)
//        defaults.set(1000, forKey: stepGoalKey)
//        defaults.set(2000, forKey: stepKey)

    }
    
    func myPageBtnInit() {
        myPageBtn.layer.masksToBounds = true
        myPageBtn.layer.cornerRadius = 3
        myPageBtn.titleLabel?.minimumScaleFactor = 0.5
        myPageBtn.titleLabel?.numberOfLines = 0
        myPageBtn.titleLabel?.adjustsFontSizeToFitWidth = true
        myPageBtn.addTarget(self, action: #selector(startHighlightMyPage), for: .touchDown)
        myPageBtn.addTarget(self, action: #selector(stopHighlightMyPage), for: .touchUpInside)
        myPageBtn.addTarget(self, action: #selector(stopHighlightMyPage), for: .touchUpOutside)
    }

    @objc func startHighlightMyPage(sender: UIButton) {
        myPageBtn.layer.backgroundColor = UIColor.white.cgColor
        myPageBtn.layer.masksToBounds = true
        myPageBtn.layer.cornerRadius = 7
    }
    @objc func stopHighlightMyPage(sender: UIButton) {
        myPageBtn.layer.backgroundColor = UIColor.systemYellow.cgColor
        myPageBtn.layer.masksToBounds = true
        myPageBtn.layer.cornerRadius = 3
    }
    
    func playBtnInit() {
        playBtn.layer.masksToBounds = true
        playBtn.layer.cornerRadius = 3
        playBtn.titleLabel?.minimumScaleFactor = 0.5
        playBtn.titleLabel?.numberOfLines = 0
        playBtn.titleLabel?.adjustsFontSizeToFitWidth = true
        playBtn.addTarget(self, action: #selector(startHighlightPlay), for: .touchDown)
        playBtn.addTarget(self, action: #selector(stopHighlightPlay), for: .touchUpInside)
        playBtn.addTarget(self, action: #selector(stopHighlightPlay), for: .touchUpOutside)
    }

    @objc func startHighlightPlay(sender: UIButton) {
        playBtn.layer.backgroundColor = UIColor.white.cgColor
        playBtn.layer.masksToBounds = true
        playBtn.layer.cornerRadius = 7
    }
    @objc func stopHighlightPlay(sender: UIButton) {
        playBtn.layer.backgroundColor = UIColor(rgb: 0xC8102E).cgColor
        playBtn.layer.masksToBounds = true
        playBtn.layer.cornerRadius = 3
    }
    
    func goalsInit() {
        if (!isKeyPresentInUserDefaults(key: "stepGoal")) {
            print("Initializing step goal to 1000")
            defaults.set(1000, forKey: "stepGoal")
        }
        
        if (!isKeyPresentInUserDefaults(key: "gameGoal")) {
            print("Initializing step goal to 5")
            defaults.set(5, forKey: "gameGoal")
        }
        
        // store goal to today's data
        let todayString = getTodayString()
        let gameGoalKey = "\(todayString)-gameGoal"
        let stepGoalKey = "\(todayString)-stepGoal"
        let scoreKey = "\(todayString)-score"
        if (!isKeyPresentInUserDefaults(key: gameGoalKey)) {
            defaults.set(defaults.integer(forKey:"gameGoal"), forKey: gameGoalKey)
        }
        if (!isKeyPresentInUserDefaults(key: stepGoalKey)) {
            defaults.set(defaults.integer(forKey:"stepGoal"), forKey: stepGoalKey)
        }
        if (!isKeyPresentInUserDefaults(key: scoreKey)) {
            defaults.set(0, forKey: scoreKey)
        }
    }
    
    func updatePedometer(){
        let sem = DispatchSemaphore(value: 0)
//        serverHandler.GetStepGoal()
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
        // update stepsWalked
        let todayString = getTodayString()
        let key = String("\(todayString)-step")
        print(key)
        defaults.set(self.stepsWalked, forKey: key)
        // also initialize every
        // send update data to server
//        serverHandler.UpdateStep(step: self.stepsWalked)
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let vc = segue.destination as? SceneKitViewController{
            vc.delegate = self          // A function for passing delegate
        }
    }
    
    
    func CatchResult(controller: SceneKitViewController, data: Int) {
        // Catch the result from the game
        DispatchQueue.main.async {
            self.resultLabel.text = "Score: \(data)"
        }
        let todayString = getTodayString()
        let key = String("\(todayString)-score")
        print(key)
        //update today's score
        if (!isKeyPresentInUserDefaults(key: key)) {
            defaults.set(data, forKey: key)
        } else {
            let value = defaults.integer(forKey: key)
            if (data > value) {
                // if score is higher, update
                defaults.set(data, forKey: key)
            }
        }
        
        // update highest score ever
        if (!isKeyPresentInUserDefaults(key: "highest_score")) {
            defaults.set(data, forKey: "highest_score")
        } else {
            let value = defaults.integer(forKey: "highest_score")
            if (data > value) {
                // if score is higher, update
                defaults.set(data, forKey: "highest_score")
            }
        }
        
        // get game goal from the server
//        serverHandler.GetGameGoal()
//        scoregoal = serverHandler.gameGoal
        
//        if(data >= scoregoal){      // If reaches the goal
//            ispassed = true
            
            // update the backend
//            self.serverHandler.UpdateScore(score: data)
//        }
//        else{                   // If not reaches the goal
//            ispassed = false
//            self.serverHandler.UpdateScore(score: data)
//        }

    }
    
    func getTodayString() -> String {
        let today = Date()
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy"
        let year = Int(formatter.string(from: today))!
        formatter.dateFormat = "M"
        let month = Int(formatter.string(from: today))!
        formatter.dateFormat = "dd"
        let day = Int(formatter.string(from: today))!
        let todayString = String("\(year)-\(month)-\(day)")
        return todayString
    }
    
    func isKeyPresentInUserDefaults(key: String) -> Bool {
        return UserDefaults.standard.object(forKey: key) != nil
    }

}
