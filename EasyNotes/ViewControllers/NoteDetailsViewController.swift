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
    var noteDetails: NSManagedObject?
    
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
        
        setupUI()
        setupContent()
    }
    
    func setupUI() {
        self.title = "Note Details"
        self.textViewEditor.delegate = self
        self.contentContainer.layer.borderWidth = 1
        self.contentContainer.layer.borderColor = UIColor.gray.cgColor
        self.contentContainer.layer.cornerRadius = 10
    }
    
    func setupContent() {
        guard let noteDetails = noteDetails else { return }
        self.titleTextField.text = noteDetails.value(forKey: "title") as? String
        self.textViewEditor.attributedText = noteDetails.value(forKey: "content") as? NSAttributedString
    }
    
    func textViewDidChange(_ textView: UITextView) { //Handle the text changes here
        
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
        if let noteDetails = self.noteDetails {
            updateNote(noteDetails: noteDetails)
        } else {
            addNote()
        }
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
    
    func addNote() {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return }
        
        let managedContext = appDelegate.persistentContainer.viewContext
        let entity = NSEntityDescription.entity(forEntityName: "Note", in: managedContext)!
        
        let note = NSManagedObject(entity: entity, insertInto: managedContext)
        let randomInt = Int.random(in: 1..<5)
        note.setValue(randomInt, forKeyPath: "id")
        note.setValue(self.titleTextField.text ?? "Empty title", forKey: "title")
        note.setValue(self.textViewEditor.attributedText, forKey: "content")
        
        do {
            try managedContext.save()
            print("save ok")
        } catch let error as NSError {
            print("Could not save. \(error), \(error.userInfo)")
        }
    }
    
    func updateNote(noteDetails: NSManagedObject?) {
        var context: NSManagedObjectContext {
           let appDelegate = UIApplication.shared.delegate as! AppDelegate
           return appDelegate.persistentContainer.viewContext
        }
        
        let note: NoteEntity!
        let fetchNote: NSFetchRequest<NoteEntity> = NoteEntity.fetchRequest()
        fetchNote.predicate = NSPredicate(format: "id = %d", noteDetails?.value(forKey: "id") as! Int)

        let results = try? context.fetch(fetchNote)

        if results?.count == 0 {
            note = NoteEntity(context: context)
        } else {
            note = results?.first
        }

        note.title = self.titleTextField.text ?? "Empty Title"
        note.content = self.textViewEditor.attributedText
        
        do {
            try context.save()
            print("update ok")
        } catch let error as NSError {
            print("Could not update. \(error), \(error.userInfo)")
        }
    }
}
