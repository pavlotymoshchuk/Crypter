import UIKit
import Foundation

class TableABCChange: UIViewController {
    override func viewDidLoad() {
        
    }
    
    func Table_KEY() {
        var cols = 7
        var leters = Letters
        leters.append(".")
        leters.shuffle()
        
        let fileName = "Table_KEY"
        let docDirURL = try! FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
        let empty = ""
        let fileURL = docDirURL.appendingPathComponent(fileName).appendingPathExtension("txt")
        do {
            try empty.write(to: fileURL, atomically: false, encoding: .utf8)
        } catch{}
        let fileWriter = try? FileHandle(forWritingTo: fileURL)
        var j = 0
        for i in 0 ..< leters.count {
            if (fileWriter != nil) {
                fileWriter?.seekToEndOfFile()
                fileWriter?.write(leters[i].data(using: .utf8)!)
            }
            j+=1
            if j == cols {
                fileWriter?.seekToEndOfFile()
                fileWriter?.write("\u{000D}".data(using: .utf8)!)
                j = 0
            }
        }
        print(fileURL)
    }

    @IBAction func useCurrentTable(_ sender: UIButton) {
        //MARK: - Відміна відкриття view
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func createNewTable(_ sender: UIButton) {
        //MARK: Запис таблиці ключа
        Table_KEY()
    }
    
    @IBAction func save(_ sender: UIButton) {
        //MARK: - Відміна відкриття view
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func cancel(_ sender: UIButton) {
        //MARK: - Відміна відкриття view
        dismiss(animated: true, completion: nil)
    }
    
}

