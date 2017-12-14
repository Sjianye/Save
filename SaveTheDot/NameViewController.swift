//
//  NameViewController.swift
//  SaveTheDot
//
//  Created by 改车吧 on 2017/12/9.
//  Copyright © 2017年 Jake Lin. All rights reserved.
//

import UIKit

class NameViewController: UIViewController , UITextFieldDelegate{
    @IBOutlet weak var nameLabel: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        nameLabel.delegate = self
    
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func GoButtonClick(_ sender: UIButton) {
        
        let length : NSInteger = (self.nameLabel.text?.lengthOfBytes(using: String.Encoding.utf8))!

        if length < 2 {return}

        self.saveWithNSUserDefaults(name: (self.nameLabel.text)!)
        
        let story : UIStoryboard = UIStoryboard.init(name: "Main", bundle: nil)
        let root = story.instantiateViewController(withIdentifier: "root")
        
        UIApplication.shared.keyWindow?.rootViewController = root
    }
    
    func saveWithNSUserDefaults(name :String) {
        // 1、利用NSUserDefaults存储数据
        let defaults = UserDefaults.standard;
        // 2、存储数据
        defaults.set(name, forKey: "nickname");
        // 3、同步数据
        defaults.synchronize();
    }

    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        guard let text = textField.text else{
            return true
        }
        
        let textLength = text.characters.count + string.characters.count - range.length
        
        return textLength<=8
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        nameLabel.resignFirstResponder()
    }
}




