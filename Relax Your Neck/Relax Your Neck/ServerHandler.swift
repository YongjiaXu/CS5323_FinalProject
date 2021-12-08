//
//  ServerHandler.swift
//  Relax Your Neck
//
//  Created by Yongjia Xu on 12/6/21.
//

import Foundation
import UIKit

let SERVER_URL = "http://10.9.165.78:8000"
//let SERVER_URL = "http://10.8.103.118:8000"


class ServerHalder: NSObject, URLSessionDelegate {
    
    // initialize server session
    lazy var session: URLSession = {
        let sessionConfig = URLSessionConfiguration.ephemeral
        
        sessionConfig.timeoutIntervalForRequest = 5.0
        sessionConfig.timeoutIntervalForResource = 5.0
        sessionConfig.httpMaximumConnectionsPerHost = 1
        
        return URLSession(configuration: sessionConfig,
            delegate: self,
            delegateQueue:self.operationQueue)
    }()
    
    let operationQueue = OperationQueue()
    var retLabel = "None"
    var checkAchievementAchieved:Bool = false
    var checkAchievementScore:Int = 0

    // convertDictionaryToData and convertDataToDictionary copied from in class assignment
    func convertDictionaryToData(with jsonUpload:NSDictionary) -> Data?{
        do { // try to make JSON and deal with errors using do/catch block
            let requestBody = try JSONSerialization.data(withJSONObject: jsonUpload, options:JSONSerialization.WritingOptions.prettyPrinted)
            return requestBody
        } catch {
            print("json error: \(error.localizedDescription)")
            return nil
        }
    }
    
    func convertDataToDictionary(with data:Data?)->NSDictionary{
        do { // try to parse JSON and deal with errors using do/catch block
            let jsonDictionary: NSDictionary =
                try JSONSerialization.jsonObject(with: data!,
                                              options: JSONSerialization.ReadingOptions.mutableContainers) as! NSDictionary
            
            return jsonDictionary
            
        } catch {
            
            if let strData = String(data:data!, encoding:String.Encoding(rawValue: String.Encoding.utf8.rawValue)){
                            print("printing JSON received as string: "+strData)
            }else{
                print("json error: \(error.localizedDescription)")
            }
            return NSDictionary() // just return empty
        }
    }
    
    
    func checkDatabase() {
        let baseURL = "\(SERVER_URL)/CheckDatabase"
        let getUrl = URL(string: baseURL)
        let request: URLRequest = URLRequest(url: getUrl!)
        // wait for the http request to check if there is enough Data
        let sem = DispatchSemaphore(value: 0)
        let dataTask : URLSessionDataTask = self.session.dataTask(with: request,
            completionHandler:{(data, response, error) in
                if(error != nil){
                    if(response != nil) {
                        print("Response:\n%@",response!)
                    } else {
                        print("no response")
                    }
                }
                else{
                    let jsonDictionary = self.convertDataToDictionary(with: data)
                    // receive the enough flag and update it in the server
                    if let ret = jsonDictionary["ret"]{
                        self.retLabel = ret as! String
                        print(ret)
                    }
                }
            sem.signal()
        })
        dataTask.resume() // start the task
        sem.wait()
    }
    
    func CheckConnection() {
        let baseURL = "\(SERVER_URL)/Handlers"
        let getUrl = URL(string: baseURL)
        let request: URLRequest = URLRequest(url: getUrl!)
        // wait for the http request to check if there is enough Data
        let sem = DispatchSemaphore(value: 0)
        let dataTask : URLSessionDataTask = self.session.dataTask(with: request,
            completionHandler:{(data, response, error) in
                if(error != nil){
                    if(response != nil) {
                        print("Response:\n%@",response!)
                    } else {
                        print("no response")
                    }
                }
                else{
                    let jsonDictionary = self.convertDataToDictionary(with: data)
                    // receive the enough flag and update it in the server
                    print("received")
                }
            sem.signal()
        })
        dataTask.resume() // start the task
        sem.wait()
    }
    
    func CheckAchievement(year: Int, month: Int, day: Int) {
        let baseURL = "\(SERVER_URL)/CheckAchievement"
        let postURL = URL(string: "\(baseURL)")
        var request = URLRequest(url: postURL!)
        let jsonUpload:NSDictionary = ["year": year, "month": month, "day": day]
        let requestBody:Data? = self.convertDictionaryToData(with:jsonUpload)
        
        request.httpMethod = "POST"
        request.httpBody = requestBody
        let sem = DispatchSemaphore(value: 0)
        let postTask : URLSessionDataTask = self.session.dataTask(with: request,
            completionHandler:{(data, response, error) in
                if(error != nil){
                    if let res = response{
                        print("Response:\n",res)
                    }
                }
                else{
                    let jsonDictionary = self.convertDataToDictionary(with: data)
                    // update the resultLabel
                    if let ret = jsonDictionary["ret"]{
                        let retArr = ret as! Array<Any>
                        self.checkAchievementAchieved = retArr[0] as! Bool
                        self.checkAchievementScore = retArr[1] as! Int
                    }
                }
            sem.signal()
        })
        
        postTask.resume() // start the task
        sem.wait()
    }
    
    func UpdateScore(score: Int, achieved: String) {
        let baseURL = "\(SERVER_URL)/UpdateScore"
        let postURL = URL(string: "\(baseURL)")
        var request = URLRequest(url: postURL!)
        let jsonUpload:NSDictionary = ["score": score, "achieved": achieved]
        let requestBody:Data? = self.convertDictionaryToData(with:jsonUpload)
        
        request.httpMethod = "POST"
        request.httpBody = requestBody
        let sem = DispatchSemaphore(value: 0)
        let postTask : URLSessionDataTask = self.session.dataTask(with: request,
            completionHandler:{(data, response, error) in
                if(error != nil){
                    if let res = response{
                        print("Response:\n",res)
                    }
                }
                else{
                    print("update score successfully!")
                    
                }
            sem.signal()
        })
        
        postTask.resume() // start the task
        sem.wait()
    }

}

