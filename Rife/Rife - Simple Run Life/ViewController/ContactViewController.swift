//
//  ContactViewController.swift
//  Rife - Simple Run Life
//
//  Created by 경원이 on 2021/11/18.
//

import UIKit
import ChannelIOFront

class ContactViewController: UIViewController {

    @IBOutlet var backButton: UIButton!
    @IBOutlet var emailButton: UIButton!
    override func viewDidLoad() {
        super.viewDidLoad()
        backButton.setTitle("", for: .normal)
        emailButton.layer.cornerRadius = 15
        emailButton.layer.borderColor = UIColor(red: 0.4941, green: 0.9922, blue: 0.6941, alpha: 1.0).cgColor
        emailButton.layer.borderWidth = 1
        self.navigationItem.hidesBackButton = true
        
        let bootConfig = BootConfig(pluginKey: "399557e8-5324-4d03-b93a-ea5a5f2175a3")

        ChannelIO.boot(with: bootConfig) { (bootStatus, user) in
            if bootStatus == .success, let user = user {
                // success
            } else {
                // show failed reason from bootStatus
            }
        }
        
        ChannelIO.showChannelButton()
        
        
        // Do any additional setup after loading the view.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

    @IBAction func talkButton(_ sender: UIButton) {
        ChannelIO.showMessenger()

        
    }
    @IBAction func backButtonClicked(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
        ChannelIO.hideChannelButton()
    }
}
