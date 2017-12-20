//
//  Recordings.swift
//  Mena Test Project
//
//  Created by Pete Barnes on 12/20/17.
//  Copyright © 2017 Pete Barnes. All rights reserved.
//

import UIKit

// MARK: - Recordings
class Recordings: NSObject {

    
    // Convenience method to save a recording
    static func addToSavedRecordings(recording: Recording) {
        
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        appDelegate.recordings.append(recording)
    }
    
    // Convenience method to get copy of the saved recordings
    static func getSavedRecordings() -> [Recording] {
        
        return (UIApplication.shared.delegate as! AppDelegate).recordings
    }
    
    // Convenience method to remove recording from saved collection
    static func removeAtIndex(_ index: Int) {
        
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let recordings = appDelegate.recordings
        
        if recordings.indices.contains(index) {
            appDelegate.recordings.remove(at: index)
        }
        
    }
    
    // Convenience method to retrieve recording from saved collection
    static func getRecordingAtIndex(_ index: Int) -> Recording? {
        
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let recordings = appDelegate.recordings
        
        return recordings.indices.contains(index) ? recordings[index] : nil
    }
}
