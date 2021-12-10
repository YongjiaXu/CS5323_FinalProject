//
//  UserViewController.swift
//  Relax Your Neck
//
//  Created by Yongjia Xu on 12/6/21.
//

import UIKit
import FSCalendar // referenced: https://www.youtube.com/watch?v=5Jwlet8L84w&t=382s

class UserViewController: UIViewController, FSCalendarDelegate, UITextFieldDelegate {
//    private let serverHandler = ServerHalder() - switched to UserDefaults
    let defaults = UserDefaults.standard
    var stepOfTheDay = 0
    var scoreOfTheDay = 0

    let months = ["January", "Feburary", "March", "April", "May", "June", "July", "August", "September", "October", "November", "December"]
    @IBOutlet weak var selectedDataLabel: UILabel!
    @IBOutlet weak var dailyGameGoalLabel: UILabel!
    @IBOutlet weak var dailyStepGoalLabel: UILabel!
    @IBOutlet weak var highestScoreEverLabel: UILabel!
    @IBOutlet weak var highestScoreEverNumLabel: UILabel!
    @IBOutlet weak var achieveStrLabel: UILabel!
    @IBOutlet weak var scoreOfTheDayLabel: UILabel!
    @IBOutlet weak var stepOfTheDayLabel: UILabel!
    @IBOutlet weak var scoreOfTheDayNumLabel: UILabel!
    @IBOutlet weak var stepOfTheDayNumLabel: UILabel!
    
