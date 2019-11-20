//  Crypter
//
//  Created by Павло Тимощук on 03.09.2019.
//  Copyright © 2019 Павло Тимощук. All rights reserved.
//

import UIKit
import Foundation
import AVFoundation
import AudioToolbox

func MixLetters()
{
    var leters = Letters
    leters.shuffle()
    let fileName = "Mixed_letters"
    let docDirURL = try! FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
    let fileURL = docDirURL.appendingPathComponent(fileName).appendingPathExtension("txt")
    for i in 0 ..< leters.count
    {
        if let fileUpdater = try? FileHandle(forUpdating: fileURL)
        {
            fileUpdater.seekToEndOfFile()
            fileUpdater.write(leters[i].data(using: .utf8)!)
            fileUpdater.closeFile()
        }
    }
}

func createSHUFR()
{
    let fileNameFrequency = "Frequency"
    let docDirURLShufr = try! FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
    let fileURLFrequency = docDirURLShufr.appendingPathComponent(fileNameFrequency).appendingPathExtension("txt")
    var readFrequency = ""
    do
    {
        readFrequency = try String(contentsOf: fileURLFrequency)
    }
    catch
    {
        print("ERROR")
    }
    
    var ind1=0
    var arr = [Int]()

    for _ in 0..<Letters.count
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
    }
    
    let fileName = "shufr"
    let docDirURL = try! FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
    let fileURL = docDirURL.appendingPathComponent(fileName).appendingPathExtension("txt")
    var lenth_mas = 0
    
    for i in arr {
        lenth_mas+=i
    }
    var array = [Int]()
    array.append(Int.random(in: 100 ..< 1000))
    for i in 1..<lenth_mas
    {
        var k=0
        var random:Int
        repeat
        {
            k=0
            random = Int.random(in: 100 ..< 1000)
            for j in 0..<i
            {
                if random == array[j]
                {
                    k+=1
                }
            }
        }
        while k != 0
        array.append(random)
        print(array[i])
    }

    var h=0
    for i in 0..<Letters.count
    {
        var shufr_letter = ""
        for _ in 0 ..< arr[i]
        {
            shufr_letter += String(array[h])
            h+=1
        }
        shufr_letter+="\n"
        if let fileUpdater = try? FileHandle(forUpdating: fileURL) {

            fileUpdater.seekToEndOfFile()

            fileUpdater.write(shufr_letter.data(using: .utf8)!)

            fileUpdater.closeFile()
        }
    }
}

class MetodChange: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource
{
    override func viewDidLoad()
    {
        metodPicker.delegate = self
        metodPicker.dataSource = self
    }
    
    @IBOutlet weak var currentKey: UILabel!
    @IBOutlet weak var newKey: UITextField!
    @IBOutlet weak var metodPicker: UIPickerView!
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String?
    {
        return arrayOfMetods[row]
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int
    {
        return arrayOfMetods.count
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int
    {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        currentMetod = row
    }
    
    @IBAction func cancelButton(_ sender: UIButton)
    {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "TabBar")
        self.present(vc, animated: true, completion: nil)
    }
    
    @IBAction func saveButton(_ sender: UIButton)
    {
        if currentMetod == 0
        {
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let vc = storyboard.instantiateViewController(withIdentifier: "KeyChange")
            self.present(vc, animated: true, completion: nil)
        }
        if currentMetod == 1
        {
            //MARK: Створення шифру
//            createSHUFR()
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let vc = storyboard.instantiateViewController(withIdentifier: "TabBar")
            self.present(vc, animated: true, completion: nil)
        }
        if currentMetod == 2
        {
            //MARK: Запис рандомно розташованих літер
//            MixLetters()
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let vc = storyboard.instantiateViewController(withIdentifier: "KeyWordChange")
            self.present(vc, animated: true, completion: nil)
        }
        if currentMetod == 3
        {
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let vc = storyboard.instantiateViewController(withIdentifier: "TableABCChange")
            self.present(vc, animated: true, completion: nil)
        }
    }
}
