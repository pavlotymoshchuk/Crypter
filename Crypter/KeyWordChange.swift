//  Crypter
//
//  Created by Павло Тимощук on 24.10.2019.
//  Copyright © 2019 Павло Тимощук. All rights reserved.
//


import UIKit
import Foundation
import AVFoundation
import AudioToolbox


class KeyWordChange: UIViewController, UITextFieldDelegate
{
    
    func check (newKeyWord: UITextField) -> Bool
    {
        let text = newKeyWord.text!
        var ans = true
        if text.isEmpty
        {
            ans = false
        }
        else
        {
        var num = 0
            for char in text
            {
                for letter in Letters
                {
                    if letter == String(char)
                    {
                        num += 1
                    }
                }
            }
            if num != text.count
            {
                ans = false
            }
        }
        return ans
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool
    {
        textField.resignFirstResponder()
        return true
    }
    
    override func viewDidLoad()
    {
        currentKeyWord.text = myKeyWord
        newKeyWord.delegate = self
    }
    
    @IBOutlet weak var currentKeyWord: UILabel!
    
    @IBOutlet weak var newKeyWord: UITextField!
    
    @IBAction func cancelButton(_ sender: UIButton)
    {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "TabBar") 
        self.present(vc, animated: true, completion: nil)
    }
    
    @IBAction func SaveButton(_ sender: UIButton)
    {
        if check(newKeyWord: newKeyWord)
        {
            myKeyWord = newKeyWord.text!
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let vc = storyboard.instantiateViewController(withIdentifier: "TabBar") 
            self.present(vc, animated: true, completion: nil)
        }
        else
        {
            AudioServicesPlaySystemSound(SystemSoundID(4095))
            let alert = UIAlertController(title: "Помилка", message: "Введіть коректне ключове слово", preferredStyle: .alert)
            let action = UIAlertAction(title: "OK", style: .cancel)
            {
                (action) in
            }
            alert.addAction(action)
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    
}

