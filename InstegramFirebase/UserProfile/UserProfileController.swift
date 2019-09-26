//
//  UserProfileController.swift
//  InstegramFirebase
//
//  Created by AHMED on 6/11/1398 AP.
//  Copyright © 1398 AHMED. All rights reserved.
//

import UIKit
import  Firebase

class UserProfileController: UICollectionViewController, UICollectionViewDelegateFlowLayout{
  override func viewDidLoad() {
    super.viewDidLoad()
    
    collectionView.backgroundColor = .white
    
    navigationItem.title = Auth.auth().currentUser?.uid
    
    fetchUser()
    
    collectionView?.register(UICollectionViewCell.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: "headerId")
  }
  
  override func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
    let header = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "headerId", for: indexPath)
    
    header.backgroundColor = .green
    
    return header
  }
  
  func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
    return CGSize(width: view.frame.width, height: 200)
  }
  
  fileprivate func fetchUser(){
    guard let uid = Auth.auth().currentUser?.uid else { return }
    
    Database.database().reference().child("users").child(uid).observeSingleEvent(of: .value, with: { (snapshot) in
      print(snapshot.value ?? "")
      
      guard let dictionary = snapshot.value as? [String: Any] else {return}
      
      let username = dictionary["username"] as? String
      self.navigationItem.title = username
    }) { (err) in
      print("Failed to fetch user:", err)
    }
  }
}
