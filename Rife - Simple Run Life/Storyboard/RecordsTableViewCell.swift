//
//  RecordsTableViewCell.swift
//  Rife - Simple Run Life
//
//  Created by 배경원 on 2021/11/19.
//

import UIKit

@available(iOS 14.0, *)
class RecordsTableViewCell: UITableViewCell {

    @IBOutlet var cellView: UIView!
    @IBOutlet var mapImageView: UIImageView!
    @IBOutlet var dateLabel: UILabel!
    @IBOutlet var distanceLabel: UILabel!
    @IBOutlet var timeLabel: UILabel!
    
    

    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        dateLabel.font = UIFont(name: "NotoSansKR-Black", size: 20)
        distanceLabel.font = UIFont(name: "NotoSansKR-Black", size: 17)
        timeLabel.font = UIFont(name: "NotoSansKR-Black", size: 17)
        

        let storyboard = UIStoryboard(name: "Map", bundle: nil)
        let mv = storyboard.instantiateViewController(withIdentifier: "Map") as! MapViewController
        
        mapImageView.image = mv.recordImage
        mapImageView.layer.cornerRadius = mapImageView.frame.width * 0.05
        mapImageView.layer.borderWidth = 1
        mapImageView.layer.borderColor = UIColor(red: 0, green: 0, blue: 0, alpha: 1.0).cgColor
        
        
        mapImageView.backgroundColor = .black
        cellView.backgroundColor = UIColor(red: 0.9882, green: 0.8667, blue: 0.9255, alpha: 1.0)
        cellView.layer.borderWidth = 1
        cellView.layer.borderColor = UIColor(red: 0, green: 0, blue: 0, alpha: 1.0).cgColor
        
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    
        // Configure the view for the selected state
    }

}