    @IBOutlet var calendar: FSCalendar!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        

       
        calendar.delegate = self
        textFieldsInit()
        calendarUIInit()
        dashboardInit()
        labelsInit()
        resetBtnInit()
    }
    
    func resetBtnInit() {
        gameGoalResetBtn.addTarget(self, action: #selector(startHighlightGameGoal), for: .touchDown)
        gameGoalResetBtn.addTarget(self, action: #selector(stopHighlightGameGoal), for: .touchUpInside)
        gameGoalResetBtn.addTarget(self, action: #selector(stopHighlightGameGoal), for: .touchUpOutside)
        stepGoalResetBtn.addTarget(self, action: #selector(startHighlightStepGoal), for: .touchDown)
        stepGoalResetBtn.addTarget(self, action: #selector(stopHighlightStepGoal), for: .touchUpInside)
        stepGoalResetBtn.addTarget(self, action: #selector(stopHighlightStepGoal), for: .touchUpOutside)
    }
    
    @objc func startHighlightGameGoal(sender: UIButton) {
        gameGoalResetBtn.layer.borderColor = UIColor(rgb: 0xC8102E).cgColor
        gameGoalResetBtn.layer.borderWidth = 3
        gameGoalResetBtn.layer.masksToBounds = true
    }
    @objc func stopHighlightGameGoal(sender: UIButton) {
        gameGoalResetBtn.layer.borderColor = UIColor(rgb: 0x2B2C2C).cgColor
        gameGoalResetBtn.layer.borderWidth = 0
    }
    
    @objc func startHighlightStepGoal(sender: UIButton) {
        stepGoalResetBtn.layer.borderColor = UIColor(rgb: 0xC8102E).cgColor
        stepGoalResetBtn.layer.borderWidth = 3
        stepGoalResetBtn.layer.masksToBounds = true
    }
    @objc func stopHighlightStepGoal(sender: UIButton) {
        stepGoalResetBtn.layer.borderColor = UIColor(rgb: 0x2B2C2C).cgColor
        stepGoalResetBtn.layer.borderWidth = 0
    }
    
    func dashboardInit() {
        selectedDataLabel.font = UIFont(name: "04b_19", size: 25)
        let today = Date()
        print(today)
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy"
        let year = Int(formatter.string(from: today))!
        formatter.dateFormat = "M"
        let month = Int(formatter.string(from: today))!
        formatter.dateFormat = "dd"
        let day = Int(formatter.string(from: today))!
        selectedDataLabel.text = "\(months[month-1]) \(day) \(year)"
//        serverHandler.CheckAchievement(year: year, month: month, day: day)
        self.updateAchieveStatus(year: year, month: month, day: day)
    }
    
    func calendarUIInit() {
        calendar.appearance.headerTitleFont = UIFont(name: "04b_19", size: 23)
        calendar.appearance.weekdayFont = UIFont(name: "04b_19", size: 16)
        calendar.appearance.titleFont = UIFont(name: "04b_19", size: 18)
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
        selectedDataLabel.text = "\(months[month-1]) \(day) \(year)"
        
//        serverHandler.CheckAchievement(year: year, month: month, day: day)
        self.updateAchieveStatus(year: year, month: month, day: day)
    }
    
    func checkAchieved(year: Int, month: Int, day: Int) -> Int{
        let date = "\(year)-\(month)-\(day)"
        let gameGoalKey = "\(date)-gameGoal"
        let stepGoalKey = "\(date)-stepGoal"
        let scoreKey = "\(date)-score"
        let stepKey = "\(date)-step"
        
        if (!isKeyPresentInUserDefaults(key: gameGoalKey) || !isKeyPresentInUserDefaults(key: stepGoalKey) ||
            !isKeyPresentInUserDefaults(key: scoreKey) || !isKeyPresentInUserDefaults(key: stepKey)) {
            return 2
        }
        
        let gameGoal = defaults.integer(forKey: gameGoalKey)
        let stepGoal = defaults.integer(forKey: stepGoalKey)
        scoreOfTheDay = defaults.integer(forKey: scoreKey)
        stepOfTheDay = defaults.integer(forKey: stepKey)
        if (stepOfTheDay > stepGoal || scoreOfTheDay >= gameGoal) {
            return 1
        } else {
            return 0
        }
    }
    
    func updateAchieveStatus(year: Int, month: Int, day: Int) {
        let achieved = checkAchieved(year: year, month: month, day: day)
        var achieve_str = ""
        if (achieved == 1) {
            achieve_str = "Daily Goal Achieved!"
//            serverHandler.GetStepOfTheDay(year: year, month: month, day: day)
//            serverHandler.GetScoreOfTheDay(year: year, month: month, day: day)
            DispatchQueue.main.async {
                self.stepOfTheDayLabel.text = "Step of the day"
                self.scoreOfTheDayLabel.text = "Score of the day"
                self.stepOfTheDayNumLabel.text = "\(self.stepOfTheDay)"
                self.scoreOfTheDayNumLabel.text = "\(self.scoreOfTheDay)"
                self.achieveStrLabel.textColor = UIColor.systemYellow
//                self.stepOfTheDayNumLabel.text = "\(self.serverHandler.stepOfTheDay)"
//                self.scoreOfTheDayNumLabel.text = "\(self.serverHandler.scoreOfTheDay)"
            }
        } else if (achieved == 0) {
            achieve_str = "Daily Goal Not Achieved."
//            serverHandler.GetStepOfTheDay(year: year, month: month, day: day)
//            serverHandler.GetScoreOfTheDay(year: year, month: month, day: day)
            DispatchQueue.main.async {
                self.stepOfTheDayLabel.text = "Step of the day"
                self.scoreOfTheDayLabel.text = "Score of the day"
                self.stepOfTheDayNumLabel.text = "\(self.stepOfTheDay)"
                self.scoreOfTheDayNumLabel.text = "\(self.scoreOfTheDay)"
                self.achieveStrLabel.textColor = UIColor.gray
//                self.stepOfTheDayNumLabel.text = "\(self.serverHandler.stepOfTheDay)"
//                self.scoreOfTheDayNumLabel.text = "\(self.serverHandler.scoreOfTheDay)"
            }
        } else {
            achieve_str = "No Check-In Record."
            DispatchQueue.main.async {
                self.achieveStrLabel.textColor = UIColor.gray
                self.stepOfTheDayLabel.text = " "
                self.scoreOfTheDayLabel.text = " "
                self.stepOfTheDayNumLabel.text = " "
                self.scoreOfTheDayNumLabel.text = " "
            }
        }
        DispatchQueue.main.async {
            self.achieveStrLabel.text = achieve_str
        }
    }
    
    func textFieldsInit() {
        // add done button on tool bar. referenced: https://www.youtube.com/watch?v=RuzHai2RVZU
        let toolBar = UIToolbar()
        toolBar.barTintColor = UIColor(rgb: 0x2B2C2C)
        toolBar.sizeToFit()
        let flexibleSpace = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.flexibleSpace, target: nil, action: nil)
        let doneButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.done, target: self, action: #selector(self.doneClicked))
        toolBar.setItems([flexibleSpace, doneButton], animated: false)
        stepGoalTF.inputAccessoryView = toolBar
        gameGoalTF.inputAccessoryView = toolBar
        stepGoalTF.delegate = self
        gameGoalTF.delegate = self
        stepGoalTF.font = UIFont(name: "04b_19", size: 18)
        gameGoalTF.font = UIFont(name: "04b_19", size: 18)
        // get gameGoal and stepGoal using server -- deprecated* switched to use UserDefaults
//        serverHandler.GetGameGoal()
//        serverHandler.GetStepGoal()
//        DispatchQueue.main.async {
//            self.gameGoal = self.serverHandler.gameGoal
//            self.stepGoal = self.serverHandler.stepGoal
//            self.gameGoalTF.text = String(self.gameGoal)  // Update the label
//            self.stepGoalTF.text = String(self.stepGoal)  // Update the label
//        }
        DispatchQueue.main.async {
            self.gameGoalTF.text = String(self.defaults.integer(forKey: "gameGoal"))
            self.stepGoalTF.text = String(self.defaults.integer(forKey: "stepGoal"))
        }
        
    }
    
    func labelsInit() {
        dailyGameGoalLabel.font = UIFont(name: "04b_19", size: 18)
        dailyStepGoalLabel.font = UIFont(name: "04b_19", size: 18)
        gameGoalResetLabel.font = UIFont(name: "04b_19", size: 18)
        stepGoalResetLabel.font = UIFont(name: "04b_19", size: 18)
        highestScoreEverLabel.font = UIFont(name: "04b_19", size: 25)
        highestScoreEverNumLabel.font = UIFont(name: "04b_19", size: 50)
        achieveStrLabel.font = UIFont(name: "04b_19", size: 30)
        scoreOfTheDayLabel.font = UIFont(name: "04b_19", size: 22)
        stepOfTheDayLabel.font = UIFont(name: "04b_19", size: 22)
        scoreOfTheDayNumLabel.font = UIFont(name: "04b_19", size: 25)
        stepOfTheDayNumLabel.font = UIFont(name: "04b_19", size: 25)
        DispatchQueue.main.async {
            self.highestScoreEverNumLabel.text = String(self.defaults.integer(forKey: "highest_score"))
        }
//        serverHandler.GetHighestScore()
//        highestScoreEverNumLabel.text = "\(serverHandler.highestScoreEver)"
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
            // update global game goal
            defaults.set(resetValue, forKey: "gameGoal")
            // update today's game goal
            let todayString = getTodayString()
            let key = "\(todayString)-gameGoal"
            defaults.set(resetValue, forKey: key)
//            self.serverHandler.UpdateGameGoal(game_goal: resetValue!)
        }
    }
    @IBOutlet weak var gameGoalResetLabel: UILabel!
    
    // Outlets and Actions for daily step goal
    @IBOutlet weak var stepGoalTF: UITextField!
    
    @IBAction func chooseStepGoal(_ sender: Any) {
        
    }

    @IBOutlet weak var stepGoalResetBtn: UIButton!
    
    
    @IBAction func resetStepGoal(_ sender: Any) {
        print("Reset step goal: \(stepGoalTF.text!)")
        if (stepGoalTF.text != "") {
            let resetValue: Int? = Int(stepGoalTF.text!)
            // update global step goal
            defaults.set(resetValue, forKey: "stepGoal")
            // update today's step goal
            let todayString = getTodayString()
            let key = "\(todayString)-stepGoal"
            defaults.set(resetValue, forKey: key)
//            self.serverHandler.UpdateStepGoal(step_goal: resetValue!)
        }
    }
    
    @IBOutlet weak var stepGoalResetLabel: UILabel!
    
    @objc func doneClicked() {
        view.endEditing(true)
    }
    
    func isKeyPresentInUserDefaults(key: String) -> Bool {
        return UserDefaults.standard.object(forKey: key) != nil
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
    // DON'T use - tap gesture messed up with tapping on calendar
//    @IBAction func didCancelKeyboard(_ sender: Any) {
//        self.gameGoalTF.resignFirstResponder()
//        self.stepGoalTF.resignFirstResponder()
//    }
    
}


// referenced: https://stackoverflow.com/questions/24263007/how-to-use-hex-color-values
extension UIColor {
   convenience init(red: Int, green: Int, blue: Int) {
       assert(red >= 0 && red <= 255, "Invalid red component")
       assert(green >= 0 && green <= 255, "Invalid green component")
       assert(blue >= 0 && blue <= 255, "Invalid blue component")

       self.init(red: CGFloat(red) / 255.0, green: CGFloat(green) / 255.0, blue: CGFloat(blue) / 255.0, alpha: 1.0)
   }

   convenience init(rgb: Int) {
       self.init(
           red: (rgb >> 16) & 0xFF,
           green: (rgb >> 8) & 0xFF,
           blue: rgb & 0xFF
       )
   }
}





