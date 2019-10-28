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
var arrayOfMetods = ["Шифр Цезаря","Гомофонний шифр","Шифр модульного гамування"]
var currentMetod = 2
var Letters =
    ["\u{0020}","а","б","в","г","ґ","д","е","є","ж","з","и","і","ї","й","к","л","м","н","о","п","р", "с","т","у","ф","х","ц","ч","ш","щ","ь", "ю","я"]
// "А","Б","В","Г","Ґ","Д","Е","Є","Ж","З","И","І","Ї","Й","К","Л","М","Н","О","П","Р","С","Т","У","Ф","Х","Ц","Ч","Ш","Щ", "Ь", "Ю","Я",                    "a","b","c","d","e","f","g","h","i","j","k","l","m","n","o","p","q","r","s","t","u","v","w","x","y","z",      "A","B","C","D","E","F","G","H","I","J","K","L","M","N","O","P","Q","R","S","T","U","V","W","X","Y","Z",",",".","?","!","@","#","$","%","^","&","*","(",")","-","+","=","_","/", "1","2","3","4","5","6","7","8","9","0","{","}","[","]",":",";","'","|","\u{000D}"

struct homophonic_struct
{
    var letter: Character
    var frequency: Int
    var code: [String]
    var freq_let: Int
}

var homophonic_el: [homophonic_struct] = []



@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    var window: UIWindow?
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {return true}
    
    func applicationWillResignActive(_ application: UIApplication) {}

    func applicationDidEnterBackground(_ application: UIApplication) {}

    func applicationWillEnterForeground(_ application: UIApplication) {}

    func applicationDidBecomeActive(_ application: UIApplication) {}

    func applicationWillTerminate(_ application: UIApplication) {}



}

