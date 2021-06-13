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

final class NoteDetailsViewController: UIViewController, UITextViewDelegate, WKNavigationDelegate {
    
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
    @IBOutlet weak var olButton: UIButton!
    @IBOutlet weak var contentContainer: UIView!
    @IBOutlet weak var textViewEditor: UITextView!
    @IBOutlet weak var toolbarContainer: UIView!
    @IBOutlet weak var bottomContainer: UIView!
    @IBOutlet weak var saveButton: UIButton!
    @IBOutlet weak var deleteButton: UIButton!
    
    var activeTextMode: TextMode = .normal
    var noteDetails: NSManagedObject?
    let bullet = "•  "
    var currentNumberingValue: Int = 1
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
    
    private func setupUI() {
        self.title = "Note Details"
        self.textViewEditor.delegate = self
        self.contentContainer.layer.borderWidth = 1
        self.contentContainer.layer.borderColor = UIColor.gray.cgColor
        self.contentContainer.layer.cornerRadius = 10
        
        buttonArray = [boldButton, italicButton, underscoreButton, ulButton, olButton]
        for button in buttonArray {
            button.layer.cornerRadius = 5
        }
        deleteButton.layer.cornerRadius = 5
        saveButton.layer.cornerRadius = 5
    }
    
    private func setupContent() {
        guard let noteDetails = noteDetails else { return }
        self.titleTextField.text = noteDetails.value(forKey: "title") as? String
        self.textViewEditor.attributedText = noteDetails.value(forKey: "content") as? NSAttributedString
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
        setupTextMode(textMode: .unorderedList)
    }
    
    @IBAction func orderedListButtonTapped(_ sender: UIButton) {
        setupTextMode(textMode: .orderedList)
    }
    
    @IBAction func saveButtonTapped(_ sender: UIButton) {
        if let noteDetails = self.noteDetails {
            updateNote(noteDetails: noteDetails)
        } else {
            addNote()
        }
    }
    
    @IBAction func deleteButtonTapped(_ sender: UIButton) {
        deleteNote(noteDetails: noteDetails)
    }
    
    private func setupTextMode(textMode: TextMode) {
        self.activeTextMode = self.activeTextMode == textMode ? .normal : textMode
        
        switch self.activeTextMode {
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
            bulletProcessing()
        case .orderedList:
            numberingProcessing()
        default:
            resetStyling()
        }
    }
    
    private func numberingProcessing() {
        if let attrStr = textViewEditor.attributedText {
            let newMutableString = attrStr.mutableCopy() as! NSMutableAttributedString
            newMutableString.append(
                createAttributed(string: "\n"+String(currentNumberingValue)+".  ")
            )

            textViewEditor.attributedText = newMutableString
            self.activeTextMode = .normal
            self.currentNumberingValue += 1
            resetButtonView()
        }
    }
    
    private func bulletProcessing() {
        if let attrStr = textViewEditor.attributedText {
            let newMutableString = attrStr.mutableCopy() as! NSMutableAttributedString
            newMutableString.append(
                createAttributed(string: "\n"+bullet)
            )

            textViewEditor.attributedText = newMutableString
            self.activeTextMode = .normal
            self.currentNumberingValue = 1
            resetButtonView()
        }
    }
    
    private func createAttributed(string: String) -> NSAttributedString {
        return NSAttributedString(string: string, attributes: [NSAttributedString.Key.font : UIFont.systemFont(ofSize: 17)])
    }
    
    private func resetStyling() {
        resetButtonView()
        self.activeTextMode = .normal
        let attrs = [NSAttributedString.Key.font : UIFont.systemFont(ofSize: 17)]
        textViewEditor.typingAttributes = attrs
    }
    
    private func highlightButton(target: UIButton) {
        resetButtonView()
        target.backgroundColor = .systemGreen
    }
    
    private func resetButtonView() {
        for button in buttonArray {
            button.backgroundColor = .darkGray
        }
    }
    
    private func displayPopup(title: String, subtitle: String) {
        let refreshAlert = UIAlertController(title: title, message: subtitle, preferredStyle: UIAlertController.Style.alert)

        refreshAlert.addAction(UIAlertAction(title: "OK", style: .default, handler: { (action: UIAlertAction!) in
            self.navigationController?.popToRootViewController(animated: true)
        }))
        
        self.present(refreshAlert, animated: true, completion: nil)
    }
    
    private func addNote() {
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
            displayPopup(title: "Success!", subtitle: "Note is saved")
        } catch _ as NSError {
            displayPopup(title: "Sorry!", subtitle: "Failed to save note")
        }
    }
    
    private func updateNote(noteDetails: NSManagedObject?) {
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
            displayPopup(title: "Success!", subtitle: "Note is updated")
        } catch _ as NSError {
            displayPopup(title: "Sorry!", subtitle: "Failed to update note")
        }
    }
    
    private func deleteNote(noteDetails: NSManagedObject?) {
        var context: NSManagedObjectContext {
           let appDelegate = UIApplication.shared.delegate as! AppDelegate
           return appDelegate.persistentContainer.viewContext
        }
        
        let fetchNote: NSFetchRequest<NoteEntity> = NoteEntity.fetchRequest()
        fetchNote.predicate = NSPredicate(format: "id = %d", noteDetails?.value(forKey: "id") as! Int)
        
        do {
            let objects = try context.fetch(fetchNote)
            for object in objects {
                context.delete(object)
            }
            try context.save()
            displayPopup(title: "Success!", subtitle: "Note is deleted")
        } catch _ as NSError {
            displayPopup(title: "Sorry!", subtitle: "Failed to delete note")
        }
    }
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        self.currentNumberingValue = text == "\n" ? 1 : self.currentNumberingValue
        return true
    }
}
