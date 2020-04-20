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

class Decrypt: UIViewController, UITextFieldDelegate {
    @IBOutlet weak var dataToDecrypt: UITextField!
    @IBOutlet weak var decryptText: UILabel!
    @IBOutlet weak var baseText: UILabel!
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    func getting_ABC() -> [String] {
        let readMixedABC = "АІҐ5СнМДґе7аиЇщИмюЖуЙсЬРйяіЛпГ3їшЩП4ж ЧтЗБВлЦФбо2ьТзКв9єНЄцрОШф0дкХУ6ч18гЕх-№"
        var newAlphabet: [String] = []
        for i in 0 ..< Letters.count {
            newAlphabet.append(readMixedABC[i])
        }
        return newAlphabet
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        dataToDecrypt.delegate = self
        let encryptIcon = UIApplicationShortcutIcon(templateImageName: "unlock")
        let encryptItem = UIApplicationShortcutItem(type: "encrypt", localizedTitle: "Encrypt", localizedSubtitle: "", icon: encryptIcon, userInfo: nil)
        UIApplication.shared.shortcutItems = [encryptItem]
        let decryptIcon = UIApplicationShortcutIcon(templateImageName: "lock")
        let decryptItem = UIApplicationShortcutItem(type: "decrypt", localizedTitle: "Decrypt", localizedSubtitle: "", icon: decryptIcon, userInfo: nil)
        UIApplication.shared.shortcutItems = [decryptItem]
    }
       
    // MARK:    Кнопка переключення методів
    
