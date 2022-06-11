//
//  SideMenuViewController.swift
//  Rife - Simple Run Life
//
//  Created by 배경원 on 2021/11/17.
//

import UIKit

@available(iOS 14.0, *)
class SideMenuViewController: UIViewController {
    
    
    

    @IBOutlet var sideMenuView: UIView!
    @IBOutlet var myProfileButton: UIButton!
    @IBOutlet var contactButton: UIButton!
    @IBOutlet var settingsButton: UIButton!
    @IBOutlet var recordsButton: UIButton!
    override func viewDidLoad() {
        super.viewDidLoad()
        sideMenuView.layer.borderColor = UIColor(named: "black")?.cgColor
        sideMenuView.layer.borderWidth = 1
        self.navigationController?.isNavigationBarHidden = true
        
        let profileNSAS = outline(string: "MY PROFILE", font: "NotoSansKR-Black", size: 25, outlineSize: 4, textColor: .white, outlineColor: .black)
        let recordsNSAS = outline(string: "RECORDS", font: "NotoSansKR-Black", size: 25, outlineSize: 4, textColor: .white, outlineColor: .black)
        let settingsNSAS = outline(string: "SETTINGS", font: "NotoSansKR-Black", size: 25, outlineSize: 4, textColor: .white, outlineColor: .black)
        let contactNSAS = outline(string: "CONTACT", font: "NotoSansKR-Black", size: 25, outlineSize: 4, textColor: .white, outlineColor: .black)
        
        myProfileButton.setAttributedTitle(profileNSAS, for: .normal)
        recordsButton.setAttributedTitle(recordsNSAS, for: .normal)
        settingsButton.setAttributedTitle(settingsNSAS, for: .normal)
        contactButton.setAttributedTitle(contactNSAS, for: .normal)
        
        
        
        
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
    @IBAction func profileButtonClicked(_ sender: UIButton) {
        let storyboard = UIStoryboard(name: "Profile", bundle: nil)
        let pv = storyboard.instantiateViewController(withIdentifier: "Profile") as! ProfileViewController
        
//        pv.modalPresentationStyle = .fullScreen
//        present(pv, animated: true, completion: nil)
        self.navigationController?.pushViewController(pv, animated: true)
    }
    
    @IBAction func recordButtonClicked(_ sender: UIButton) {
        let storyboard = UIStoryboard(name: "Records", bundle: nil)
        let rv = storyboard.instantiateViewController(withIdentifier: "Records") as! RecordsViewController

        
        self.navigationController?.pushViewController(rv, animated: true)
    }
    
    @IBAction func settingsButtonClicked(_ sender: UIButton) {
        let storyboard = UIStoryboard(name: "Settings", bundle: nil)
        let sv = storyboard.instantiateViewController(withIdentifier: "Settings") as! SettingsViewController
        
        self.navigationController?.pushViewController(sv, animated: true)
    }
    
    @IBAction func contactButtonClicked(_ sender: UIButton) {
        let storyboard = UIStoryboard(name: "Contact", bundle: nil)
        let cv = storyboard.instantiateViewController(withIdentifier: "Contact") as! ContactViewController
        
        self.navigationController?.pushViewController(cv, animated: true)
        
    }
}

