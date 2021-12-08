//
//  UserViewController.swift
//  Relax Your Neck
//
//  Created by Yongjia Xu on 12/6/21.
//

import UIKit
import FSCalendar
class UserViewController: UIViewController, FSCalendarDelegate {
    private let serverHandler = ServerHalder()

    @IBOutlet var calendar: FSCalendar!
    override func viewDidLoad() {
        super.viewDidLoad()
        calendar.delegate = self
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
        let score = serverHandler.checkAchievementScore
        let achieved = serverHandler.checkAchievementAchieved
        // ****** also need to check the pedometer value
        var achieve_str = ""
        if (achieved) {
            achieve_str = "Daily Goal Achieved!"
        } else {
            achieve_str = "Daily Goal Not Achieved, Get Some Exercise!"
        }
        let alert = UIAlertController(title: "\(year)-\(month)-\(day)", message: "Highest Score: \(score) \n \(achieve_str)", preferredStyle: .alert)
        let okayAction = UIAlertAction(title: "Okay", style: .default)
        alert.addAction(okayAction)
        present(alert, animated: true, completion: nil)
    }

}
