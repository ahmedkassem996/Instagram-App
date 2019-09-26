//
//  ViewController.swift
//  InstegramFirebase
//
//  Created by AHMED on 6/10/1398 AP.
//  Copyright © 1398 AHMED. All rights reserved.
//

import UIKit
import Firebase

class SignUpController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
  
  let plusPhotoBtn: UIButton = {
    let button = UIButton(type: .system)
    button.setImage(UIImage(named: "plusPhoto")?.withRenderingMode(.alwaysOriginal), for: .normal)
    button.addTarget(self, action: #selector(handlePlusPhoto), for: .touchUpInside)
    return button
  }()
  
  @objc func handlePlusPhoto(){
    let imagePickerController = UIImagePickerController()
    imagePickerController.delegate = self
    imagePickerController.allowsEditing = true
    present(imagePickerController, animated: true, completion: nil)
  }
  
  func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
    if let editedImage = info[UIImagePickerController.InfoKey.editedImage] as? UIImage {
      plusPhotoBtn.setImage(editedImage.withRenderingMode(.alwaysOriginal), for: .normal)
    }else if let chosenImage = info[.originalImage] as? UIImage {
      plusPhotoBtn.setImage(chosenImage.withRenderingMode(.alwaysOriginal), for: .normal)
    } else{
      print("Something went wrong")
    }
    
    plusPhotoBtn.layer.cornerRadius = plusPhotoBtn.frame.width / 2
    plusPhotoBtn.layer.masksToBounds = true
    plusPhotoBtn.layer.borderColor = UIColor.black.cgColor
    plusPhotoBtn.layer.borderWidth = 3
    dismiss(animated: true, completion: nil)
  }
  
  let emailTextField: UITextField = {
    let tf = UITextField()
    tf.placeholder = "Email"
    tf.backgroundColor = UIColor(white: 0, alpha: 0.03)
    tf.borderStyle = .roundedRect
    tf.font = UIFont.systemFont(ofSize: 14)
    
    tf.addTarget(self, action: #selector(handleTxtInputChange), for: .editingChanged)
    
    return tf
  }()
  
  @objc func handleTxtInputChange(){
    let isFormValid = !(emailTextField.text?.isEmpty)!  && !(usernameTextField.text?.isEmpty)! && !(passwordTextField.text?.isEmpty)!
    
    if isFormValid{
      signUpBtn.isEnabled = true
      signUpBtn.backgroundColor = UIColor.rgb(red: 17, green: 154, blue: 237)
    }else{
      signUpBtn.isEnabled = false
      signUpBtn.backgroundColor = UIColor.rgb(red: 149, green: 204, blue: 244)
    }
    
  }

  
  let usernameTextField: UITextField = {
    let tf = UITextField()
    tf.placeholder = "Username"
    tf.backgroundColor = UIColor(white: 0, alpha: 0.03)
    tf.borderStyle = .roundedRect
    tf.font = UIFont.systemFont(ofSize: 14)
    
    tf.addTarget(self, action: #selector(handleTxtInputChange), for: .editingChanged)
    
    return tf
  }()
  
  let passwordTextField: UITextField = {
    let tf = UITextField()
    tf.placeholder = "Password"
    tf.isSecureTextEntry = true
    tf.backgroundColor = UIColor(white: 0, alpha: 0.03)
    tf.borderStyle = .roundedRect
    tf.font = UIFont.systemFont(ofSize: 14)
    
    tf.addTarget(self, action: #selector(handleTxtInputChange), for: .editingChanged)
    
    return tf
  }()
  
  let signUpBtn: UIButton = {
    let button = UIButton(type: .system)
    button.setTitle("Sign Up", for: .normal)
    button.backgroundColor = UIColor.rgb(red: 149, green: 204, blue: 244)
    button.layer.cornerRadius = 5
    button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 14)
    button.setTitleColor(.white, for: .normal)
    
    button.addTarget(self, action: #selector(handleSignUp), for: .touchUpInside)
    
    button.isEnabled = false
    return button
  }()
  
  @objc func handleSignUp(){
    
    guard let email = emailTextField.text, !email.isEmpty else { return }
    guard let username = usernameTextField.text, !username.isEmpty else { return }
    guard let password = passwordTextField.text, !password.isEmpty else { return }
    
    Auth.auth().createUser(withEmail: email, password: password) { (user, error) in
      if let err = error{
        print("failed to create user", err)
        return
      }
      
      print("successfully created user:", user?.user.uid ?? "")
      
      guard let image = self.plusPhotoBtn.imageView?.image else { return }
      guard let uploadData = image.jpegData(compressionQuality: 0.3) else { return }
      
      let fileName = NSUUID().uuidString
      
      Storage.storage().reference().child("profile_image").child(fileName).putData(uploadData, metadata: nil, completion: { (metadata, err) in
        
        if let err = err{
          print("Failed to upload profile image", err)
          return
        }
        
   //     guard let profileImageUrl = metadata?.downloadURL()?.absoluteString else { return }
        print("Successfully uploaded profile image")
        
        guard let uid = user?.user.uid else { return }
        
        let dictionaryValues = ["username": username/*, "profileImageUrl": profileImageUrl*/]
        let values = [uid: dictionaryValues]
        
        Database.database().reference().child("users").updateChildValues(values, withCompletionBlock: { (err, ref) in
          
          if let err = err{
            print("Failed to save user info into DB", err)
            return
          }
          
          print("Successfully saved user info into DB")
          
        })
      })
    }
  }

  override func viewDidLoad() {
    super.viewDidLoad()
    
    setupViewBtn()
    setupInputFields()
  }
  
  fileprivate func setupViewBtn(){
    
    view.addSubview(plusPhotoBtn)
    
    plusPhotoBtn.anchor(top: view.topAnchor, left: nil, bottom: nil, right: nil, paddingTop: 40, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 140, height: 140)
    
    NSLayoutConstraint.activate([
      plusPhotoBtn.centerXAnchor.constraint(equalTo: view.centerXAnchor),
      
      ])
  }
  
  fileprivate func setupInputFields(){
    
    let stackView = UIStackView(arrangedSubviews: [emailTextField, usernameTextField, passwordTextField, signUpBtn])
    stackView.distribution = .fillEqually
    stackView.axis = .vertical
    stackView.spacing = 10
    
    view.addSubview(stackView)
    
    stackView.anchor(top: plusPhotoBtn.bottomAnchor, left: view.leftAnchor, bottom: nil, right: view.rightAnchor, paddingTop: 80, paddingLeft: 40, paddingBottom: 0, paddingRight: 40, width: 0, height: 200)
  }
}

extension UIView{
  func anchor(top: NSLayoutYAxisAnchor?, left: NSLayoutXAxisAnchor?, bottom: NSLayoutYAxisAnchor?, right: NSLayoutXAxisAnchor?, paddingTop: CGFloat, paddingLeft: CGFloat, paddingBottom: CGFloat, paddingRight: CGFloat, width: CGFloat, height: CGFloat){
    
    translatesAutoresizingMaskIntoConstraints = false
    
    if let top = top{
      self.topAnchor.constraint(equalTo: top, constant: paddingTop).isActive = true
    }
    
    if let left = left{
      self.leftAnchor.constraint(equalTo: left, constant: paddingLeft).isActive = true
    }
    
    if let bottom = bottom{
      bottomAnchor.constraint(equalTo: bottom, constant: paddingBottom).isActive = true
    }
    
    if let right = right{
      rightAnchor.constraint(equalTo: right, constant: -paddingRight).isActive = true
    }
    
    if width != 0{
      widthAnchor.constraint(equalToConstant: width).isActive = true
    }
    
    if height != 0{
      heightAnchor.constraint(equalToConstant: height).isActive = true
    }
    
  }
}

