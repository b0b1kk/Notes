//
//  ViewController.swift
//  Notes
//
//  Created by fo_0x on 07.05.2019.
//  Copyright © 2019 fo_0x. All rights reserved.
//

import UIKit
import CoreData

class ViewController: UIViewController, NSFetchedResultsControllerDelegate {

    var notesTableView = UITableView()
    
    let sortImage = UIImage(named: "sortIcon")
    
    var searchController = UISearchController(searchResultsController: nil)
    
    var searchBarIsEmpty: Bool {
        guard let text = searchController.searchBar.text else { return false }
        return text.isEmpty
    }
    
    var isFiltering: Bool {
        return searchController.isActive && !searchBarIsEmpty
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

            title = "Notes"
    
            createTableView()
        
            // setup the search controller
            searchController.searchResultsUpdater = self
            searchController.obscuresBackgroundDuringPresentation = false
            searchController.searchBar.placeholder = "Search"
            notesTableView.tableHeaderView = searchController.searchBar
            definesPresentationContext = true
        
            //create right bar button
        let sortedRightBarButton = UIBarButtonItem(image: sortImage, style: .plain, target: self, action: #selector(sortedNotes(sender:)))
        let addRightBarButton = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addNotesItemOnSecondVC(sender:)))
        navigationItem.rightBarButtonItems = [addRightBarButton, sortedRightBarButton]
        
        
        
    }
    
    // reload data in table view
    override func viewWillAppear(_ animated: Bool) {
        notesTableView.reloadData()
        fetch()
        
    }
    
    // action to add bar button
    @objc func addNotesItemOnSecondVC(sender: UIBarButtonItem) {
        let secondVC = SecondViewController()
        secondVC.changeBarButton = true
        navigationController?.pushViewController(secondVC, animated: true)
        
    }
    
    //action to sorted right bar button with alert
    @objc func sortedNotes(sender: UIBarButtonItem) {
        
        let alert = UIAlertController(title: nil, message: "select sorted type", preferredStyle: .actionSheet)
        alert.addAction(UIAlertAction(title: "New first", style: .default, handler: { (_) in
            noteArray.sort(by: { (s1, s2) -> Bool in
                return (s1.value(forKey: "timeAndDate") as! String) < (s2.value(forKey: "timeAndDate") as! String)
            })
            self.notesTableView.reloadData()
        }))
        alert.addAction(UIAlertAction(title: "Old first", style: .default, handler: { (_) in
            noteArray.sort(by: { (s1, s2) -> Bool in
                return (s1.value(forKey: "timeAndDate") as! String) > (s2.value(forKey: "timeAndDate") as! String)
            })
            self.notesTableView.reloadData()
        }))
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: { (_) in
        }))
        
        present(alert, animated: true, completion: nil)
        
        
    }
    // create table view on board
    func createTableView() {
        notesTableView = UITableView(frame: view.bounds, style: .plain)
        notesTableView.register(UITableViewCell.self, forCellReuseIdentifier: "Cell")
        notesTableView.delegate = self
        notesTableView.dataSource = self
        view.addSubview(notesTableView)
    }
   
    // update table view
    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        notesTableView.beginUpdates()
    }
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        
        switch type {
        case .insert:
            if let _newIndexPath = newIndexPath {
                notesTableView.insertRows(at: [_newIndexPath], with: .fade)
            }
        case .delete:
            if let _newIndexPath = newIndexPath {
                notesTableView.deleteRows(at: [_newIndexPath], with: .fade)
            }
        case .update:
            if let _newIndexPath = newIndexPath {
                notesTableView.reloadRows(at: [_newIndexPath], with: .fade)
            }
        default:
            notesTableView.reloadData()
        }
        noteArray = controller.fetchedObjects as! [NSManagedObject]
    }
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        notesTableView.endUpdates()
    }
}

extension ViewController:  UITableViewDataSource, UITableViewDelegate {

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60.0
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if isFiltering {
            return searchContent.count
        }
        return noteArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        //create a cell in table view
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        cell.accessoryType = .disclosureIndicator
        cell.textLabel?.numberOfLines = 2
        cell.textLabel?.font = UIFont(name: "Arial", size: 14.0)
        
        let timeAndDateLabel = UILabel()
        timeAndDateLabel.frame = CGRect(x: 5, y: 5, width: 100, height: 10)
        timeAndDateLabel.font = UIFont(name: "Arial", size: 9.0)
        timeAndDateLabel.textColor = UIColor.gray
        
        var note: NSManagedObject
        
        if isFiltering {
            note = searchContent[indexPath.row]
        } else {
            note = noteArray[indexPath.row]
        }
        
        timeAndDateLabel.text = note.value(forKey: "timeAndDate") as? String
        
        cell.addSubview(timeAndDateLabel)
        
        
        
        //limit the text to 100 characters
        let item = noteArray[indexPath.row]
        let nsString = item.value(forKey: "notes") as! NSString
        if nsString.length >= 100 {
            cell.textLabel?.text = nsString.substring(with: NSRange(location: 0, length: nsString.length > 100 ? 100 : nsString.length))
        } else {
            cell.textLabel?.text = item.value(forKey: "notes") as? String
        }
        return cell
    }
    
    // edit row in table view
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    // delete note with core data
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        
        
        if editingStyle == .delete {
            self.delete(indexP: indexPath.row)

        } else if editingStyle == .insert {
            
        }
    }
 
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        //push second VC when select a row in table view
        let secondVC = SecondViewController()
        secondVC.customIndex(indexRow: indexPath.row, textNotes: (noteArray[indexPath.row].value(forKey: "notes") as? String) ?? "nil")
        secondVC.changeBarButton = false
        
        navigationController?.pushViewController(secondVC, animated: true)
        tableView.deselectRow(at: indexPath, animated: true)
        
    }
    
    
}


extension ViewController: UISearchResultsUpdating {
    
    func updateSearchResults(for searchController: UISearchController) {
            filterContent(searchText: searchController.searchBar.text!)
    }

    func filterContent(searchText: String) {
        searchContent = noteArray.filter({ (note: NSManagedObject) -> Bool in
            return (note.value(forKey: "notes") as! String).lowercased().contains(searchText.lowercased())
        })
        
        notesTableView.reloadData()

    }


}

