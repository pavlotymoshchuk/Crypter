//
//  AppDelegate.swift
//  Crypter
//
//  Created by Павло Тимощук on 7/20/18.
//  Copyright © 2018 Павло Тимощук. All rights reserved.
//

import UIKit
import Foundation

var myKey = 27
var myKeyWord = "ну лп"
var arrayOfMetods = ["Шифр Цезаря", "Гомофонний шифр", "Шифр модульного гамування", "Шифр Плейфера"]
var currentMetod = 3
var Letters =
    ["\u{0020}","а","б","в","г","ґ","д","е","є","ж","з","и","і","ї","й","к","л","м","н","о","п","р", "с","т","у","ф","х","ц","ч","ш","щ","ь","ю","я",
     "А","Б","В","Г","Ґ","Д","Е","Є","Ж","З","И","І","Ї","Й","К","Л","М","Н","О","П","Р","С","Т","У","Ф","Х","Ц","Ч","Ш","Щ","Ь",
     "1","2","3","4","5","6","7","8","9","0","-","№"]

struct homophonic_struct
{
    var letter: Character
    var frequency: Int
    var code: [String]
    var freq_let: Int
}

var homophonic_el: [homophonic_struct] = []


func get_position(_ Table_KEY: [[String]], _ a: String, _ pos_a: inout [Int], _ b: String, _ pos_b: inout [Int]) {
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
}

func double_replace(_ pos_a: inout [Int], _ pos_b: inout [Int], _ newText: inout String, _ Table_KEY: [[String]], _ param: Int) {
    if pos_a[0] == pos_b[0] // Літери в одному рядку
    {
        newText += Table_KEY[pos_a[0]][(pos_a[1]+Table_KEY[0].count+param)%Table_KEY[0].count]
        newText += Table_KEY[pos_b[0]][(pos_b[1]+Table_KEY[0].count+param)%Table_KEY[0].count]
    }
    else if pos_a[1] == pos_b[1] // Літери в одному стовпці
    {
        newText += Table_KEY[(pos_a[0]+Table_KEY.count+param)%Table_KEY.count][pos_a[1]]
        newText += Table_KEY[(pos_b[0]+Table_KEY.count+param)%Table_KEY.count][pos_b[1]]
    }
    else // Літери утворюють прямокутник
    {
        newText += Table_KEY[pos_b[0]][pos_a[1]]
        newText += Table_KEY[pos_a[0]][pos_b[1]]
    }
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
    var rows = 5, cols = 7
    var i = 0
    for _ in 0 ..< rows
    {
        var sub_array = [String]()
        for _ in 0 ..< cols
        {
            sub_array.append(readTable_KEY[i])
            i+=1
        }
        Table_KEY.append(sub_array)
        i+=1
    }
    return Table_KEY
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
//
@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate
{
    var window: UIWindow?
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {return true}
    func applicationWillResignActive(_ application: UIApplication) {}
    func applicationDidEnterBackground(_ application: UIApplication) {}
    func applicationWillEnterForeground(_ application: UIApplication) {}
    func applicationDidBecomeActive(_ application: UIApplication) {}
    func applicationWillTerminate(_ application: UIApplication) {}

}
