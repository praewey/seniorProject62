//
//  ActivityViewController.swift
//  seniorProject62
//
//  Created by Praewey Spokkokkak on 24/1/2563 BE.
//  Copyright © 2563 Praewey Spokkokkak. All rights reserved.
//

import UIKit
import Firebase
import AlamofireImage

struct Activity {
    let id: String
    let title: String
    let desc: String
    let headerImage: String
    let date: Timestamp
    let company: String
    let place: String
    let contact: String
    let images: [String]
    let readed: Bool
    let favorited: Bool
}

class ActivityViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UISearchBarDelegate {
    
    @IBOutlet weak var activityTableView: UITableView!
    @IBOutlet weak var signinView: UIView!
    @IBOutlet weak var blankView: UIView!
    @IBOutlet weak var loadingView: UIView!
    @IBOutlet weak var loadingImageView: UIImageView!
    @IBOutlet weak var underlineAllView: UIView!
    @IBOutlet weak var underlineCurrentView: UIView!
    @IBOutlet weak var underlinePastView: UIView!
    @IBOutlet weak var underlineFavoriteView: UIView!
    
    @IBOutlet weak var allUIBtn: UIButton!
    @IBOutlet weak var currentUIBtn: UIButton!
    @IBOutlet weak var pastUIBtn: UIButton!
    @IBOutlet weak var favoriteUIBtn: UIButton!
    
    @IBOutlet weak var searchBar: UISearchBar!
    
    var activities: [Activity]  = []
    var filteredActivities: [Activity]  = []
    var selectedActivity: Activity?
    
    enum ActivityType {
        case all, current, past, favorite
    }
    var currentActivityType: ActivityType = .all
    
    let db = Firestore.firestore()
    let dateFormatter = DateFormatter()
    
