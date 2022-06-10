//
//  SettingsViewController.swift
//  Rife - Simple Run Life
//
//  Created by 경원이 on 2021/11/18.
//

import UIKit
import Zip
import MobileCoreServices

class SettingsViewController: UIViewController, UIDocumentPickerDelegate {
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    func onBackupButtonClicked() {
        var urlPaths = [URL]()
        
        if let path = getDocumentDirectoryPath() {
            let realm = (path as NSString).appendingPathComponent("default.realm")

            if FileManager.default.fileExists(atPath: realm) {
                urlPaths.append(URL(string: realm)!)
            } else {
                print("백업할 파일이 없습니다")
            }
        }

        do {
            let zipFilePath = try Zip.quickZipFiles(urlPaths, fileName: "archive") // Zip 경로
            print("압축 경로 : ", zipFilePath)
            presentActivityViewController()
        } catch {
            print("Something went wrong")
        }
    }
    
    func onRestoreButtonClicked() {
        let alert = UIAlertController(title: "데이터 복구", message: "데이터 복구가 완료되면 앱이 종료됩니다.", preferredStyle: .alert)
        let ok = UIAlertAction(title: "확인", style: .default) { _ in
            let documentPicker = UIDocumentPickerViewController(documentTypes: [kUTTypeArchive as String], in: .import)
            documentPicker.delegate = self
            documentPicker.allowsMultipleSelection = false
            
            self.present(documentPicker, animated: true, completion: nil)
        }
        
        let cancel = UIAlertAction(title: "취소", style: .cancel)
        alert.addAction(ok)
        alert.addAction(cancel)
        
        present(alert, animated: true, completion: nil)
        
    }
    
    func getDocumentDirectoryPath() -> String? {
        let documentDirectory = FileManager.SearchPathDirectory.documentDirectory
        let userDomainMask = FileManager.SearchPathDomainMask.userDomainMask
        let path = NSSearchPathForDirectoriesInDomains(documentDirectory, userDomainMask, true)

        if let directoryPath = path.first {
            return directoryPath
        } else {
            return nil
        }
    }
    
    func presentActivityViewController() {
        let fileName = (getDocumentDirectoryPath()! as NSString).appendingPathComponent("archive.zip")
        let fileURL = URL(fileURLWithPath: fileName)
        let vc = UIActivityViewController(activityItems: [fileURL], applicationActivities: [])
        
        self.present(vc, animated: true, completion: nil)
    }
    
    func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
        guard let selectedFileURL = urls.first else { return }
        
        let directory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        let sandboxFileURL = directory.appendingPathComponent(selectedFileURL.lastPathComponent)

        if FileManager.default.fileExists(atPath: sandboxFileURL.path) {
             do {
                let documentDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
                let fileURL = documentDirectory.appendingPathComponent("archive.zip")
                
                try Zip.unzipFile(fileURL, destination: documentDirectory, overwrite: true, password: nil, progress: { progress in
                    print("progress : ", progress)
                }, fileOutputHandler: { unzippedFile in
                    print("unzippedFile : ",unzippedFile)
                    exit(0)
                })
            } catch {
                print("error")
            }
        } else {
            do {
                try FileManager.default.copyItem(at: selectedFileURL, to: sandboxFileURL)

                let documentDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
                let fileURL = documentDirectory.appendingPathComponent("archive.zip")
                
                try Zip.unzipFile(fileURL, destination: documentDirectory, overwrite: true, password: nil, progress: { progress in
                    print("progress : ", progress)
                }, fileOutputHandler: { unzippedFile in
                    print("unzippedFile : ",unzippedFile)
                })
            } catch {
                print("error")
            }
        }
    }
}


