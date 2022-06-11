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
    
    let localRealm = try! Realm()
    var task: Results<RecordObject>!
    var filteredTask: Results<RecordObject>! {
        didSet {
            tableView.reloadData()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
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
    
    func filterContentForSearchText(_ searchText: String, scope: String = "All") {
        filteredTask = searchText.isEmpty ? task : task.filter("memo CONTAINS[c] %@", searchText)
        self.tableView.reloadData()
    }
}

extension RecordsViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let rdv = self.storyboard?.instantiateViewController(withIdentifier: "RecordDetail") as! RecordDetailViewController
        rdv.recordData = self.filteredTask[indexPath.row]
        
        self.navigationController?.pushViewController(rdv, animated: true)
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "Record", for: indexPath) as? RecordsTableViewCell else {
            return UITableViewCell()
        }
        
        let image = UIImage(data: task[indexPath.row].image)
        let date = filteredTask[indexPath.row].date
        let dateformatter = DateFormatter()
        dateformatter.dateFormat = "YYYY년 MM월 dd일 HH:mm"
        let stringDate = dateformatter.string(from: date)
        let distanceformatter = MKDistanceFormatter()
        distanceformatter.units = .metric
        let stringDistance = distanceformatter.string(fromDistance: filteredTask[indexPath.row].distance)
        
        cell.mapImageView.image = image
        cell.dateLabel.text = stringDate
        cell.distanceLabel.text = stringDistance
        cell.timeLabel.text = filteredTask[indexPath.row].time

        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 98
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