    func updateUnreadMessage() {
        db.collection("activities").getDocuments { query, error in
            self.db.collection("reads").whereField("email", isEqualTo: Auth.auth().currentUser?.email ?? "").getDocuments { queryRead, errorRead in
                
                let reads = queryRead!.documents
                var unreadCount = 0
                if reads.count > 0 {
                    unreadCount = query!.count - (reads.first!.data()["reads"] as! [String]).count
                } else {
                    unreadCount = query!.count
                }
                
                if unreadCount > 0 {
                    self.tabBarController?.tabBar.items?[2].badgeValue = "\(unreadCount)"
                } else {
                    self.tabBarController?.tabBar.items?[2].badgeValue = nil
                }
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        dateFormatter.dateFormat = "dd MMMM yyyy"
        dateFormatter.locale = Locale(identifier: "th-TH")
        
        searchBar.delegate = self
        
        if Auth.auth().currentUser?.uid == nil{
            print("ยังไม่ได้เข้าสู่ระบบ")
            signinView.isHidden = false
            
        } else {
            print("เข้าสู่ระบบแล้ว")
            signinView.isHidden = true
        }
        
        activityTableView.dataSource = self //สั่งสร้าง
        activityTableView.delegate = self //ถ้าตารางเกิดอะไรขึ้น เช่น โดนคลิก
        
        UITableView.appearance().separatorColor = UIColor.clear
        
        underlineAllView.isHidden = false
        underlineCurrentView.isHidden = true
        underlinePastView.isHidden = true
        underlineFavoriteView.isHidden = true
        
        allUIBtn.setTitleColor(.link, for: .normal)
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        loadingImageView.loadGif(name: "loading")
        
        updateUnreadMessage()
        
        db.collection("activities").order(by: "createAt", descending: true).getDocuments { query, error in
            self.db.collection("reads").whereField("email", isEqualTo: Auth.auth().currentUser?.email ?? "").getDocuments { queryRead, errorRead in
                
                self.db.collection("activityFavorites").whereField("email", isEqualTo: Auth.auth().currentUser?.email ?? "").getDocuments { queryFavorite, errorFavorite in
                    
                    self.activities = []
                    
                    for activity in query!.documents {
                        let data = activity.data()
                        print(data)
                        
                        var readed = false
                        let reads = queryRead!.documents
                        if reads.count > 0 {
                            for read in reads.first!.data()["reads"] as! [String] {
                                if activity.documentID == read {
                                    readed = true
                                    break
                                }
                            }
                        }
                        
                        var favorited = false
                        let favorites = queryFavorite!.documents
                        if favorites.count > 0 {
                            for favorite in favorites.first!.data()["favorites"] as! [String] {
                                if activity.documentID == favorite {
                                    favorited = true
                                    break
                                }
                            }
                        }
                        
                        self.activities.append(Activity(id: activity.documentID, title: data["title"] as! String, desc: data["description"] as! String, headerImage: data["headerImage"] as! String, date: data["date"] as! Timestamp, company: data["company"] as! String, place: data["place"] as! String, contact: data["contact"] as! String, images: data["images"] as! [String], readed: readed, favorited: favorited))
                        
                    }
                    
                    switch self.currentActivityType {
                    case .all:
                        self.touchAll(self)
                    case .current:
                        self.touchCurrent(self)
                    case .past:
                        self.touchPast(self)
                    case .favorite:
                        self.touchFavorite(self)
                    }
                }
                
                
            }
            
        }
    }
    
    //ถ้ากำลังจะเปลี่ยนหน้าให้เอาข้อมูลมาด้วย
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "detail" {
            let detailVC = segue.destination as! ActivityDetailViewController
            detailVC.selectedActivity = selectedActivity
        }
    }
    
    @IBAction func touchAll(_ sender: Any) {
        loadingView.isHidden = false
        
        if searchBar.text != "" {
            filteredActivities = activities.filter({ activity in
                return activity.title.localizedStandardContains(self.searchBar.text!)
            })
        } else {
            filteredActivities = activities
        }
        
        activityTableView.reloadData()
        
        loadingView.isHidden = true
        blankView.isHidden = filteredActivities.count != 0
        
        underlineAllView.isHidden = false
        underlineCurrentView.isHidden = true
        underlinePastView.isHidden = true
        underlineFavoriteView.isHidden = true
        
        allUIBtn.setTitleColor(.link, for: .normal)
        currentUIBtn.setTitleColor(.darkGray, for: .normal)
        pastUIBtn.setTitleColor(.darkGray, for: .normal)
        favoriteUIBtn.setTitleColor(.darkGray, for: .normal)
        
        currentActivityType = .all
        
    }
    
    @IBAction func touchCurrent(_ sender: Any) {
        loadingView.isHidden = false
        
        filteredActivities = activities.filter { activity in
            return activity.date.dateValue() >= Date()
        }
        activityTableView.reloadData()
        
        loadingView.isHidden = true
        blankView.isHidden = filteredActivities.count != 0
        
        underlineAllView.isHidden = true
        underlineCurrentView.isHidden = false
        underlinePastView.isHidden = true
        underlineFavoriteView.isHidden = true
        
        allUIBtn.setTitleColor(.darkGray, for: .normal)
        currentUIBtn.setTitleColor(.link, for: .normal)
        pastUIBtn.setTitleColor(.darkGray, for: .normal)
        favoriteUIBtn.setTitleColor(.darkGray, for: .normal)
        
        currentActivityType = .current
    }
    
    @IBAction func touchPast(_ sender: Any) {
        loadingView.isHidden = false
        
        filteredActivities = activities.filter { activity in
            return activity.date.dateValue() < Date()
        }
        activityTableView.reloadData()
        
        loadingView.isHidden = true
        blankView.isHidden = filteredActivities.count != 0
        
        underlineAllView.isHidden = true
        underlineCurrentView.isHidden = true
        underlinePastView.isHidden = false
        underlineFavoriteView.isHidden = true
        
        allUIBtn.setTitleColor(.darkGray, for: .normal)
        currentUIBtn.setTitleColor(.darkGray, for: .normal)
        pastUIBtn.setTitleColor(.link, for: .normal)
        favoriteUIBtn.setTitleColor(.darkGray, for: .normal)
        
        currentActivityType = .past
    }
    
    @IBAction func touchFavorite(_ sender: Any) {
        loadingView.isHidden = false
        
        filteredActivities = activities.filter { activity in
            return activity.favorited
        }
        activityTableView.reloadData()
        
        loadingView.isHidden = true
        blankView.isHidden = filteredActivities.count != 0
        
        underlineAllView.isHidden = true
        underlineCurrentView.isHidden = true
        underlinePastView.isHidden = true
        underlineFavoriteView.isHidden = false
        
        allUIBtn.setTitleColor(.darkGray, for: .normal)
        currentUIBtn.setTitleColor(.darkGray, for: .normal)
        pastUIBtn.setTitleColor(.darkGray, for: .normal)
        favoriteUIBtn.setTitleColor(.link, for: .normal)
        
        currentActivityType = .favorite
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return filteredActivities.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = activityTableView.dequeueReusableCell(withIdentifier: "ActivityTableViewCell") as! ActivityTableViewCell
        cell.titleLabel.text = filteredActivities[indexPath.row].title //indexPath.row เป็นการเรียกตำแหน่งแถวปัจจุบัน
        cell.descTextView.text = filteredActivities[indexPath.row].desc
        cell.dateLabel.text = dateFormatter.string(from: filteredActivities[indexPath.row].date.dateValue())
        cell.headerImageView.af_setImage(withURL: URL(string: filteredActivities[indexPath.row].headerImage)!)
        cell.readView.isHidden = filteredActivities[indexPath.row].readed
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 121
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        selectedActivity = filteredActivities[indexPath.row]
        performSegue(withIdentifier: "detail", sender: self)//ช่วยเคลื่อนไปตามเส้รนที่ชื่อ detail (เปลี่ยนหน้า)
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        print(searchText)
        touchAll(self)
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
        searchBar.text = ""
    }
    
}
