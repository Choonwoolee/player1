//
//  DetailViewController.swift
//  player1
//
//  Created by choonlog on 2014. 11. 10..
//  Copyright (c) 2014년 choonlog. All rights reserved.
//

import UIKit
import MediaPlayer
import AVFoundation
import CoreData

class DetailViewController: UIViewController, UITableViewDelegate,UITableViewDataSource,NSFetchedResultsControllerDelegate{
    
    var managedObjectContext: NSManagedObjectContext? = nil
    
    @IBOutlet weak var detailDescriptionLabel: UILabel!
    @IBOutlet weak var audioFullTime: UILabel!
    @IBOutlet weak var playButton: UIButton!
    @IBOutlet weak var bookmarkButton: UIButton!
    @IBOutlet weak var playTime: UILabel!
    @IBOutlet weak var tableView: UITableView!

    //var player : MPMusicPlayerController = MPMusicPlayerController.applicationMusicPlayer();
    var player : AVAudioPlayer = AVAudioPlayer()
    var isPlay : Bool = false

    var detailItem: AnyObject? {
        didSet {
            // Update the view.
            self.configureView()
        }
    }
    
    

    func configureView() {
        // Update the user interface for the detail item.
        if let detail: AnyObject = self.detailItem {
            self.findAudioFromLibray()
            if let label = self.detailDescriptionLabel {
                label.text = detail.valueForKey("title")!.description
            }
        }
    }
    
    func findAudioFromLibray(){
        var audioId:AnyObject?
        if let detail: AnyObject = self.detailItem {
                audioId = detail.valueForKey("audioId")
        }
        
        println(audioId)
        
        var predicate:MPMediaPropertyPredicate = MPMediaPropertyPredicate(value:audioId, forProperty:MPMediaItemPropertyPersistentID)
        
        var songQuery:MPMediaQuery =  MPMediaQuery()
        
        
        //self.player.setQueueWithQuery(songQuery)
        var error:NSErrorPointer = NSErrorPointer()
        songQuery.addFilterPredicate( predicate);
        if (songQuery.items.count > 0)
        {
            println("find song")
            var song:MPMediaItem = songQuery.items[0] as MPMediaItem;
            self.player = AVAudioPlayer(contentsOfURL: song.valueForProperty(MPMediaItemPropertyAssetURL) as NSURL, error: error)
            
            var duration = player.duration
            print(" \(duration.hours) hours \(duration.minuteComponent) minutes \(duration.secondComponent) seconds")
            if let label = self.audioFullTime {
                audioFullTime.text = " \(duration.hours):\(duration.minuteComponent):\(duration.secondComponent)"
            }
            
        }
        
        
    }
    
    

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        self.configureView()
        var timer = NSTimer.scheduledTimerWithTimeInterval(0.5, target: self, selector: Selector("updatePlayTime"), userInfo: nil, repeats: true)
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func playButtonUp(AnyObject) {
        println("button tapped!")
        if(isPlay) {
            player.stop()
            isPlay = false
        }else{
            player.play()
            isPlay = true
            
        }
    }

    @IBAction func bookmarkButtonUp(AnyObject) {
        println("bookmark button tapped!")
        self.saveBookmark()
       
    }
    
    func saveBookmark(){
        let context = self.fetchedResultsController.managedObjectContext
        let entity = self.fetchedResultsController.fetchRequest.entity!
        let newManagedObject = NSEntityDescription.insertNewObjectForEntityForName(entity.name!, inManagedObjectContext: context) as NSManagedObject
        
        // If appropriate, configure the new managed object.
        // Normally you should use accessor methods, but using KVC here avoids the need to add a custom class to the template.
        
        println(player.currentTime)
        
        newManagedObject.setValue(player.currentTime, forKey: "second")
        
        // Save the context.
        var error: NSError? = nil
        if !context.save(&error) {
            println("Unresolved error \(error), \(error)")
        }
        
    }

    
    // MARK: - AudioPlayer
    

    func updatePlayTime(){
        var total=player.duration;
        var f = player.currentTime
        if let label = self.playTime {
            playTime.text = " \(f.hours):\(f.minuteComponent):\(f.secondComponent)"
        }
        
    }

    
    // MARK: - Table View
    
