//  Crypter
//
//  Created by Павло Тимощук on 03.09.2019.
//  Copyright © 2019 Павло Тимощук. All rights reserved.
//

import UIKit
import UserNotifications
import Foundation
import AVFoundation
import AudioToolbox
import LocalAuthentication
import PassKit

class Decrypt: UIViewController, UITextFieldDelegate
{
    @IBOutlet weak var dataToDecrypt: UITextField!
    @IBOutlet weak var decryptText: UILabel!
    @IBOutlet weak var baseText: UILabel!
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool
    {
        textField.resignFirstResponder()
        return true
    }
    
    func getting_ABC() -> [String]
    {
       
        let fileName = "Mixed_letters"
        let docDirURL = try! FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
        let fileURL = docDirURL.appendingPathComponent(fileName).appendingPathExtension("txt")
        var readMixedABC = ""
        do
        {
            readMixedABC = try String(contentsOf: fileURL)
        }
        catch
        {
            print("ERROR")
        }
        var newAlphabet: [String] = []
        for i in 0 ..< Letters.count
        {
            newAlphabet.append(readMixedABC[i])
        }
        return newAlphabet
    }
    
    func getting_Table_KEY() -> [[String]]
    {
        let fileName = "Table_KEY"
        let docDirURL = try! FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
        let fileURL = docDirURL.appendingPathComponent(fileName).appendingPathExtension("txt")
        var readTable_KEY = ""
        var Table_KEY = [[String]]()
        do
        {
            readTable_KEY = try String(contentsOf: fileURL)
        }
        catch
        {
            print("ERROR")
        }
        
        var i = 0
        for _ in 0 ..< 5
        {
            var sub_array = [String]()
            for _ in 0 ..< 7
            {
                sub_array.append(readTable_KEY[i])
                i+=1
            }
            Table_KEY.append(sub_array)
            i+=1
        }
        return Table_KEY
    }
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        dataToDecrypt.delegate = self
        
        let encryptIcon = UIApplicationShortcutIcon(templateImageName: "unlock")
        let encryptItem = UIApplicationShortcutItem(type: "encrypt", localizedTitle: "Encrypt", localizedSubtitle: "", icon: encryptIcon, userInfo: nil)
        
        UIApplication.shared.shortcutItems = [encryptItem]
        
        let decryptIcon = UIApplicationShortcutIcon(templateImageName: "lock")
        let decryptItem = UIApplicationShortcutItem(type: "decrypt", localizedTitle: "Decrypt", localizedSubtitle: "", icon: decryptIcon, userInfo: nil)
        
