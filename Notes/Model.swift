//
//  Model.swift
//  Notes
//
//  Created by fo_0x on 07.05.2019.
//  Copyright © 2019 fo_0x. All rights reserved.
//

import Foundation
import UIKit
import CoreData

class NotesOfApp {
    
    var notes: String
    
    var timeAndDate: String
    
    init(notes: String, timeAndDate: String) {
        self.notes = notes
        self.timeAndDate = timeAndDate
    }
}


var noteArray: [NSManagedObject] = []

var searchContent: [NSManagedObject] = []


func time() -> String {
    let date = Date()
    
    let formatter = DateFormatter()
    
    formatter.dateStyle = .short
    formatter.timeStyle = .short
    
    let result = formatter.string(from: date)
    
    print(result)
    
    return result
}

    // save note with Core Data
func save(note: String, timeAndDate: String) {
    
    guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
        return
    }
    
    // 1
    let managedContext = appDelegate.persistentContainer.viewContext
    
    // 2
    
    let entity = NSEntityDescription.entity(forEntityName: "Notes", in: managedContext)!
    
    let notes = NSManagedObject(entity: entity, insertInto: managedContext)
    
    // 3
    notes.setValue(note, forKey: "notes")
    notes.setValue(timeAndDate, forKey: "timeAndDate")
    
    // 4
    do {
        try managedContext.save()
        noteArray.append(notes)
    } catch let error as NSError {
        print("Could not save \(error), \(error.userInfo)")
    }
    
}

    //fetch request with Core Data
func fetch() {
    
    // 1
    guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
        return
    }
    
    let managedContext = appDelegate.persistentContainer.viewContext
    
    // 2
    let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "Notes")
    
    // 3
    do {
        noteArray = try
            managedContext.fetch(fetchRequest)
    } catch let error as NSError {
        print("Could not fetch. \(error), \(error.userInfo)")
    }
    
}


    //delete note with Core Data
extension ViewController {

    func delete(indexP: Int) {
    // 1
    guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
        return
    }
    
    let managedContext = appDelegate.persistentContainer.viewContext
    
    // 2
    let noteToDelete = noteArray[indexP]
    managedContext.delete(noteToDelete)
    //tableView.deleteRows(at: [indexPath], with: .fade)
    
    // 3
    do {
        try managedContext.save()
    } catch let error as NSError {
        print("Could not delete. \(error), \(error.userInfo)")
    }
    
    // to Fetch New Data From The DB and Reload Table
    let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "Notes")
    
    do {
        noteArray = try
            managedContext.fetch(fetchRequest)
    } catch let error as NSError {
        print("Could not fetch. \(error), \(error.userInfo)")
    }
    
    notesTableView.reloadData()
}
}



