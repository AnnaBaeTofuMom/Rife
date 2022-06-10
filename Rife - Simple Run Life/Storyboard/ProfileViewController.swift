//
//  ProfileViewController.swift
//  Rife - Simple Run Life
//
//  Created by 배경원 on 2021/11/17.
//

import UIKit
import NotificationBannerSwift


class ProfileViewController: UIViewController, UINavigationControllerDelegate, UITextFieldDelegate {
    
    let imagePicker = UIImagePickerController()

    @IBOutlet var backButton: UIButton!
    @IBOutlet var totalDistanceField: UITextField!
    @IBOutlet var mottoField: UITextField!
    @IBOutlet var heightField: UITextField!
    @IBOutlet var nameField: UITextField!
    @IBOutlet var mainView: UIView!
    @IBOutlet var editButton: UIButton!
    @IBOutlet var profileImageView: UIImageView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        backButton.setTitle("", for: .normal)
        editButton.setTitle("", for: .normal)
        imagePicker.delegate = self
        self.navigationItem.hidesBackButton = true
        self.navigationController?.isNavigationBarHidden = true
        
        profileImageView.layer.cornerRadius = profileImageView.frame.height/2
        profileImageView.layer.borderColor = UIColor(red: 0.4941, green: 0.9922, blue: 0.6941, alpha: 1.0).cgColor
        profileImageView.layer.borderWidth = 1
        profileImageView.clipsToBounds = true
        if let data: Data = UserDefaults.standard.data(forKey: "userImage") {
            let image = UIImage(data: data)
            profileImageView.image = image
            nameField.delegate = self
            heightField.delegate = self
            mottoField.delegate = self
        }
        
        
        
        
        nameField.text = UserDefaults.standard.string(forKey: "userName")
        nameField.layer.borderColor = UIColor(red: 0.4941, green: 0.9922, blue: 0.6941, alpha: 1.0).cgColor
        nameField.layer.borderWidth = 1
        nameField.attributedPlaceholder = NSAttributedString(string: "YOUR NAME", attributes: [NSAttributedString.Key.foregroundColor : UIColor(red: 0.4941, green: 0.9922, blue: 0.6941, alpha: 1.0)])
        
        
        heightField.text = UserDefaults.standard.string(forKey: "userHeight")
        heightField.layer.borderColor = UIColor(red: 0.4941, green: 0.9922, blue: 0.6941, alpha: 1.0).cgColor
        heightField.layer.borderWidth = 1
        heightField.attributedPlaceholder = NSAttributedString(string: "YOUR HEIGHT", attributes: [NSAttributedString.Key.foregroundColor : UIColor(red: 0.4941, green: 0.9922, blue: 0.6941, alpha: 1.0)])
        
        mottoField.text = UserDefaults.standard.string(forKey: "userMotto")
        mottoField.layer.borderColor = UIColor(red: 0.4941, green: 0.9922, blue: 0.6941, alpha: 1.0).cgColor
        mottoField.layer.borderWidth = 1
        mottoField.attributedPlaceholder = NSAttributedString(string: "YOUR MOTTO", attributes: [NSAttributedString.Key.foregroundColor : UIColor(red: 0.4941, green: 0.9922, blue: 0.6941, alpha: 1.0)])
        
        totalDistanceField.layer.borderColor = UIColor(red: 0.4941, green: 0.9922, blue: 0.6941, alpha: 1.0).cgColor
        totalDistanceField.layer.borderWidth = 1
        totalDistanceField.text = "YOU DIDN'T RUN YET"

        // Do any additional setup after loading the view.
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        print("dddddd")
        if nameField.isEditing == true {
            nameField.placeholder = ""
        }
        if mottoField.isEditing == true {
            mottoField.placeholder = ""
        }
        if heightField.isEditing == true {
            heightField.placeholder = ""
        }
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        nameField.placeholder = "YOUR NAME"
        mottoField.placeholder = "YOUR MOTTO"
        heightField.placeholder = "YOUR HEIGHT"
    }
   
    func openLibrary(){

      imagePicker.sourceType = .photoLibrary

      present(imagePicker, animated: false, completion: nil)

    }

    func openCamera(){

        if(UIImagePickerController .isSourceTypeAvailable(.camera)){

        imagePicker.sourceType = .camera

                    present(imagePicker, animated: false, completion: nil)

                }

                else{

                    print("Camera not available")

                }


    }

    @IBAction func backButtonClicked(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }

    @IBAction func tap(_ sender: Any) {
        view.endEditing(true)
    }
    @IBAction func saveButtonClicked(_ sender: UIButton) {
        let data = profileImageView.image?.jpegData(compressionQuality: 1)
        
        
        UserDefaults.standard.set(data, forKey: "userImage")
        UserDefaults.standard.set("\(nameField.text!)", forKey: "userName")
        UserDefaults.standard.set("\(heightField.text!)", forKey: "userHeight")
        UserDefaults.standard.set("\(mottoField.text!)", forKey: "userMotto")
        
        let banner = NotificationBanner(title: "Well saved!", subtitle: "Your profile has been successfully saved!", style: .success)
        banner.show()
        
    }
    @IBAction func editButtonClicked(_ sender: UIButton) {
        let alert = UIAlertController(title: "이미지 불러오기", message: "이미지를 불러올 방법을 선택해 주세요.", preferredStyle: .actionSheet)
        let library = UIAlertAction(title: "앨범에서 선택", style: .default) { action in
            self.openLibrary()
        }
        let camera = UIAlertAction(title: "사진 찍기", style: .default) { action in
            self.openCamera()
        }
        let cancel = UIAlertAction(title: "취소", style: .cancel, handler: nil)
        
        alert.addAction(library)
        alert.addAction(camera)
        alert.addAction(cancel)
        
        present(alert, animated: true, completion: nil)
        
        
    }
    
}

extension ProfileViewController : UIImagePickerControllerDelegate{

    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let image = info[UIImagePickerController.InfoKey.originalImage] as? UIImage{

                    profileImageView.image = image

                    print(info)

                }

                dismiss(animated: true, completion: nil)


    }

}
