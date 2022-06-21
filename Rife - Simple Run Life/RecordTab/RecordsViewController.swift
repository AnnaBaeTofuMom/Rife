//
//  RecordsViewController.swift
//  Rife - Simple Run Life
//
//  Created by 경원이 on 2021/11/18.
//

import UIKit
import RealmSwift
import MapKit

@available(iOS 14.0, *)
class RecordsViewController: UIViewController {
    var tableView = UITableView()
    var searchBar = UISearchBar()
    var task: Results<RecordObject>!
    var filteredTask: Results<RecordObject>! {
        didSet {
            tableView.reloadData()
        }
    }
    let localRealm = try! Realm()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.addSubview(tableView)
        view.addSubview(searchBar)
        
        configuration()
        constraints()
        setNavigator()
        
        searchBar.placeholder = "작성하신 메모로 기록을 검색해보세요."
        task = localRealm.objects(RecordObject.self)
        filteredTask = localRealm.objects(RecordObject.self)
        
        tableView.dataSource = self
        tableView.delegate = self
        searchBar.delegate = self
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?){
        self.view.endEditing(true)
    }
    
    func configuration() {
        view.backgroundColor = UIColor(named: "background_green")
        tableView.backgroundColor = UIColor(named: "background_green")
        searchBar.backgroundImage = UIImage(named: "background_green_img")
        
        tableView.register(RecordTableViewCell.self, forCellReuseIdentifier: RecordTableViewCell.identifier)
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 80
    }
    
    func constraints() {
        searchBar.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide)
            make.leading.trailing.equalToSuperview()
        }
        
        tableView.snp.makeConstraints { make in
            make.top.equalTo(searchBar.snp.bottom)
            make.leading.trailing.equalToSuperview()
            make.bottom.equalTo(view.safeAreaLayoutGuide)
        }
    }
    
    func setNavigator() {
        let leftNavButton = UIBarButtonItem()
        let rightNavButton = UIBarButtonItem()
        
        leftNavButton.image = UIImage(named: "rife_icon")?.withRenderingMode(.alwaysOriginal)
        rightNavButton.image = UIImage(named: "setting_icon")?.withRenderingMode(.alwaysOriginal)
        
        self.navigationItem.leftBarButtonItem = leftNavButton
        self.navigationItem.rightBarButtonItem = rightNavButton
    }
    
    func filterContentForSearchText(_ searchText: String, scope: String = "All") {
        filteredTask = searchText.isEmpty ? task : task.filter("memo CONTAINS[c] %@", searchText)
        self.tableView.reloadData()
    }
}

extension RecordsViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "record", for: indexPath) as? RecordTableViewCell else {
            return UITableViewCell()
        }
        
        let image = UIImage(data: task[indexPath.row].image)
        let date = filteredTask[indexPath.row].date
        let dateformatter = DateFormatter()
        dateformatter.dateFormat = "YYYY.MM.dd HH:mm"
        let stringDate = dateformatter.string(from: date)
        let distanceformatter = MKDistanceFormatter()
        distanceformatter.units = .metric
        let stringDistance = distanceformatter.string(fromDistance: filteredTask[indexPath.row].distance)
        
        cell.mapImage.image = image
        cell.dateLabel.text = stringDate
        cell.distanceLabel.text = stringDistance

        return cell
    }
}

extension RecordsViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        
        let taskToDelete = task[indexPath.row]
        if editingStyle == .delete {
            try! localRealm.write {
                localRealm.delete(taskToDelete)
            }
            tableView.reloadData()
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return filteredTask.count
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
}

extension RecordsViewController: UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        filterContentForSearchText(searchText)
        self.tableView.reloadData()
    }
    
}
