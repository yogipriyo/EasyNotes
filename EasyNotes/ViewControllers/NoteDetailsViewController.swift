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
    @IBOutlet weak var boldButton: UIButton!
    @IBOutlet weak var italicButton: UIButton!
    @IBOutlet weak var underscoreButton: UIButton!
    @IBOutlet weak var ulButton: UIButton!
    @IBOutlet weak var contentContainer: UIView!
    @IBOutlet weak var textViewEditor: UITextView!
    @IBOutlet weak var toolbarContainer: UIView!
    @IBOutlet weak var bottomContainer: UIView!
    @IBOutlet weak var saveButton: UIButton!
    @IBOutlet weak var deleteButton: UIButton!
    
    var textMode: TextMode = .normal
    var noteDetails: NSManagedObject?
    let bullet = "•  "
    var buttonArray: [UIButton] = []
    
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
        
        buttonArray = [boldButton, italicButton, underscoreButton, ulButton]
        for button in buttonArray {
            button.layer.cornerRadius = 5
        }
        deleteButton.layer.cornerRadius = 5
        saveButton.layer.cornerRadius = 5
    }
    
    func setupContent() {
        guard let noteDetails = noteDetails else { return }
        self.titleTextField.text = noteDetails.value(forKey: "title") as? String
        self.textViewEditor.attributedText = noteDetails.value(forKey: "content") as? NSAttributedString
    }
    
    func textViewDidChange(_ textView: UITextView) { //Handle the text changes here
        
    }
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        
//        if text == "\n" {
//            if self.textMode == .unorderedList {
//                textViewEditor.text += bullet
//            }
//            return true
//        }
        if self.textMode == .unorderedList && text == "\n" {
            
        }
        return true
    }
    
    func processString(content: String) {
        
    }

    @IBAction func boldButtonTapped(_ sender: UIButton) {
        highlightButton(target: boldButton)
        setupTextMode(textMode: .bold)
    }
    
    @IBAction func italicButtonTapped(_ sender: UIButton) {
        highlightButton(target: italicButton)
        setupTextMode(textMode: .italic)
    }
    
    @IBAction func underscoreButtonTapped(_ sender: UIButton) {
        highlightButton(target: underscoreButton)
        setupTextMode(textMode: .underscore)
    }
    
    @IBAction func unorderedListButtonTapped(_ sender: UIButton) {
        highlightButton(target: ulButton)
        setupTextMode(textMode: .unorderedList)
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
            let attrs = [NSAttributedString.Key.font : UIFont.boldSystemFont(ofSize: 17)]
            textViewEditor.typingAttributes = attrs
        case .italic:
            let attrs = [NSAttributedString.Key.font : UIFont.italicSystemFont(ofSize: 17)]
            textViewEditor.typingAttributes = attrs
        case .underscore:
            let attrs = [
                NSAttributedString.Key.underlineColor: UIColor.black,
                .underlineStyle: NSUnderlineStyle.thick.rawValue | NSUnderlineStyle.single.rawValue,
                .font: UIFont.systemFont(ofSize: 17)
                ] as [NSAttributedString.Key : Any]
            textViewEditor.typingAttributes = attrs
        case .unorderedList:
//            let paragraph = NSMutableParagraphStyle()
////            paragraph.firstLineHeadIndent = 15
//            paragraph.headIndent = 15
//
//            let attrs = [
//                NSAttributedString.Key.paragraphStyle: paragraph
//            ]
//            textViewEditor.typingAttributes = attrs
//            let bullet = "•  "
//            let paragraphStyle = NSMutableParagraphStyle()
//            paragraphStyle.headIndent = (bullet as NSString).size(withAttributes: attributes).width
//            attributes[.paragraphStyle] = paragraphStyle
            
            textViewEditor.text += "\n"+bullet
        default:
            resetButtonView()
            let attrs = [NSAttributedString.Key.font : UIFont.systemFont(ofSize: 17)]
            textViewEditor.typingAttributes = attrs
        }
    }
    
    func highlightButton(target: UIButton) {
        resetButtonView()
        target.backgroundColor = .systemGreen
    }
    
    func resetButtonView() {
        for button in buttonArray {
            button.backgroundColor = .darkGray
        }
    }
    
    func displayPopup(title: String, subtitle: String) {
        let refreshAlert = UIAlertController(title: title, message: subtitle, preferredStyle: UIAlertController.Style.alert)

        refreshAlert.addAction(UIAlertAction(title: "OK", style: .default, handler: { (action: UIAlertAction!) in
            self.navigationController?.popToRootViewController(animated: true)
        }))
        
        self.present(refreshAlert, animated: true, completion: nil)
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
            displayPopup(title: "Success!", subtitle: "Note is saved")
        } catch let error as NSError {
            print("Could not save. \(error), \(error.userInfo)")
            displayPopup(title: "Sorry!", subtitle: "Failed to save note")
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
            displayPopup(title: "Success!", subtitle: "Note is updated")
        } catch let error as NSError {
            print("Could not update. \(error), \(error.userInfo)")
            displayPopup(title: "Sorry!", subtitle: "Failed to update note")
        }
    }
}