     func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return self.fetchedResultsController.sections?.count ?? 0
    }
    
     func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let sectionInfo = self.fetchedResultsController.sections![section] as NSFetchedResultsSectionInfo
        return sectionInfo.numberOfObjects
    }
    
     func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("Cell", forIndexPath: indexPath) as UITableViewCell
        self.configureCell(cell, atIndexPath: indexPath)
        return cell
    }
    
     func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    
     func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            let context = self.fetchedResultsController.managedObjectContext
            context.deleteObject(self.fetchedResultsController.objectAtIndexPath(indexPath) as NSManagedObject)
            
            var error: NSError? = nil
            if !context.save(&error) {
                // Replace this implementation with code to handle the error appropriately.
                // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                //println("Unresolved error \(error), \(error.userInfo)")
                abort()
            }
        }
    }
    
    func configureCell(cell: UITableViewCell, atIndexPath indexPath: NSIndexPath) {
        let object = self.fetchedResultsController.objectAtIndexPath(indexPath) as NSManagedObject
        cell.textLabel!.text = object.valueForKey("second")!.description
    }
    
    // MARK: - Fetched results controller
    
    var fetchedResultsController: NSFetchedResultsController {
        if _fetchedResultsController != nil {
            return _fetchedResultsController!
        }
        
        let fetchRequest = NSFetchRequest()
        // Edit the entity name as appropriate.
        let entity = NSEntityDescription.entityForName("AudioBookmark", inManagedObjectContext: self.managedObjectContext!)
        fetchRequest.entity = entity
        
        // Set the batch size to a suitable number.
        fetchRequest.fetchBatchSize = 20
        
        // Edit the sort key as appropriate.
        let sortDescriptor = NSSortDescriptor(key: "second", ascending: false)
        let sortDescriptors = [sortDescriptor]
        
        fetchRequest.sortDescriptors = [sortDescriptor]
        
        // Edit the section name key path and cache name if appropriate.
        // nil for section name key path means "no sections".
        let aFetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: self.managedObjectContext!, sectionNameKeyPath: nil, cacheName: "Master")
        aFetchedResultsController.delegate = self
        _fetchedResultsController = aFetchedResultsController
        
        var error: NSError? = nil
        if !_fetchedResultsController!.performFetch(&error) {
            // Replace this implementation with code to handle the error appropriately.
            // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
            //println("Unresolved error \(error), \(error.userInfo)")
            abort()
        }
        
        return _fetchedResultsController!
    }
    var _fetchedResultsController: NSFetchedResultsController? = nil
    
    func controllerWillChangeContent(controller: NSFetchedResultsController) {
        self.tableView.beginUpdates()
    }
    
    func controller(controller: NSFetchedResultsController, didChangeSection sectionInfo: NSFetchedResultsSectionInfo, atIndex sectionIndex: Int, forChangeType type: NSFetchedResultsChangeType) {
        switch type {
        case .Insert:
            self.tableView.insertSections(NSIndexSet(index: sectionIndex), withRowAnimation: .Fade)
        case .Delete:
            self.tableView.deleteSections(NSIndexSet(index: sectionIndex), withRowAnimation: .Fade)
        default:
            return
        }
    }
    
    func controller(controller: NSFetchedResultsController, didChangeObject anObject: AnyObject, atIndexPath indexPath: NSIndexPath?, forChangeType type: NSFetchedResultsChangeType, newIndexPath: NSIndexPath?) {
        switch type {
        case .Insert:
            tableView.insertRowsAtIndexPaths([newIndexPath!], withRowAnimation: .Fade)
        case .Delete:
            tableView.deleteRowsAtIndexPaths([indexPath!], withRowAnimation: .Fade)
        case .Update:
            self.configureCell(tableView.cellForRowAtIndexPath(indexPath!)!, atIndexPath: indexPath!)
        case .Move:
            tableView.deleteRowsAtIndexPaths([indexPath!], withRowAnimation: .Fade)
            tableView.insertRowsAtIndexPaths([newIndexPath!], withRowAnimation: .Fade)
        default:
            return
        }
    }
    
    func controllerDidChangeContent(controller: NSFetchedResultsController) {
        self.tableView.endUpdates()
    }
    
    /*
    // Implementing the above methods to update the table view in response to individual changes may have performance implications if a large number of changes are made simultaneously. If this proves to be an issue, you can instead just implement controllerDidChangeContent: which notifies the delegate that all section and object changes have been processed.
    
    func controllerDidChangeContent(controller: NSFetchedResultsController) {
    // In the simplest, most efficient, case, reload the table view.
    self.tableView.reloadData()
    }
    */
    
    
}

