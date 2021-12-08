//
//  UserViewController.swift
//  Relax Your Neck
//
//  Created by Yongjia Xu on 12/6/21.
//

import UIKit
import FSCalendar // referenced: https://www.youtube.com/watch?v=5Jwlet8L84w&t=382s
import CoreMotion

class UserViewController: UIViewController, FSCalendarDelegate, UITextFieldDelegate {
    private let serverHandler = ServerHalder()
    let pedometer = CMPedometer()
    var stepsWalked = 0
    var stepGoal = 0
    var gameGoal = 0
    
    @IBOutlet var calendar: FSCalendar!
    override func viewDidLoad() {
        super.viewDidLoad()
        calendar.delegate = self
        self.textFieldsInit()
    }
    
    func updatePedometer(){
        let sem = DispatchSemaphore(value: 0)
        serverHandler.GetStepGoal()
        self.stepGoal = self.serverHandler.stepGoal
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
    }
    
    func calendar(_ calendar: FSCalendar, didSelect date: Date, at monthPosition: FSCalendarMonthPosition) {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy"
        let year = Int(formatter.string(from: date))!
        formatter.dateFormat = "M"
        let month = Int(formatter.string(from: date))!
        formatter.dateFormat = "dd"
        let day = Int(formatter.string(from: date))!
        print("\(year) \(month) \(day)")
//        serverHandler.CheckConnection()
        serverHandler.CheckAchievement(year: year, month: month, day: day)
        let achieved = serverHandler.checkAchievementAchieved
        // ****** also need to check the pedometer value
        var achieve_str = ""
        if (achieved) {
            achieve_str = "Daily Goal Achieved!"
        } else {
            achieve_str = "Daily Goal Not Achieved, Get Some Exercise!"
        }
        let alert = UIAlertController(title: "\(year)-\(month)-\(day)", message: "\(achieve_str)", preferredStyle: .alert)
        let okayAction = UIAlertAction(title: "Okay", style: .default)
        alert.addAction(okayAction)
        present(alert, animated: true, completion: nil)
    }
    
    func textFieldsInit() {
        // add done button on tool bar. referenced: https://www.youtube.com/watch?v=RuzHai2RVZU
        let toolBar = UIToolbar()
        toolBar.sizeToFit()
        let flexibleSpace = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.flexibleSpace, target: nil, action: nil)
        let doneButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.done, target: self, action: #selector(self.doneClicked))
        toolBar.setItems([flexibleSpace, doneButton], animated: false)
        stepGoalTF.inputAccessoryView = toolBar
        gameGoalTF.inputAccessoryView = toolBar
        stepGoalTF.delegate = self
        gameGoalTF.delegate = self
        // get gameGoal and stepGoal
        serverHandler.GetGameGoal()
        serverHandler.GetStepGoal()
        DispatchQueue.main.async {
            self.gameGoal = self.serverHandler.gameGoal
            self.stepGoal = self.serverHandler.stepGoal
            self.gameGoalTF.text = String(self.gameGoal)  // Update the label
            self.stepGoalTF.text = String(self.stepGoal)  // Update the label
        }
    }
    
    // Outlets and Actions for daily game goal
    @IBOutlet weak var gameGoalTF: UITextField!
    
    @IBAction func chooseGameGoal(_ sender: Any) {
        
    }
    @IBOutlet weak var gameGoalResetBtn: UIButton!
    
    @IBAction func resetGameGoal(_ sender: Any) {
        print("Reset game goal: \(gameGoalTF.text!)")
        if (gameGoalTF.text != "") {
            let resetValue: Int? = Int(gameGoalTF.text!)
            self.serverHandler.UpdateGameGoal(game_goal: resetValue!)
        }
    }
    
    // Outlets and Actions for daily step goal
    @IBOutlet weak var stepGoalTF: UITextField!
    
    @IBAction func chooseStepGoal(_ sender: Any) {
        
    }
    @IBAction func stepGoalResetBtn(_ sender: Any) {
        
    }

    
    @IBAction func resetStepGoal(_ sender: Any) {
        print("Reset step goal: \(stepGoalTF.text!)")
        if (stepGoalTF.text != "") {
            let resetValue: Int? = Int(stepGoalTF.text!)
            self.serverHandler.UpdateStepGoal(step_goal: resetValue!)
        }
    }
    
    @objc func doneClicked() {
        view.endEditing(true)
    }
    
    // DON'T use - tap gesture messed up with tapping on calendar
//    @IBAction func didCancelKeyboard(_ sender: Any) {
//        self.gameGoalTF.resignFirstResponder()
//        self.stepGoalTF.resignFirstResponder()
//    }
    
}
