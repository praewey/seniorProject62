//
//  ActivityDetailViewController.swift
//  seniorProject62
//
//  Created by Praewey Spokkokkak on 24/1/2563 BE.
//  Copyright © 2563 Praewey Spokkokkak. All rights reserved.
//

import UIKit
import Firebase
import AlamofireImage

class ActivityDetailViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    
    @IBOutlet weak var imageCollectionView: UICollectionView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var companyLabel: UILabel!
    @IBOutlet weak var descTextView: UITextView!
    @IBOutlet weak var placeTextView: UITextView!
    @IBOutlet weak var dateTextView: UITextView!
    @IBOutlet weak var contactTextView: UITextView!
    @IBOutlet weak var favoriteBtn: UIButton!
    
    var selectedActivity: Activity?
    
    let dateFormatter = DateFormatter()
    let db = Firestore.firestore()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        imageCollectionView.dataSource = self
        imageCollectionView.delegate = self
        
        dateFormatter.dateFormat = "dd MMMM yyyy"
        dateFormatter.locale = Locale(identifier: "th-TH")
        
        titleLabel.text = selectedActivity!.title
        companyLabel.text = selectedActivity!.company
        descTextView.text = selectedActivity!.desc
        placeTextView.text = selectedActivity!.place
        dateTextView.text = dateFormatter.string(from: selectedActivity!.date.dateValue())
        
        
        let htmlData = NSString(string: selectedActivity!.contact).data(using: String.Encoding.unicode.rawValue)
        
        let options = [NSAttributedString.DocumentReadingOptionKey.documentType: NSAttributedString.DocumentType.html]
        
        let attributedString = try! NSAttributedString(data: htmlData!, options: options, documentAttributes: nil)
        
        contactTextView.attributedText = attributedString
        
        favoriteBtn.tintColor = selectedActivity!.favorited ? #colorLiteral(red: 0.8078431487, green: 0.02745098062, blue: 0.3333333433, alpha: 1) : #colorLiteral(red: 0.2549019754, green: 0.2745098174, blue: 0.3019607961, alpha: 1)
        
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        db.collection("reads").whereField("email", isEqualTo: Auth.auth().currentUser?.email ?? "").getDocuments { queryRead, errorRead in
            
            let reads = queryRead!.documents
            if reads.count > 0 {
                var readArray = reads.first!.data()["reads"] as! [String]
                let dup = readArray.filter { id in
                    return id == self.selectedActivity!.id
                }
                
                if dup.count == 0 {
                    readArray.append(self.selectedActivity!.id)
                    self.db.collection("reads").document(reads.first!.documentID).setData(["email": Auth.auth().currentUser?.email ?? "", "reads": readArray], merge: false)
                }
                
            } else {
                self.db.collection("reads").addDocument(data: ["email": Auth.auth().currentUser?.email ?? "", "reads": [self.selectedActivity!.id]]) 
            }
        }
        
    }
    
    @IBAction func touchFavorite(_ sender: Any) {
        favoriteBtn.isUserInteractionEnabled = false
        
        if selectedActivity!.favorited {
            db.collection("activityFavorites").whereField("email", isEqualTo: Auth.auth().currentUser?.email ?? "").getDocuments { queryFavorite, errorFavorite in
                
                let favorites = queryFavorite!.documents
                var favoriteArray = favorites.first!.data()["favorites"] as! [String]
                favoriteArray.removeAll { id in
                    return id == self.selectedActivity!.id
                }
                self.db.collection("activityFavorites").document(favorites.first!.documentID).setData(["email": Auth.auth().currentUser?.email ?? "", "favorites": favoriteArray], merge: false)
                
                self.favoriteBtn.isUserInteractionEnabled = true
                self.favoriteBtn.tintColor = #colorLiteral(red: 0.2549019754, green: 0.2745098174, blue: 0.3019607961, alpha: 1)
            }
            
        } else {
            db.collection("activityFavorites").whereField("email", isEqualTo: Auth.auth().currentUser?.email ?? "").getDocuments { queryFavorite, errorFavorite in
                
                let favorites = queryFavorite!.documents
                if favorites.count > 0 {
                    var favoriteArray = favorites.first!.data()["favorites"] as! [String]
                    let dup = favoriteArray.filter { id in
                        return id == self.selectedActivity!.id
                    }
                    
                    if dup.count == 0 {
                        favoriteArray.append(self.selectedActivity!.id)
                        self.db.collection("activityFavorites").document(favorites.first!.documentID).setData(["email": Auth.auth().currentUser?.email ?? "", "favorites": favoriteArray], merge: false)
                    }
                    
                } else {
                    self.db.collection("activityFavorites").addDocument(data: ["email": Auth.auth().currentUser?.email ?? "", "favorites": [self.selectedActivity!.id]])
                }
                
                self.favoriteBtn.isUserInteractionEnabled = true
                self.favoriteBtn.tintColor = #colorLiteral(red: 0.8078431487, green: 0.02745098062, blue: 0.3333333433, alpha: 1) 
            }
        }
    }
    
    @IBAction func touchBack(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return selectedActivity!.images.count
        
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = imageCollectionView.dequeueReusableCell(withReuseIdentifier: "ImageCollectionViewCell", for: indexPath) as! ImageCollectionViewCell
        cell.imageView.af_setImage(withURL: URL(string: selectedActivity!.images[indexPath.row])!)
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: UIScreen.main.bounds.width, height: 250)
    }
}
