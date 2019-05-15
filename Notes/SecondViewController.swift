//
//  SecondViewController.swift
//  Notes
//
//  Created by fo_0x on 08.05.2019.
//  Copyright © 2019 fo_0x. All rights reserved.
//

import UIKit
import CoreData

class SecondViewController: UIViewController {

    let notesTextView = UITextView()
        
    var isTableEditing = false
    
    var indexRow: Int!
    
    var changeBarButton: Bool = false
    
    var activityViewController: UIActivityViewController? = nil
    

    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        functionOfBarButton()
        
        createTextView()
        
        NotificationCenter.default.addObserver(self, selector: #selector(updateTextView(param:)), name: UIResponder.keyboardDidShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(updateTextView(param:)), name: UIResponder.keyboardWillHideNotification, object: nil)
        
        

    }
    
    //save new notes, action to right bar button
    @objc func saveRightBarButton(sender: UIBarButtonItem) {
        if notesTextView.text.isEmpty {
            print("field empty")
        } else {
            save(note: notesTextView.text, timeAndDate: time())
            print(noteArray)
            
            
        }
    }
    
    //edit and save old notes, actiont to right bar button
    @objc func notesEditAndSaveRightBarButton(sender: UIBarButtonItem) {
        
        if self.isTableEditing {
            self.isTableEditing = false
            sender.title = "Edit"
            if notesTextView.text == (noteArray[indexRow].value(forKey: "notes") as? String)! {
                print("value not edit")
            }
            notesTextView.isEditable = false
            print(noteArray)
            
            
        } else {
            self.isTableEditing = true
            sender.title = "Save"
            notesTextView.isEditable = true
        }
    }
   
    //create text view on board
    func createTextView() {
        notesTextView.frame = view.bounds
        view.addSubview(notesTextView)
    }
    
    //to hide keyboard
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        notesTextView.resignFirstResponder()
    }
    
    //transfer notes from row in first VC to text view
    func customIndex(indexRow: Int, textNotes: String) {
        self.indexRow = indexRow
        self.notesTextView.text = textNotes
    }
    
    //change action and name of right bar button
    func functionOfBarButton() {
        
        if changeBarButton {
            title = "Add new note"
            navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Save", style: .plain, target: self, action: #selector(saveRightBarButton(sender:)))

        } else {
            title = "Detail of note"
            notesTextView.isEditable = false
            
            let sharedRightBarButton = UIBarButtonItem(barButtonSystemItem: .action, target: self, action: #selector(sharedText(sender:)))
            let editAndSaveRightBarButton = UIBarButtonItem(title: "Edit", style: .plain, target: self, action: #selector(notesEditAndSaveRightBarButton(sender:)))
            navigationItem.rightBarButtonItems = [editAndSaveRightBarButton, sharedRightBarButton]
        }
        
    }
    
    //scrolling the keyboard relative to the input text
    @objc func updateTextView(param: Notification) {
        let userInfo = param.userInfo
        
        let getKeybordRect = (userInfo![UIResponder.keyboardFrameEndUserInfoKey] as! NSValue).cgRectValue
        let keyboardFrame = self.view.convert(getKeybordRect, to: view.window)
        
        if param.name == UIResponder.keyboardWillHideNotification {
            notesTextView.contentInset = UIEdgeInsets.zero
        } else {
            notesTextView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: keyboardFrame.height, right: 0)
            notesTextView.scrollIndicatorInsets = notesTextView.contentInset
        }
        notesTextView.scrollRangeToVisible(notesTextView.selectedRange)
    }
    
    //action for shared text with activity view controller
    @objc func sharedText(sender: UIBarButtonItem) {
        
        if notesTextView.text.isEmpty {
            let alertController = UIAlertController(title: nil, message: "First enter text", preferredStyle: .alert)
            let action = UIAlertAction(title: "ok", style: .cancel, handler: nil)
            
            alertController.addAction(action)
            present(alertController, animated: true, completion: nil)
        }
        activityViewController = UIActivityViewController(activityItems: [notesTextView.text ?? "nil"], applicationActivities: nil)
        present(activityViewController!, animated: true, completion: nil)
    }
   
}
    

