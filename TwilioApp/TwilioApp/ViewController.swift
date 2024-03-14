//
//  ViewController.swift
//  TwilioApp
//
//  Created by Abdur Rehman on 13/03/2024.
//

import UIKit
import Alamofire

class ViewController: UIViewController {
    
    @IBOutlet weak var messageLbl: UILabel!

    public static  let session: Session = {
        let manager = ServerTrustManager(evaluators: ["api.twilio.com": DisabledTrustEvaluator()])
        let configuration = URLSessionConfiguration.af.default
        configuration.timeoutIntervalForRequest = 15
        configuration.timeoutIntervalForResource = 15
        return Session(configuration: configuration, serverTrustManager: manager)
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()

    }

    @IBAction func sendMessage(_ sender: UIButton) {
        print("Send Messaage taped")
        sendSMS()
//        sendMessage()
    }
    func sendSMS(){
        
        let twilioSID = "ACa601c69a630341cf5b5f53c359762dd1"
        let twilioSecret = "60b993b0eaafa41efcba478e47b0e55b"
        
        //Note replace + = %2B , for To and From phone number
        let fromNumber = "%2B15162523119"// actual number is +14803606445
        let toNumber = "%2B923355269449"// actual number is +919152346132
        let message = "Hello from Swift, It's a testing message from test app! Date: \(Date())"
        
        // Build the request
        // "https://\(twilioSID):\(twilioSecret)@api.twilio.com/2010-04-01/Accounts/\(twilioSID)/SMS/Messages" discontinued
        let request = NSMutableURLRequest(url: NSURL(string:"https://api.twilio.com/2010-04-01/Accounts/\(twilioSID)/Messages")! as URL)
        request.httpMethod = "POST"
        request.httpBody = "From=\(fromNumber)&To=\(toNumber)&Body=\(message)".data(using: .utf8, allowLossyConversion: true)
        
        let loginString = "\(twilioSID):\(twilioSecret)"

        guard let loginData = loginString.data(using: String.Encoding.utf8) else {
            return
        }
        let base64LoginString = loginData.base64EncodedString()

        request.setValue("Basic \(base64LoginString)", forHTTPHeaderField: "Authorization")


        // Build the completion block and send the request
        URLSession.shared.dataTask(with: request as URLRequest, completionHandler: { (data, response, error) in
            print("Finished")
            if let data = data, let responseDetails = NSString(data: data, encoding: NSUTF8StringEncoding) {
                // Success
                print("Response: \(responseDetails)")
                DispatchQueue.main.async {
//                    self.messageLbl.attributedText = "\(responseDetails)".htmlToAttributedString
                    self.messageLbl.attributedText = String(data: data, encoding: .utf8)?.htmlToAttributedString
                }
            } else {
                // Failure
                print("Error: \(String(describing: error))")
                DispatchQueue.main.async {
                    self.messageLbl.text = response.debugDescription
                }
            }
        }).resume()
    }

    func sendMessage() {
        
        if let accountSID = ProcessInfo.processInfo.environment["ACa601c69a630341cf5b5f53c359762dd1"],
           let authToken = ProcessInfo.processInfo.environment["60b993b0eaafa41efcba478e47b0e55b"] {
            
            let url = "https://api.twilio.com/2010-04-01/Accounts/\(accountSID)/Messages"
            let parameters = ["From": "+15162523119", "To": "+923355269449", "Body": "Hello from Swift, It's a testing message from test app!"]
            
            ViewController.session.request(url, method: .post, parameters: parameters)
                .authenticate(username: accountSID, password: authToken)
                .responseData { response in
                    switch response.result {
                    case .success(let data):
                        print(data)
                        DispatchQueue.main.async {
                            self.messageLbl.text = response.debugDescription
                        }
                    case .failure(let err):
                        print(err)
                    }
                }
        }
        
        /*
         
            
            AF.request(url, method: .post, parameters: parameters)
                .authenticate(username: accountSID, password: authToken)
                .responseData { response in
                    switch response.result {
                    case .success(let data):
                        print(data)
                    case .failure(let err):
                        print(err)
                    }
                }
            
            Alamofire.AF.request(url, method: .post, parameters: parameters)
                .authenticate(username: accountSID, password: authToken)
                .responseJSON { response in
                    debugPrint(response)
                    DispatchQueue.main.async {
                        self.messageLbl.text = response.debugDescription
                    }
                }
         
         
         var swiftRequest = SwiftRequest();
         
        if let accountSID = ProcessInfo.processInfo.environment["ACa601c69a630341cf5b5f53c359762dd1"],
           let authToken = ProcessInfo.processInfo.environment["60b993b0eaafa41efcba478e47b0e55b"] {
            
            let url = "https://api.twilio.com/2010-04-01/Accounts/\(accountSID)/Messages"
            let parameters = ["From": "+15162523119", "To": "+923355269449", "Body": "Hello from Swift, It's a testing message from test app!"]
            let auth = ["username" : "[\(accountSID)]", "password" : "\(authToken)"]
            
            swiftRequest.post(url: url,
                              data: parameters,
                              auth: auth) { err, response, body in
                if err == nil {
                    print("Success: \(response)")
                } else {
                    print("Error: \(err)")
                }
            }
        }
            */
    }
}



extension String {
    var htmlToAttributedString: NSAttributedString? {
        guard let data = data(using: .utf8) else { return nil }
        do {
            return try NSAttributedString(data: data, options: [.documentType: NSAttributedString.DocumentType.html, .characterEncoding:String.Encoding.utf8.rawValue], documentAttributes: nil)
        } catch {
            return nil
        }
    }
    var htmlToString: String {
        return htmlToAttributedString?.string ?? ""
    }
}
