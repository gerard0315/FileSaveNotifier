//
//  ViewController.swift
//
//  Created by Gerard Taub on 24/07/18.
//

import Foundation
import UIKit

import UserNotifications

    //MARK: - UIViewController Properties
class ViewController: UIViewController, UNUserNotificationCenterDelegate {
    var isGrantedAccess = false
    private var notification_1: NSObjectProtocol?
    private var notification_2: NSObjectProtocol?
    
    //MARK: - IBOutlets
    @IBOutlet weak var startButton: UIButton!
    // @IBOutlet weak var pauseButton: UIButton!
    @IBOutlet weak var timerLabel: UILabel!
    

    var seconds = 60.0 * 20
    var timer = 60 * 20
    var timer_1 = Timer()
 
    var startTapped = false
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    var startTimestamp = 0.0
    // var reactiveTime = 0.0
    var isTimeRunning = false
    var backgroundtime = 0.0
    var inBackground = true
    
    //MARK: - Super Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        UNUserNotificationCenter.current().delegate = self
        UNUserNotificationCenter.current().requestAuthorization(
            options: [.alert,.sound])
        {(granted, error) in
            self.isGrantedAccess = granted
        }
        notification_1 = NotificationCenter.default.addObserver(forName: .UIApplicationWillEnterForeground, object: nil, queue: .main) {
            [unowned self] notification_1 in
            print("enter forground in ui view controller")
            self.inBackground = false
        }
        notification_2 = NotificationCenter.default.addObserver(forName: .UIApplicationDidEnterBackground, object: nil, queue: .main) {
            [unowned self] notification_2 in
            print("enter background in ui view controller")
            self.inBackground = true
            let _temp = Date().timeIntervalSince1970
            self.backgroundtime = round(_temp)
        }
    }
    
    
    //MARK: - IBActions
    @IBAction func startButtonTapped(_ sender: UIButton) {
        if self.startTapped == false {
            runTimer()
            self.isTimeRunning = true
            
            self.startButton.setTitle("STOP",for: .normal)
            
            if isGrantedAccess{
                let content = UNMutableNotificationContent()
                content.title = "请张潇若进行一次保存操作"
                content.body = "因为20分钟到了"
                content.sound = UNNotificationSound.default()
                content.categoryIdentifier = "saveNotifier"
                
                let trigger = UNTimeIntervalNotificationTrigger(timeInterval: seconds, repeats: true)
                let request = UNNotificationRequest(identifier: "saveNotifier", content: content, trigger: trigger)
                UNUserNotificationCenter.current().add(request) { (error) in
                    if let error = error{
                        print("Error posting notification:\(error.localizedDescription)")
                    }
                }
            }
            self.startTapped = true
            self.startTimestamp = Date().timeIntervalSince1970
        } else {
            self.isTimeRunning = false
            self.startButton.setTitle("START",for: .normal)
            UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
            timer_1.invalidate()
            timer = 60 * 20
            timerLabel.text = timeString(time: TimeInterval(timer))
            self.startTapped = false
        }
    }
    
    func runTimer() {
        timer_1 = Timer.scheduledTimer(timeInterval: 1, target: self, selector: (#selector(ViewController.updateTimer)), userInfo: nil, repeats: true)
    }
    
    @IBAction func resetButtonTapped(_ sender: UIButton) {
        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
        timer_1.invalidate()
        timer = 60 * 20
        runTimer()
        self.isTimeRunning = true
        
        self.startButton.setTitle("STOP",for: .normal)
        
        if isGrantedAccess{
            let content = UNMutableNotificationContent()
            content.title = "请张潇若进行一次保存操作"
            content.body = "因为20分钟到了"
            content.sound = UNNotificationSound.default()
            content.categoryIdentifier = "saveNotifier"
            
            let trigger = UNTimeIntervalNotificationTrigger(timeInterval: seconds, repeats: true)
            let request = UNNotificationRequest(identifier: "saveNotifier", content: content, trigger: trigger)
            UNUserNotificationCenter.current().add(request) { (error) in
                if let error = error{
                    print("Error posting notification:\(error.localizedDescription)")
                }
            }
        }
        self.startTapped = true
        self.startTimestamp = Date().timeIntervalSince1970
    }
    

    @objc func updateTimer() {
        if self.isTimeRunning {
            if self.inBackground == false && self.backgroundtime != 0.0 {
                let reactiveTime = Date().timeIntervalSince1970
                let diff = round(reactiveTime - self.startTimestamp)
                print("diff is ", diff)
                let n = Int(diff) % ( 60 * 20)
                print("remain is ", n)
                timer = 60 * 20 - n + 1
                self.backgroundtime = 0.0
            }
            if timer < 1 {
                timer = 60 * 20 - 1
                timerLabel.text = timeString(time: TimeInterval(timer))
                self.startTimestamp = Date().timeIntervalSince1970
                // self.startTimestamp = round(_temp)
                // print("new starttimestamp", self.startTimestamp)
            } else {
                timer -= 1
                timerLabel.text = timeString(time: TimeInterval(timer))
            }
        }
    }
    
    func timeString(time:TimeInterval) -> String {
       // let hours = Int(time) / 3600
        let minutes = Int(time) / 60 % 60
        let seconds = Int(time) % 60
        return String(format:"%02i:%02i", minutes, seconds)
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        completionHandler()
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        completionHandler([.alert,.sound])
    }

}
