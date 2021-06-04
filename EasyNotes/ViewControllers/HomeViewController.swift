//
//  HomeViewController.swift
//  EasyNotes
//
//  Created by Yogi Priyo Prayogo on 03/06/21.
//  Copyright © 2021 Yogi Priyo Prayogo. All rights reserved.
//

import UIKit

final class HomeViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    // MARK: - Outlets & properties
    @IBOutlet weak var notesTableView: UITableView!
    
    // MARK: - Life Cycles
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        setupNavbar()
        setupTable()
    }
    
    // MARK: - Private functions
    private func setupNavbar() {
        self.title = "Home"
    }
    
    private func setupTable() {
        notesTableView.delegate = self
        notesTableView.dataSource = self
        notesTableView.tableFooterView = UIView()
        
        let textFieldCell = UINib(nibName: "NoteTableViewCell", bundle: nil)
        notesTableView.register(textFieldCell, forCellReuseIdentifier: "NoteTableViewCell")
    }

    // MARK: - Tableview delegate & datasource
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        4
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let cell = tableView.dequeueReusableCell(withIdentifier: "NoteTableViewCell") as? NoteTableViewCell {
            return cell
        }
        
        return UITableViewCell()
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print("_+_+_ \(indexPath.row)")
        print("_+_+_ \(self.navigationController)")
        let noteDetailsVC: NoteDetailsViewController = NoteDetailsViewController()
        self.navigationController?.pushViewController(noteDetailsVC, animated: true)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60
    }
}
