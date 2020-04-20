//  Crypter
//
//  Created by Павло Тимощук on 30.09.2019.
//  Copyright © 2019 Павло Тимощук. All rights reserved.
//

import UIKit
import Foundation
import AVFoundation
import AudioToolbox


class KeyChange: UIViewController, UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    func check(newKey: UITextField) -> Bool {
        var ans = false
        var k = 0
        for character in newKey.text! {
            if character >= "\u{0030}" && character <= "\u{0039}" {
                k+=1
            }
        }
        if newKey.text! != "" && k == newKey.text!.count {
            if Int(newKey.text!)! > 0 && Int(newKey.text!)! < 33 {
                ans = true
            }
        }
        return ans
    }
    
    override func viewDidLoad() {
        newKey.delegate = self
        currentKey.text = String(myKey)
        
        let key = UserDefaults.standard
        key.set(myKey, forKey: "Key")
        key.synchronize()
        if key.value(forKey: "Key") != nil {
            myKey = key.value(forKey: "Key") as! NSInteger
        }
       
    }
    
    @IBOutlet weak var currentKey: UILabel!
    
    @IBOutlet weak var newKey: UITextField!

    @IBAction func cancelButton(_ sender: UIButton) {
        //MARK: - Відміна відкриття view
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func saveButton(_ sender: UIButton) {
        if check(newKey: newKey) {
            myKey = Int(newKey.text!)!
            //MARK: - Відміна відкриття view
            dismiss(animated: true, completion: nil)
        }
        else {
            AudioServicesPlaySystemSound(SystemSoundID(4095))
            let alert = UIAlertController(title: "Помилка", message: "Введіть число від 1 до 32", preferredStyle: .alert)
            let action = UIAlertAction(title: "OK", style: .cancel) {
                (action) in
            }
            alert.addAction(action)
            self.present(alert, animated: true, completion: nil)
        }
    }
}
