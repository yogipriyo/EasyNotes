//
//  NoteDetailsViewController.swift
//  EasyNotes
//
//  Created by Yogi Priyo Prayogo on 04/06/21.
//  Copyright © 2021 Yogi Priyo Prayogo. All rights reserved.
//

import UIKit
import WebKit
import CoreData

class NoteDetailsViewController: UIViewController, UITextViewDelegate, WKNavigationDelegate {
    
    enum TextMode {
        case normal
        case bold
        case italic
        case underscore
        case orderedList
        case unorderedList
    }
    
    @IBOutlet weak var topContainer: UIView!
    @IBOutlet weak var titleTextField: UITextField!
    @IBOutlet weak var midContainer: UIView!
    @IBOutlet weak var contentContainer: UIView!
    @IBOutlet weak var textViewEditor: UITextView!
    @IBOutlet weak var toolbarContainer: UIView!
    @IBOutlet weak var bottomContainer: UIView!
    
    var textMode: TextMode = .normal
    
    lazy var webView: WKWebView = {
        let webConfiguration = WKWebViewConfiguration()
        let webView = WKWebView(frame: .zero, configuration: webConfiguration)
        webView.navigationDelegate = self
        webView.translatesAutoresizingMaskIntoConstraints = false
        return webView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.title = "Note Details"
        self.textViewEditor.delegate = self
        self.contentContainer.layer.borderWidth = 1
        self.contentContainer.layer.borderColor = UIColor.gray.cgColor
        self.contentContainer.layer.cornerRadius = 10
    }
    
    func textViewDidChange(_ textView: UITextView) { //Handle the text changes here
//        print(textView.text)
    }
    
    func processString(content: String) {
        
    }

    @IBAction func boldButtonTapped(_ sender: UIButton) {
        setupTextMode(textMode: .bold)
    }
    
    @IBAction func italicButtonTapped(_ sender: UIButton) {
        setupTextMode(textMode: .italic)
    }
    
    @IBAction func saveButtonTapped(_ sender: UIButton) {
        saveData()
    }
    
    func setupTextMode(textMode: TextMode) {
        self.textMode = self.textMode == textMode ? .normal : textMode
        
        switch self.textMode {
        case .bold:
            let attrs = [NSAttributedString.Key.font : UIFont.boldSystemFont(ofSize: 15)]
            textViewEditor.typingAttributes = attrs
        case .italic:
            let attrs = [NSAttributedString.Key.font : UIFont.italicSystemFont(ofSize: 15)]
            textViewEditor.typingAttributes = attrs
//        case .underscore:
//            let attrs = [NSAttributedString.Key.underlineStyle]
//            textViewEditor.typingAttributes = attrs
        default:
            textViewEditor.typingAttributes = [:]
        }
    }
    
    func saveData() {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
            return
        }
        
        // 1
        let managedContext = appDelegate.persistentContainer.viewContext
        
        // 2
        let entity = NSEntityDescription.entity(forEntityName: "Note", in: managedContext)!
        
        let note = NSManagedObject(entity: entity, insertInto: managedContext)
//        let note = EasyNote(title: self.titleTextField.text ?? "Empty title", content: self.textViewEditor.text, insertIntoManagedObjectContext: managedContext)
        
        // 3
//        person.setValue(name, forKeyPath: "name")
        note.setValue(self.titleTextField.text ?? "Empty title", forKey: "title")
        note.setValue(self.textViewEditor.text, forKey: "content")
        
        // 4
        do {
          try managedContext.save()
//          people.append(person)
            print("save ok")
        } catch let error as NSError {
          print("Could not save. \(error), \(error.userInfo)")
        }
    }
}
