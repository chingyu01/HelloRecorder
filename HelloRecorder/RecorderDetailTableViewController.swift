//
//  RecorderDetailTableViewController.swift
//  HelloRecorder
//
//  Created by 胡靜諭 on 2018/1/30.
//  Copyright © 2018年 胡靜諭. All rights reserved.
//

import UIKit
import AVFoundation
let reuseIdentifier = "recordingCell"

class RecorderDetailTableViewController: UITableViewController {
  
    
   var recordings = [URL]()
   var player: AVAudioPlayer!
        
        override func viewDidLoad() {
            super.viewDidLoad()
            
            listRecordings()
            
            let recognizer = UILongPressGestureRecognizer(target: self, action: #selector(RecorderDetailTableViewController.longPress(_:)))
            recognizer.minimumPressDuration = 0.5 //seconds
            recognizer.delegate = self as! UIGestureRecognizerDelegate
            recognizer.delaysTouchesBegan = true
            self.tableView?.addGestureRecognizer(recognizer)
            
            let doubleTap = UITapGestureRecognizer(target: self, action: #selector(RecorderDetailTableViewController.doubleTap(_:)))
            doubleTap.numberOfTapsRequired = 2
            doubleTap.numberOfTouchesRequired = 1
            doubleTap.delaysTouchesBegan = true
            self.tableView?.addGestureRecognizer(doubleTap)
        }
        
        @objc func doubleTap(_ rec: UITapGestureRecognizer) {
            if rec.state != .ended {
                return
            }
            
            let p = rec.location(in: self.tableView)
            if let indexPath = self.tableView?.indexPathForRow(at: p) {
                askToRename(indexPath.row)
            }
            
        }
        
        @objc func longPress(_ rec: UILongPressGestureRecognizer) {
            if rec.state != .ended {
                return
            }
            let p = rec.location(in: self.tableView)
            if let indexPath = self.tableView?.indexPathForRow(at: p) {
                askToDelete(indexPath.row)
            }
            
        }
        
        override func didReceiveMemoryWarning() {
            super.didReceiveMemoryWarning()
            // Dispose of any resources that can be recreated.
        }
        
        
        // MARK: UICollectionViewDataSource
        
        override func numberOfSections(in tableView: UITableView) -> Int {
            return 1
        }
        
        
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
            return self.recordings.count
        }
        
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
            
        if let cell = tableView.dequeueReusableCell(withIdentifier: reuseIdentifier, for: indexPath) as? RecorderDetailTableViewCell {
                
                cell.label.text = recordings[indexPath.row].lastPathComponent
                
                return cell
            }
            
            return UITableViewCell()
        }
        
        
        // MARK: UICollectionViewDelegate
        
    override func tableView(_ tableView: UITableView, shouldHighlightRowAt indexPath: IndexPath) -> Bool {
            return true
        }
        
        
//    override func tableView(_ tableView: UITableView, shouldHighlightRowAt indexPath: IndexPath) -> Bool {
//            return true
//        }
    
    override func tableView(_ tableView: UITableView, accessoryButtonTappedForRowWith indexPath: IndexPath) {
            
            print("selected \(recordings[(indexPath as NSIndexPath).row].lastPathComponent)")
            
            //var cell = collectionView.cellForItemAtIndexPath(indexPath)
            play(recordings[indexPath.row])
            
        }
        
        func play(_ url: URL) {
            print("playing \(url)")
            
            do {
                self.player = try AVAudioPlayer(contentsOf: url)
                player.prepareToPlay()
                player.volume = 1.0
                player.play()
            } catch {
                self.player = nil
                print(error.localizedDescription)
                print("AVAudioPlayer init failed")
            }
            
        }
        
        func listRecordings() {
            
            let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
            do {
                let urls = try FileManager.default.contentsOfDirectory(at: documentsDirectory,
                                                                       includingPropertiesForKeys: nil,
                                                                       options: FileManager.DirectoryEnumerationOptions.skipsHiddenFiles)
                self.recordings = urls.filter({ (name: URL) -> Bool in
                    return name.pathExtension == "m4a"
                })
            } catch {
                print(error.localizedDescription)
                print("something went wrong listing recordings")
            }
            
        }
        
        func askToDelete(_ row: Int) {
            let alert = UIAlertController(title: "Delete",
                                          message: "Delete Recording \(recordings[row].lastPathComponent)?",
                preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Yes", style: .default, handler: {_ in
                print("yes was tapped \(self.recordings[row])")
                self.deleteRecording(self.recordings[row])
            }))
            alert.addAction(UIAlertAction(title: "No", style: .default, handler: {_ in
                print("no was tapped")
            }))
            self.present(alert, animated: true, completion: nil)
        }
        
        func askToRename(_ row: Int) {
            let recording = self.recordings[row]
            
            let alert = UIAlertController(title: "Rename",
                                          message: "Rename Recording \(recording.lastPathComponent)?",
                preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Yes", style: .default, handler: {
                [unowned alert] _ in
                print("yes was tapped \(self.recordings[row])")
                if let textFields = alert.textFields {
                    let tfa = textFields as [UITextField]
                    let text = tfa[0].text
                    let url = URL(fileURLWithPath: text!)
                    self.renameRecording(recording, to: url)
                }
            }))
            alert.addAction(UIAlertAction(title: "No", style: .default, handler: {_ in
                print("no was tapped")
            }))
            alert.addTextField(configurationHandler: {textfield in
                textfield.placeholder = "Enter a filename"
                textfield.text = "\(recording.lastPathComponent)"
            })
            self.present(alert, animated: true, completion: nil)
        }
        
        func renameRecording(_ from: URL, to: URL) {
            let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
            let toURL = documentsDirectory.appendingPathComponent(to.lastPathComponent)
            
            print("renaming file \(from.absoluteString) to \(to) url \(toURL)")
            let fileManager = FileManager.default
            fileManager.delegate = self as! FileManagerDelegate
            do {
                try FileManager.default.moveItem(at: from, to: toURL)
            } catch {
                print(error.localizedDescription)
                print("error renaming recording")
            }
            DispatchQueue.main.async {
                self.listRecordings()
                self.tableView?.reloadData()
            }
        }
        
        func deleteRecording(_ url: URL) {
            
            print("removing file at \(url.absoluteString)")
            let fileManager = FileManager.default
            
            do {
                try fileManager.removeItem(at: url)
            } catch {
                print(error.localizedDescription)
                print("error deleting recording")
            }
            
            DispatchQueue.main.async {
                self.listRecordings()
                self.tableView?.reloadData()
            }
        }
    }
    
    
    extension RecorderDetailTableViewController: FileManagerDelegate {
        
        func fileManager(_ fileManager: FileManager, shouldMoveItemAt srcURL: URL, to dstURL: URL) -> Bool {
            
            print("should move \(srcURL) to \(dstURL)")
            return true
        }
        
    }
    
    extension RecorderDetailTableViewController: UIGestureRecognizerDelegate {
        
}

