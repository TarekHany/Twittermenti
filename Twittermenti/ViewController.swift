//
//  ViewController.swift
//  Twittermenti
//
//  Created by Tarek Hany on 10/5/20.
//

import UIKit
import SwifteriOS
import CoreML
import SwiftyJSON

class ViewController: UIViewController {

    @IBOutlet weak var sentimentLabel: UILabel!
    @IBOutlet weak var textField: UITextField!
    
    let swifter = Swifter(consumerKey: Twitter_API_Key , consumerSecret: Twitter_API_Secret_Key)
    
    let sentimentClassifier = TweetSentimentClassifier()
    let tweetsCount = 100
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }

    @IBAction func predictPressed(_ sender: UIButton) {
        fetchTweets()
    }
    func fetchTweets(){
        if let searchText = textField.text {
            swifter.searchTweet(using: searchText,lang: "en", count: tweetsCount, tweetMode: .extended) { (results, metadata) in
                //print(results)
                var tweets = [TweetSentimentClassifierInput]()
                for i in 0..<100 {
                    if let tweet = results[i]["full_text"].string {
                        let tweetForClassification = TweetSentimentClassifierInput(text: tweet)
                        tweets.append(tweetForClassification)
                    }
                }
                self.makePrediction(with: tweets)
            } failure: { (error) in
                print("There was an error with twitter api request, \(error)")
            }
        }
    }
    func makePrediction(with tweets: [TweetSentimentClassifierInput]){
        do {
            let predictions = try self.sentimentClassifier.predictions(inputs: tweets)
            var sentimentScore = 0
            for pred in predictions {
                if pred.label == "Neg" {
                    sentimentScore -= 1
                } else if pred.label == "Pos" {
                    sentimentScore += 1
                }
            }
            print(sentimentScore)
            updateUI(with: sentimentScore)
        } catch {
            print(error)
        }
    }
    func updateUI(with sentimentScore: Int){
        if sentimentScore > 20 {
            self.sentimentLabel.text = "😍"
        }else if sentimentScore > 10 {
            self.sentimentLabel.text = "😃"
        }else if sentimentScore > 0 {
            self.sentimentLabel.text = "🙂"
        }else if sentimentScore == 0 {
            self.sentimentLabel.text = "😐"
        }else if sentimentScore > -10 {
            self.sentimentLabel.text = "🙁"
        }else if sentimentScore > -20 {
            self.sentimentLabel.text = "😡"
        }else {
            self.sentimentLabel.text = "🤮"
        }
    }
}