    @IBAction func keyChanger(_ sender: UIButton) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "MetodChange")
        self.present(vc, animated: true, completion: nil)
    }
    
    // MARK:    Шифрування Цезаря
    
    fileprivate func Caesars_decode(_ readString: inout String, _ newText: inout String) {
        var symbol: UInt16
        var newSymbol: String
        for character in readString.utf16 {
            symbol = character - UInt16(myKey)
            if String(UnicodeScalar(symbol)!) < "\u{0410}" && String(UnicodeScalar(character)!) >= "\u{0410}" {
                let vrongSymb = symbol
                symbol = UInt16(UnicodeScalar("Я").value) - UInt16( UnicodeScalar("А").value - UnicodeScalar(vrongSymb)!.value) + 1
            }
            if String(UnicodeScalar(symbol)!) < "\u{0430}" && String(UnicodeScalar(character)!) >= "\u{0430}" {
                let vrongSymb = symbol
                symbol = UInt16(UnicodeScalar("я").value) - UInt16( UnicodeScalar("а").value - UnicodeScalar(vrongSymb)!.value) + 1
            }
            newSymbol = String(UnicodeScalar(symbol)!)
            newText += newSymbol
        }
    }
    
    // MARK:    Гомофонний шифр
    
    func Homophonic_decode(_ text: inout String, _ newText: inout String) {
        //        MARK: Отримання шифру
        Get_shuft()
        if text.count%3 != 0 {
            newText = "Це що-небуть, тільки не зашифрований текст ❌"
        }
        else {
            var num = 0
            for char in text {
                if char >= "0" && char <= "9" {
                    num+=1
                }
            }
            if num == text.count {
                var array = [String]()
                var ind = 0
                repeat {
                    var newSTR = ""
                    for _ in 0...2 {
                        newSTR+=String(text[ind])
                        ind+=1
                    }
                    array.append(newSTR)
                } while ind < text.count
                
                num=0
                for k in array {
                    for i in homophonic_el {
                        for j in i.code {
                            if k == j {
                                newText += String(i.letter)
                                num+=1
                            }
                        }
                    }
                }
                if num != array.count {
                    newText = "Це що-небуть, тільки не зашифрований текст ❌"
                }
            } else {
                newText = "Це що-небуть, тільки не зашифрований текст ❌"
            }
        }
    }
    
    // MARK:    Шифр модульного гамування
    
    func Module_gamming_decode (_ text: inout String, _ newText: inout String) {
        var keyPhrase = ""
        var i = 0
        for _ in 0 ..< text.count {
            keyPhrase += myKeyWord[i]
            if i == myKeyWord.count-1 {
                i = 0
            } else {
                i += 1
            }
        }
        let newAlphabet = getting_ABC()
        for i in 0 ..< newAlphabet.count {
            print("\(Letters[i]) = \(Int(newAlphabet.firstIndex(of: Letters[i])!))")
        }
        for k in 0 ..< text.count {
            let delta = Int(newAlphabet.firstIndex(of: text[k])!)-Int(newAlphabet.firstIndex(of: keyPhrase[k])!)+newAlphabet.count
            newText += newAlphabet[delta%newAlphabet.count]
        }
    }
    
    // MARK:    Шифр  Плейфера
    
    func Playfair_decode (_ text: inout String, _ newText: inout String) {
        let Table_KEY = getting_Table_KEY()
        if text.count%2 != 0 { // Якщо текст має непарну к-сть символів
            text+=text[text.count-1]
        }
        var i = 0
        repeat {
            let a = text[i], b = text[i+1]
            var pos_a = [0,0], pos_b = [0,0]
            get_position(Table_KEY, a, &pos_a, b, &pos_b)
            double_replace(&pos_a, &pos_b, &newText, Table_KEY,-1)
            i+=2
        } while i < text.count
    }
    
    // MARK: Розшифрування з файлу
    
    @IBAction func decrypt_file(_ sender: UIButton) {
        let fileName = "FileEnctypt"
        let fileNameFileDecrypt = "FileDecrypt"
        let docDirURL = try! FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
        let fileURL = docDirURL.appendingPathComponent(fileName).appendingPathExtension("txt")
        let fileURLFileDecrypt = docDirURL.appendingPathComponent(fileNameFileDecrypt).appendingPathExtension("txt")
        print(fileURL)
        var readString = ""
        do {
            readString = try String(contentsOf: fileURL)
            print("Текст,який потрібно розшифрувати: \(readString)")
            baseText.text = "Текст, який потрібно розшифрувати: \(readString)"
        } catch _ as NSError {
            print("ERROR")
        }
        var newText = ""
        if currentMetod == 0 {
            Caesars_decode(&readString, &newText)
        }
        if currentMetod == 1 {
            Homophonic_decode(&readString, &newText)
        }
        if currentMetod == 2 {
            Module_gamming_decode(&readString, &newText)
        }
        if currentMetod == 3 {
            Playfair_decode(&readString, &newText)
        }
        print("Розшифрований текст: \(decryptText.text!)")
        decryptText.text = "Розшифрований текст: \(newText)"
        do {
            try newText.write(to: fileURLFileDecrypt, atomically: false, encoding: .utf8)
        } catch _ as NSError {
            print("ERROR")
        }
    }
    
    // MARK: Розшифрування звичайне
    
    @IBAction func decrypt(_ sender: UIButton) {
        var text = dataToDecrypt.text!
        baseText.text =  "Текст, який потрібно розшифрувати: \(text)"
        var newText = ""
                
        if currentMetod == 0 {
            Caesars_decode(&text, &newText)
        }
        if currentMetod == 1 {
            Homophonic_decode(&text, &newText)
        }
        if currentMetod == 2 {
            Module_gamming_decode(&text, &newText)
        }
        if currentMetod == 3 {
            Playfair_decode(&text, &newText)
        }
        
        decryptText.text = "Розшифрований текст: \(newText)"
    }
    
    @IBAction func copy_decrypt(_ sender: UIButton) {
        //Копіювання даних
        UIPasteboard.general.string = decryptText.text
        print(currentMetod)
    }
    
    @IBAction func share2Button(_ sender: UIButton) {
        let activityController = UIActivityViewController(activityItems: [decryptText.text!],applicationActivities: nil)
        present(activityController, animated: true, completion: nil)
    }
    
}
