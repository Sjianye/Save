//
//  LeaderboardVC.swift
//  SaveTheDot
//
//  Created by 改车吧 on 2017/12/11.
//  Copyright © 2017年 Jake Lin. All rights reserved.
//

import UIKit
import LeanCloud
import SVProgressHUD

class LeaderboardVC: UIViewController,UITableViewDelegate,UITableViewDataSource{
    

    @IBOutlet weak var myTableView: UITableView!
    
    fileprivate var dataArray : [String] = [String]() //
    fileprivate var gradeArray : [Double] = [Double]() //


    override func viewDidLoad() {
        super.viewDidLoad()

        
        SVProgressHUD.show()
        
        self.myTableView.delegate = self
        self.myTableView.dataSource = self
        self.myTableView.rowHeight = 60.0
        self.myTableView.register(UINib.init(nibName: "LeadboardTableViewCell", bundle: nil), forCellReuseIdentifier: "cellid")
        
        let query = LCQuery.init(className: "number")

        query.whereKey("grade1", .descending)
        query.whereKey("grade1", .selected)
        query.whereKey("name1",  .selected)
        
        query.limit = 20
        
        query.find { result in
            switch result {
            case .success(let todos):
                
                for a in todos {
                    self.dataArray.append((a.get("name1")?.stringValue)!)
                    self.gradeArray.append((a.get("grade1")?.doubleValue)!)
                }
                SVProgressHUD.dismiss()
                self.myTableView.reloadData()
            break
            case .failure(let error):
                print("---++++++++++++>>>>>>>>>>>>>>>>>>>>>+>++>++",error)
                SVProgressHUD.showError(withStatus: NSLocalizedString("netWorkError", comment: "default"))
            }
        }
        

        

    }
    

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        let cell = tableView.dequeueReusableCell(withIdentifier: "cellid", for: indexPath) as! LeadboardTableViewCell
        
        cell.nameLable.text = dataArray[indexPath.row]
        
        let interval = Int(gradeArray[indexPath.row])
        let seconds = interval % 60
        let minutes = (interval / 60) % 60
        let milliseconds = Int(gradeArray[indexPath.row] * 1000) % 1000
        cell.timeNumber.text = String.init(format:"%02d:%02d.%03d", minutes, seconds, milliseconds)
        
        cell.iconImageView.isHidden = true
        switch indexPath.row {
        case 0:
            cell.iconImageView.isHidden = false
            cell.iconImageView.image = UIImage(named:"F")
            break
        case 1:
            cell.iconImageView.isHidden = false
            cell.iconImageView.image = UIImage(named:"S")
            break
        case 2:
            cell.iconImageView.isHidden = false
            cell.iconImageView.image = UIImage(named:"T")
            break
        default:
            break
        }
        
        return cell
    }
    

    @IBAction func OKButtonClick(_ sender: UIButton) {
        
        self.dismiss(animated: true, completion: nil)
        
    }
    
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        return
    }
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
