//
//  RecordDetailViewController.swift
//  Rife - Simple Run Life
//
//  Created by 배경원 on 2021/11/22.
//

import UIKit
import MapKit
import NotificationBannerSwift
import RealmSwift

class RecordDetailViewController: UIViewController {
        
    @IBOutlet var distanceLabel: UILabel!
    var recordData: RecordObject!
    let localRealm = try! Realm()
    
    @IBOutlet var saveButton: UIButton!
    @IBOutlet var backButton: UIButton!
    @IBOutlet var memoLabel: UILabel!
    @IBOutlet var memoTextView: UITextView!
    @IBOutlet var mapImageView: UIImageView!
    @IBOutlet var timeLabel: UILabel!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        saveButton.setTitle("", for: .normal)
        backButton.setTitle("", for: .normal)
        mapImageView.layer.cornerRadius = 5
        mapImageView.layer.borderColor = UIColor(hue: 0.4, saturation: 0.5, brightness: 0.99, alpha: 1.0).cgColor
        mapImageView.layer.borderWidth = 1
        self.navigationController?.isNavigationBarHidden = true
        
        let distanceformatter = MKDistanceFormatter()
        distanceformatter.units = .metric
        let stringDistance = distanceformatter.string(fromDistance: recordData.distance)
        
        let distanceNSAS = outline(string: "\(stringDistance)", font: "NotoSansKR-Black", size: 35, outlineSize: 3, textColor: UIColor(hue: 0.4, saturation: 0.5, brightness: 0.99, alpha: 1.0), outlineColor: .black)
        let timeNSAS = outline(string: "\(recordData.time)", font: "NotoSansKR-Black", size: 35, outlineSize: 3, textColor: UIColor(hue: 0.4, saturation: 0.5, brightness: 0.99, alpha: 1.0), outlineColor: .black)
        
        let memoNSAS = outline(string: "Memo", font: "NotoSansKR-Black", size: 22, outlineSize: 1, textColor: UIColor(hue: 0.4, saturation: 0.5, brightness: 0.99, alpha: 1.0), outlineColor: .clear)
        
        distanceLabel.attributedText = distanceNSAS
        timeLabel.attributedText = timeNSAS
        memoTextView.text = recordData.memo
        mapImageView.image = UIImage(data: recordData.image)
        memoLabel.attributedText = memoNSAS
        memoTextView.layer.cornerRadius = 5
        memoTextView.layer.borderWidth = 1
        memoTextView.layer.borderColor = UIColor(hue: 0.4, saturation: 0.5, brightness: 0.99, alpha: 1.0).cgColor
        memoTextView.text = recordData.memo
        
        
        
        
        
       
        
        
    }
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?){

         self.view.endEditing(true)

   }

  
    @IBAction func backButtonClicked(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func saveButtonClicked(_ sender: UIButton) {
        let taskToUpdate = recordData
        try! localRealm.write {
            taskToUpdate?.memo = memoTextView.text
        }
        let banner = NotificationBanner(title: "Well Saved!", subtitle: "Your memo is succesfully saved.", style: .success)
        banner.show()
    }
}
