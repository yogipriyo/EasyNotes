//
//  HomeViewController.swift
//  EasyNotes
//
//  Created by Yogi Priyo Prayogo on 03/06/21.
//  Copyright © 2021 Yogi Priyo Prayogo. All rights reserved.
//

import UIKit
import CoreData

final class HomeViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    // MARK: - Outlets & properties
    @IBOutlet weak var notesTableView: UITableView!
    @IBOutlet weak var addNoteButton: UIButton!
    
    var noteArray: [NSManagedObject] = []
    
    // MARK: - Life Cycles
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        setupUI()
        setupTable()
        fecthData()
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        setupNavbar()
    }
    
    // MARK: - Private functions
    private func setupUI() {
        addNoteButton.layer.cornerRadius = 5
    }
    
    private func fecthData() {

        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
            return
        }
        
        let managedContext = appDelegate.persistentContainer.viewContext
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "Note")
        
        do {
            noteArray = try managedContext.fetch(fetchRequest)
            notesTableView.reloadData()
        } catch let error as NSError {
            print("Could not fetch. \(error), \(error.userInfo)")
        }
    }
    
    private func setupNavbar() {
        self.title = "Home"
    }
    
    private func setupTable() {
        notesTableView.delegate = self
        notesTableView.dataSource = self
        notesTableView.tableFooterView = UIView()
        
        let textFieldCell = UINib(nibName: "NoteTableViewCell", bundle: nil)
        notesTableView.register(textFieldCell, forCellReuseIdentifier: "NoteTableViewCell")
        notesTableView.reloadData()
    }
    
    private func goToDetailNote(noteDetails: NSManagedObject? = nil) {
        let noteDetailsVC: NoteDetailsViewController = NoteDetailsViewController()
        noteDetailsVC.noteDetails = noteDetails
        self.navigationController?.pushViewController(noteDetailsVC, animated: true)
    }
    
    @IBAction func addNoteTapped(_ sender: UIButton) {
        goToDetailNote()
    }
    

    // MARK: - Tableview delegate & datasource
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        self.noteArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let cell = tableView.dequeueReusableCell(withIdentifier: "NoteTableViewCell") as? NoteTableViewCell {
            cell.setupContent(title: self.noteArray[indexPath.row].value(forKey: "title") as! String)
            return cell
        }
        
        return UITableViewCell()
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        goToDetailNote(noteDetails: self.noteArray[indexPath.row])
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 50
    }
}
