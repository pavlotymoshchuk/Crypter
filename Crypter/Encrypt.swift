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
    
    var length: Int {
        return count
    }
    
    subscript (i: Int) -> String {
        return self[i ..< i + 1]
    }
    
    func substring(fromIndex: Int) -> String {
        return self[min(fromIndex, length) ..< length]
    }
    
    func substring(toIndex: Int) -> String {
        return self[0 ..< max(0, toIndex)]
    }
    
    subscript (r: Range<Int>) -> String {
        let range = Range(uncheckedBounds: (lower: max(0, min(length, r.lowerBound)),
                                            upper: min(length, max(0, r.upperBound))))
        let start = index(startIndex, offsetBy: range.lowerBound)
        let end = index(start, offsetBy: range.upperBound - range.lowerBound)
        return String(self[start ..< end])
    }
    
}

class Encrypt: UIViewController, UITextFieldDelegate
{
    @IBOutlet weak var dataToEncrypt: UITextField!
    @IBOutlet weak var encryptText: UILabel!
    @IBOutlet weak var baseText: UILabel!
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool
    {
        textField.resignFirstResponder()
        return true
    }
    
    func getting_ABC(_ text: String) -> [String] {
       
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
    
    func Get_shuft() {
        homophonic_el.removeAll()
        let fileNameShufr = "shufr"
        let fileNameFrequency = "Frequency"
        let docDirURLShufr = try! FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
        let fileURLShufr = docDirURLShufr.appendingPathComponent(fileNameShufr).appendingPathExtension("txt")
        let fileURLFrequency = docDirURLShufr.appendingPathComponent(fileNameFrequency).appendingPathExtension("txt")
        var readShufr = ""
        var readFrequency = ""
        do
        {
            readShufr = try String(contentsOf: fileURLShufr)
            readFrequency = try String(contentsOf: fileURLFrequency)
        }
        catch
        {
            print("ERROR")
        }
        
        var ind=0, ind1=0
        var arr = [Int]()
        var array = [[String]]()
        
        
        for i in 0..<Letters.count
        {
            if ind1 < readFrequency.count
            {
                var newINT = ""
                repeat
                {
                    newINT+=String(readFrequency[ind1])
                    ind1+=1
                }
                while readFrequency[ind1] != "," && ind1 < readFrequency.count
                arr.append(Int(newINT)!)
                ind1+=1
            }
            if ind < readShufr.count
            {
                var sub_array = [String]()
                repeat
                {
                    var newSTR = ""
                    for _ in 0...2
                    {
                        newSTR+=String(readShufr[ind])
                        ind+=1
                    }
                    sub_array.append(newSTR)
                }
                    while readShufr[ind] != "\n" && ind < readShufr.count
                ind+=1
                array.append(sub_array)
            }
            let get_shufr = homophonic_struct(letter: Character(Letters[i]), frequency: arr[i], code: array[i],freq_let: 0)
                homophonic_el.append(get_shufr)
        
        }
    }
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        dataToEncrypt.delegate = self
        
        let encryptIcon = UIApplicationShortcutIcon(templateImageName: "unlock")
        let encryptItem = UIApplicationShortcutItem(type: "encrypt", localizedTitle: "Encrypt", localizedSubtitle: "", icon: encryptIcon, userInfo: nil)
        
        UIApplication.shared.shortcutItems = [encryptItem]
        
        let decryptIcon = UIApplicationShortcutIcon(templateImageName: "lock")
        let decryptItem = UIApplicationShortcutItem(type: "decrypt", localizedTitle: "Decrypt", localizedSubtitle: "", icon: decryptIcon, userInfo: nil)
        
        var key = UserDefaults.standard
        key.set(myKey, forKey: "Key")
        key.synchronize()
        if key.value(forKey: "Key") != nil
        {
            myKey = key.value(forKey: "Key") as! NSInteger
        }
        UIApplication.shared.shortcutItems = [decryptItem]
        
//        MARK: Отримання шифру
        Get_shuft()
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
    
    func Caesars_code(_ text: inout String, _ newText: inout String) {
        var symbol: UInt16
        var newSymbol: String
        
        for character in text.utf16
        {
            symbol = character + UInt16(myKey)
            if String(UnicodeScalar(symbol)!) > "\u{042f}" && String(UnicodeScalar(character)!) <= "\u{042f}"
            {
                let vrongSymb = symbol
                symbol = UInt16(UnicodeScalar("А")!.value + UnicodeScalar(vrongSymb)!.value - UnicodeScalar("Я")!.value - 1)
            }
            if String(UnicodeScalar(symbol)!) > "\u{044f}" && String(UnicodeScalar(character)!) <= "\u{044f}"
            {
                let vrongSymb = symbol
                symbol = UInt16(UnicodeScalar("а")!.value + UnicodeScalar(vrongSymb)!.value - UnicodeScalar("я")!.value - 1)
            }
            
            newSymbol = String(UnicodeScalar(symbol)!)
            newText += newSymbol
        }
    }
    
    // MARK: Гомофонний шифр
    
    func Homophonic_code(_ text: inout String, _ newText: inout String)
    {
        for char in text
        {
            for j in 0 ..< homophonic_el.count
            {
                if char == homophonic_el[j].letter
                {
                    newText+=homophonic_el[j].code.randomElement()!
                    homophonic_el[j].freq_let+=1
                }
            }
        }
    }
    
    // MARK:    Шифр модульного гамування
    
    func Module_gamming_code (_ text: inout String, _ newText: inout String)
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
        let newAlphabet: [String] = getting_ABC(text)
        for i in 0 ..< newAlphabet.count
        {
            print("\(Letters[i]) = \(Int(newAlphabet.index(of: Letters[i])!))")
        }
        for k in 0 ..< text.count
        {
            if Int(newAlphabet.index(of: text[k])!)+Int(newAlphabet.index(of: keyPhrase[k])!) > 33
            {
                newText += newAlphabet[(Int(newAlphabet.index(of: text[k])!)+Int(newAlphabet.index(of: keyPhrase[k])!))%newAlphabet.count]
            }
            else
            {
            newText += newAlphabet[(Int(newAlphabet.index(of: text[k])!)+Int(newAlphabet.index(of: keyPhrase[k])!))]
            }
        }
    }

    
    // MARK: Шифрування з файлу
    
