//
//  RecordTableViewCell.swift
//  Rife - Simple Run Life
//
//  Created by 경원이 on 2022/06/21.
//

import UIKit

class RecordTableViewCell: UITableViewCell {
    
    static let identifier = "record"
    
    var mapImage: UIImageView = {
        let imgView = UIImageView()
        imgView.image = UIImage(named: "background_green_img")
        return imgView
    }()
    
    var titleLabel: UILabel = {
        let label = UILabel()
        label.text = "Sunday Run"
        return label
    }()
    
    var dateLabel: UILabel = {
        let label = UILabel()
        label.text = "2022년 6월 20일"
        return label
    }()
    
    var timeLabel: UILabel = {
        let label = UILabel()
        label.text = "00:00:00"
        return label
    }()
    
    var distanceLabel: UILabel = {
        let label = UILabel()
        label.text = "42.195km"
        return label
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        configuration()
        makeConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
    }
    
    func configuration() {
        contentView.addSubview(mapImage)
        contentView.addSubview(titleLabel)
        contentView.addSubview(timeLabel)
        contentView.addSubview(distanceLabel)
        contentView.addSubview(dateLabel)
        
        titleLabel.font = UIFont(name: "DINCondensed-Bold", size: 22)
        timeLabel.font = UIFont(name: "DINCondensed-Bold", size: 17)
        distanceLabel.font = UIFont(name: "DINCondensed-Bold", size: 17)
        dateLabel.font = UIFont(name: "DINCondensed-Bold", size: 17)
        
        mapImage.layer.cornerRadius = 5
    }
    
    func makeConstraints() {
        mapImage.snp.makeConstraints { make in
            make.width.height.equalTo(50)
            make.top.leading.bottom.equalToSuperview().inset(15)
        }
        
        titleLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(15)
            make.leading.equalTo(mapImage.snp.trailing).offset(12)
        }
        
        dateLabel.snp.makeConstraints { make in
            make.leading.equalTo(mapImage.snp.trailing).offset(12)
            make.bottom.equalTo(mapImage.snp.bottom)
        }
        
        timeLabel.snp.makeConstraints { make in
            make.leading.equalTo(dateLabel.snp.trailing).offset(12)
            make.bottom.equalTo(mapImage.snp.bottom)
        }
        
        distanceLabel.snp.makeConstraints { make in
            make.leading.equalTo(timeLabel.snp.trailing).offset(12)
            make.bottom.equalTo(mapImage.snp.bottom)
        }
    }
    
    
    
    
    
}