        UIApplication.shared.shortcutItems = [decryptItem]
        
    }
        
    @IBAction func keyChanger(_ sender: UIButton)
    {
        //        let context = LAContext()
        //        var error: NSError?
        //
        //        if context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error) {
        //            let reason = "Прикладіть палець до кнопки"
        //
        //            context.evaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, localizedReason: reason) {
        //                [unowned self] success, authenticationError in
        //                DispatchQueue.main.async {
        //                    if success {
        //                        let alert = UIAlertController(title: "Ви авторизувались", message: "", preferredStyle: .alert)
        //                        let action = UIAlertAction(title: "Ввійти", style: .cancel)
        //                        {
        //                            (action) in
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "MetodChange")
        self.present(vc, animated: true, completion: nil)
        //                        }
        //                        alert.addAction(action)
        //                        self.present(alert, animated: true, completion: nil)
        //                    }
        //                }
        //            }
        //        }
    }
    
    // MARK:    Шифрування Цезаря
    
    fileprivate func Caesars_decode(_ readString: inout String, _ newText: inout String) {
        var symbol: UInt16
        var newSymbol: String
        for character in readString.utf16
        {
            symbol = character - UInt16(myKey)
            if String(UnicodeScalar(symbol)!) < "\u{0410}" && String(UnicodeScalar(character)!) >= "\u{0410}"
            {
                let vrongSymb = symbol
                symbol = UInt16(UnicodeScalar("Я").value) - UInt16( UnicodeScalar("А").value - UnicodeScalar(vrongSymb)!.value) + 1
            }
            if String(UnicodeScalar(symbol)!) < "\u{0430}" && String(UnicodeScalar(character)!) >= "\u{0430}"
            {
                let vrongSymb = symbol
                symbol = UInt16(UnicodeScalar("я").value) - UInt16( UnicodeScalar("а").value - UnicodeScalar(vrongSymb)!.value) + 1
            }
            newSymbol = String(UnicodeScalar(symbol)!)
            newText += newSymbol
        }
    }
    
    // MARK:    Гомофонний шифр
    
    func Homophonic_decode(_ text: inout String, _ newText: inout String)
    {
        if text.count%3 != 0
        {
            newText = "Це що-небуть, тільки не зашифрований текст ❌"
        }
        else
        {
            var num = 0
            for char in text
            {
                if char >= "0" && char <= "9"
                {
                    num+=1
                }
            }
            if num == text.count
            {
                var array = [String]()
                var ind = 0
                
                repeat
                {
                    var newSTR = ""
                    for _ in 0...2
                    {
                        newSTR+=String(text[ind])
                        ind+=1
                    }
                    array.append(newSTR)
                }
                while ind < text.count
                
                num=0
                for k in array
                {
                    for i in homophonic_el
                    {
                        for j in i.code
                        {
                            if k == j
                            {
                                newText += String(i.letter)
                                num+=1
                            }
                        }
                    }
                }
                if num != array.count
                {
                    newText = "Це що-небуть, тільки не зашифрований текст ❌"
                }
            }
            else
            {
                newText = "Це що-небуть, тільки не зашифрований текст ❌"
            }
        }
    }
    
    // MARK:    Шифр модульного гамування
    
    func Module_gamming_decode (_ text: inout String, _ newText: inout String)
    {
        var keyPhrase = ""
        var i = 0
        for _ in 0 ..< text.count
        {
            keyPhrase += myKeyWord[i]
            if i == myKeyWord.count-1
            {
                i = 0
            }
            else
            {
                i += 1
            }
        }
        let newAlphabet = getting_ABC()
        for i in 0 ..< newAlphabet.count
        {
            print("\(Letters[i]) = \(Int(newAlphabet.firstIndex(of: Letters[i])!))")
        }
        for k in 0 ..< text.count
        {
            let delta = Int(newAlphabet.firstIndex(of: text[k])!)-Int(newAlphabet.firstIndex(of: keyPhrase[k])!)+newAlphabet.count
            newText += newAlphabet[delta%newAlphabet.count]
        }
    }
    
    // MARK:    Шифр  Плейфера
    
    func Playfair_decode (_ text: inout String, _ newText: inout String)
    {
        let Table_KEY = getting_Table_KEY()
        var i = 0
        repeat
        {
            let a = text[i], b = text[i+1]
            var pos_a = [0,0], pos_b = [0,0]
            for j in 0 ..< Table_KEY.count
            {
                for k in 0 ..< Table_KEY[j].count
                {
                    if a == Table_KEY[j][k]
                    {
                        pos_a[0] = j
                        pos_a[1] = k
                    }
                    if b == Table_KEY[j][k]
                    {
                        pos_b[0] = j
                        pos_b[1] = k
                    }
                }
            }
            if pos_a[0] == pos_b[0] && pos_a[1] == pos_b[1] // Однакові літери
            {
                newText += Table_KEY[pos_a[0]][(pos_a[1]+Table_KEY[0].count-1)%Table_KEY[0].count]
                newText += Table_KEY[pos_b[0]][(pos_b[1]+Table_KEY[0].count-1)%Table_KEY[0].count]
            }
            if pos_a[0] == pos_b[0] && pos_a[1] != pos_b[1] // Літери в одному рядку
            {
                newText += Table_KEY[pos_a[0]][(pos_a[1]+Table_KEY[0].count-1)%Table_KEY[0].count]
                newText += Table_KEY[pos_b[0]][(pos_b[1]+Table_KEY[0].count-1)%Table_KEY[0].count]
            }
            if pos_a[0] != pos_b[0] && pos_a[1] == pos_b[1] // Літери в одному стовпці
            {
                newText += Table_KEY[(pos_a[0]+Table_KEY.count-1)%Table_KEY.count][pos_a[1]]
                newText += Table_KEY[(pos_b[0]+Table_KEY.count-1)%Table_KEY.count][pos_b[1]]
            }
            if pos_a[0] != pos_b[0] && pos_a[1] != pos_b[1] // Літери утворюють прямокутник
            {
                newText += Table_KEY[pos_a[0]][pos_b[1]]
                newText += Table_KEY[pos_b[0]][pos_a[1]]
            }
            
            if text.count%2 == 0 // Якщо текст має парну к-сть символів
            {
                i+=2
            }
            else
            {
                i+=2
                if i == text.count-1 // Відловлення залишкової останньої літери
                {
                    for j in 0 ..< Table_KEY.count
                    {
                        for k in 0 ..< Table_KEY[j].count
                        {
                            if text[text.count-1] == Table_KEY[j][k]
                            {
                                pos_a[0] = j
                                pos_a[1] = k
                                newText += Table_KEY[pos_a[0]][(pos_a[1]+Table_KEY[0].count-1)%Table_KEY[0].count]
                            }
                        }
                    }
                    i+=1
                }
            }
        }
        while i < text.count
    }
    
    // MARK: Розшифрування з файлу
    
    @IBAction func decrypt_file(_ sender: UIButton)
    {
        let fileName = "FileEnctypt"
        let fileNameFileDecrypt = "FileDecrypt"
        let docDirURL = try! FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
        let fileURL = docDirURL.appendingPathComponent(fileName).appendingPathExtension("txt")
        let fileURLFileDecrypt = docDirURL.appendingPathComponent(fileNameFileDecrypt).appendingPathExtension("txt")
        print(fileURL)
        var readString = ""
        do
        {
            readString = try String(contentsOf: fileURL)
            print("Текст,який потрібно розшифрувати: \(readString)")
            baseText.text = "Текст, який потрібно розшифрувати: \(readString)"
        }
        catch _ as NSError
        {
            print("ERROR")
        }
        
        var newText = ""
                
        if currentMetod==0
        {
            Caesars_decode(&readString, &newText)
        }
        if currentMetod==1
        {
            Homophonic_decode(&readString, &newText)
        }
        if currentMetod==2
        {
            Module_gamming_decode(&readString, &newText)
        }
        if currentMetod==3
        {
            Playfair_decode(&readString, &newText)
        }
        
        print("Розшифрований текст: \(decryptText.text!)")
        decryptText.text = "Розшифрований текст: \(newText)"
        do
        {
            try newText.write(to: fileURLFileDecrypt, atomically: false, encoding: .utf8)
        }
        catch _ as NSError
        {
            print("ERROR")
        }
    }
    
    // MARK: Розшифрування звичайне
    
    @IBAction func decrypt(_ sender: UIButton)
    {
        var text = dataToDecrypt.text!
        baseText.text =  "Текст, який потрібно розшифрувати: \(text)"
        var newText = ""
                
        if currentMetod==0
        {
            Caesars_decode(&text, &newText)
        }
        if currentMetod==1
        {
            Homophonic_decode(&text, &newText)
        }
        if currentMetod==2
        {
            Module_gamming_decode(&text, &newText)
        }
        if currentMetod==3
        {
            Playfair_decode(&text, &newText)
        }
        
        decryptText.text = "Розшифрований текст: \(newText)"
    }
    
    @IBAction func copy_decrypt(_ sender: UIButton)
    {
        //Копіювання даних
        UIPasteboard.general.string = decryptText.text
        print(currentMetod)
    }
    
    @IBAction func share2Button(_ sender: UIButton)
    {
        let activityController = UIActivityViewController(activityItems: [decryptText.text!],applicationActivities: nil)
        present(activityController, animated: true, completion: nil)
    }
    
}