    @IBAction func encrypt_file(_ sender: UIButton)
    {
        let fileName = "File"
        let fileNameFileEnctypt = "FileEnctypt"
        let docDirURL = try! FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
        let fileURL = docDirURL.appendingPathComponent(fileName).appendingPathExtension("txt")
        let fileURLFileEnctypt = docDirURL.appendingPathComponent(fileNameFileEnctypt).appendingPathExtension("txt")
        var readString = ""
        print(fileURL)
        do
        {
            readString = try String(contentsOf: fileURL)
            print("Текст, який потрібно зашифрувати: \(readString)")
            baseText.text = "Текст, який потрібно зашифрувати: \(readString)"
            
        }
        catch
        {
            print("ERROR")
        }
        
        var newText = ""
        
        // MARK: Шифрування з вибором
        
        if currentMetod == 0
        {
            Caesars_code(&readString, &newText)
        }
        if currentMetod == 1
        {
            for i in 0 ..< homophonic_el.count
            {
                print("Кодові значення для літери '\(homophonic_el[i].letter)': ")
                for j in 0 ..< homophonic_el[i].code.count
                {
                    print("\(homophonic_el[i].code[j])")
                }
            }
            Homophonic_code(&readString, &newText)
            for i in 0 ..< homophonic_el.count
            {
                print("Літера '\(homophonic_el[i].letter)' використана \(homophonic_el[i].freq_let) разів з частотою \(Float(homophonic_el[i].freq_let)/Float(readString.count)*100)%")
                
            }
            for j in 0 ..< homophonic_el.count
            {
                homophonic_el[j].freq_let=0
            }
        }
        if currentMetod == 2
        {
            Module_gamming_code(&readString, &newText)
        }
        
        print("Зашифрований текст: \(newText)")
        encryptText.text =   "Зашифрований текст: \n\(newText)"
        do
        {
            try newText.write(to: fileURLFileEnctypt, atomically: false, encoding: .utf8)
        }
        catch _ as NSError
        {
            print("ERROR")
        }
        
    }
    
    // MARK: Шифрування звичайне
    
    @IBAction func encrypt(_ sender: UIButton)
    {
        var text = dataToEncrypt.text!
        baseText.text =  "Текст, який потрібно зашифрувати: \(text)"
        var newText = ""
        
        // MARK: Шифрування з вибором
        
        if currentMetod==0
        {
            Caesars_code(&text, &newText)
        }
        if currentMetod==1
        {
            Homophonic_code(&text, &newText)
            for i in 0 ..< homophonic_el.count
            {
                print("Літера '\(homophonic_el[i].letter)' використана \(homophonic_el[i].freq_let) разів з частотою \(Float(homophonic_el[i].freq_let)/Float(text.count)*100)%")
            }
            for j in 0 ..< homophonic_el.count
            {
                homophonic_el[j].freq_let=0
            }
        }
        if currentMetod==2
        {
            Module_gamming_code(&text, &newText)
        }
        
        encryptText.text = "Зашифрований текст: \(newText)"
    }
    
    @IBAction func copy_encrypt(_ sender: UIButton)
    {
        //Копіювання даних
        var copy_text = encryptText.text!
        let range = copy_text.startIndex ..< copy_text.index(copy_text.startIndex, offsetBy: 20)
        copy_text.removeSubrange(range)
        UIPasteboard.general.string = copy_text
        print(currentMetod)
    }
    
    @IBAction func shareButton(_ sender: UIButton)
    {
        let activityController = UIActivityViewController(activityItems: [encryptText.text], applicationActivities: nil)
        present(activityController, animated: true, completion: nil)
    }
    
}

