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
		
extension String {
    var length: Int { return count }
    subscript (i: Int) -> String { return self[i ..< i + 1] }
    func substring(fromIndex: Int) -> String { return self[min(fromIndex, length) ..< length] }
    func substring(toIndex: Int) -> String { return self[0 ..< max(0, toIndex)] }
    subscript (r: Range<Int>) -> String {
        let range = Range(uncheckedBounds: (lower: max(0, min(length, r.lowerBound)),
                                            upper: min(length, max(0, r.upperBound))))
        let start = index(startIndex, offsetBy: range.lowerBound)
        let end = index(start, offsetBy: range.upperBound - range.lowerBound)
        return String(self[start ..< end])
    }
}

class Encrypt: UIViewController, UITextFieldDelegate {
    @IBOutlet weak var dataToEncrypt: UITextField!
    @IBOutlet weak var encryptText: UILabel!
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
        dataToEncrypt.delegate = self
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
    
    func Caesars_code(_ text: inout String, _ newText: inout String) {
        var symbol: UInt16
        var newSymbol: String
        for character in text.utf16 {
            symbol = character + UInt16(myKey)
            if String(UnicodeScalar(symbol)!) > "\u{042f}" && String(UnicodeScalar(character)!) <= "\u{042f}" {
                let vrongSymb = symbol
                symbol = UInt16(UnicodeScalar("А").value + UnicodeScalar(vrongSymb)!.value - UnicodeScalar("Я").value - 1)
            }
            if String(UnicodeScalar(symbol)!) > "\u{044f}" && String(UnicodeScalar(character)!) <= "\u{044f}" {
                let vrongSymb = symbol
                symbol = UInt16(UnicodeScalar("а").value + UnicodeScalar(vrongSymb)!.value - UnicodeScalar("я").value - 1)
            }
            newSymbol = String(UnicodeScalar(symbol)!)
            newText += newSymbol
        }
    }
    
    // MARK: Гомофонний шифр
    
    func Homophonic_code(_ text: inout String, _ newText: inout String) {
        // MARK: Отримання шифру
        Get_shuft()
        for char in text {
            for j in 0 ..< homophonic_el.count {
                if char == homophonic_el[j].letter {
                    newText+=homophonic_el[j].code.randomElement()!
                    homophonic_el[j].freq_let+=1
                }
            }
        }
        for i in 0 ..< homophonic_el.count {
            print("Літера '\(homophonic_el[i].letter)' використана \(homophonic_el[i].freq_let) разів з частотою \(Float(homophonic_el[i].freq_let)/Float(text.count)*100)%")
        }
        for j in 0 ..< homophonic_el.count {
            homophonic_el[j].freq_let=0
        }
    }
    
    // MARK: Шифр модульного гамування
    
    func Module_gamming_code (_ text: inout String, _ newText: inout String) {
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
            let pos = (Int(newAlphabet.firstIndex(of: text[k])!)+Int(newAlphabet.firstIndex(of: keyPhrase[k])!))%newAlphabet.count
            newText += newAlphabet[pos]
        }
    }
    
    // MARK:    Шифр Плейфера
    
    func Playfair_code (_ text: inout String, _ newText: inout String) {
        let Table_KEY = getting_Table_KEY()
        for i in 0..<Table_KEY.count {
            print(Table_KEY[i])
        }
        if text.count%2 != 0 { // Якщо текст має непарну к-сть символів
            text+=text[text.count-1]
        }
        var i = 0
        repeat {
            let a = text[i], b = text[i+1]
            var pos_a = [0,0], pos_b = [0,0]
            get_position(Table_KEY, a, &pos_a, b, &pos_b)
            double_replace(&pos_a, &pos_b, &newText, Table_KEY,1)
            i+=2
        }
        while i < text.count
    }
    
    // MARK: Шифрування з файлу
    
    @IBAction func encrypt_file(_ sender: UIButton) {
        let fileName = "File"
        let fileNameFileEnctypt = "FileEnctypt"
        let docDirURL = try! FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
        let fileURL = docDirURL.appendingPathComponent(fileName).appendingPathExtension("txt")
        let fileURLFileEnctypt = docDirURL.appendingPathComponent(fileNameFileEnctypt).appendingPathExtension("txt")
        var readString = ""
        print(fileURL)
        do {
            readString = try String(contentsOf: fileURL)
            print("Текст, який потрібно зашифрувати: \(readString)")
            baseText.text = "Текст, який потрібно зашифрувати: \(readString)"
        } catch {
            print("ERROR")
        }
        var newText = ""
                
        if currentMetod == 0 {
            Caesars_code(&readString, &newText)
        }
        if currentMetod == 1 {
            for i in 0 ..< homophonic_el.count {
                var code_values = ""
                print("Кодові значення для символа '\(homophonic_el[i].letter)': ")
                for j in 0 ..< homophonic_el[i].code.count {
                    code_values.append("\(homophonic_el[i].code[j]) ")
                }
                print(code_values)
            }
            Homophonic_code(&readString, &newText)
            for i in 0 ..< homophonic_el.count {
                print("Літера '\(homophonic_el[i].letter)' використана \(homophonic_el[i].freq_let) разів з частотою \(Float(homophonic_el[i].freq_let)/Float(readString.count)*100)%")
            }
            for j in 0 ..< homophonic_el.count {
                homophonic_el[j].freq_let=0
            }
        }
        if currentMetod == 2 {
            Module_gamming_code(&readString, &newText)
        }
        if currentMetod == 3 {
            Playfair_code(&readString, &newText)
        }
        print("Зашифрований текст: \(newText)")
        encryptText.text = "Зашифрований текст: \n\(newText)"
        do {
            try newText.write(to: fileURLFileEnctypt, atomically: false, encoding: .utf8)
        } catch _ as NSError {
            print("ERROR")
        }
    }
    
    // MARK: Шифрування звичайне
    
    @IBAction func encrypt(_ sender: UIButton) {
        var text = dataToEncrypt.text!
        baseText.text =  "Текст, який потрібно зашифрувати: \(text)"
        var newText = ""
                
        if currentMetod==0 {
            Caesars_code(&text, &newText)
        }
        if currentMetod==1 {
            Homophonic_code(&text, &newText)
        }
        if currentMetod==2 {
            Module_gamming_code(&text, &newText)
        }
        if currentMetod==3 {
            Playfair_code(&text, &newText)
        }
        encryptText.text = "Зашифрований текст: \(newText)"
    }
    
    @IBAction func copy_encrypt(_ sender: UIButton) {
        //Копіювання даних
        var copy_text = encryptText.text!
        let range = copy_text.startIndex ..< copy_text.index(copy_text.startIndex, offsetBy: 20)
        copy_text.removeSubrange(range)
        UIPasteboard.general.string = copy_text
        print(currentMetod)
    }
    
    @IBAction func shareButton(_ sender: UIButton) {
        let activityController = UIActivityViewController(activityItems: [encryptText.text!], applicationActivities: nil)
        present(activityController, animated: true, completion: nil)
    }
}
