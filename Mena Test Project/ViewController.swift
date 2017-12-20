//
//  ViewController.swift
//  Mena Test Project
//
//  Created by Marc Gelfo on 12/16/17.
//  Copyright © 2017 modacity. All rights reserved.
//

import UIKit
import AudioKitUI

enum PianoKey: Int {
    case C4
    case CS4
    case D4
    case DS4
    case E4
    case F4
    case FS4
    case G4
    case GS4
    case A4
    case AS4
    case B4
    case C5
}

class ViewController: UIViewController {
    
    @IBOutlet weak var cButton: UIButton!
    @IBOutlet weak var cSharpButton: UIButton!
    @IBOutlet weak var dButton: UIButton!
    @IBOutlet weak var dSharpButton: UIButton!
    @IBOutlet weak var eButton: UIButton!
    @IBOutlet weak var fButton: UIButton!
    @IBOutlet weak var fSharpButton: UIButton!
    @IBOutlet weak var gButton: UIButton!
    @IBOutlet weak var gSharpButton: UIButton!
    @IBOutlet weak var aButton: UIButton!
    @IBOutlet weak var aSharpButton: UIButton!
    @IBOutlet weak var bButton: UIButton!
    @IBOutlet weak var highCButton: UIButton!
    @IBOutlet weak var recordAudioButton: UIButton!
    @IBOutlet weak var audioRecordingsTableView: UITableView!
    
    var oscillator = AKOscillator(waveform: AKTable(.sawtooth))
    var currentAmplitude = 0.1
    var currentRampTime = 0.2
    var recorder: AKNodeRecorder!
    var player: AKAudioPlayer!
    var activePlaybackIndexPath: IndexPath?
    var recordings = [Recording]()
    var tape: AKAudioFile?
    
    var frequencies = [PianoKey.C4: 261.626,
                 PianoKey.CS4: 277.183,
                 PianoKey.D4: 293.665,
                 PianoKey.DS4: 311.127,
                 PianoKey.E4: 329.628,
                 PianoKey.F4: 349.228,
                 PianoKey.FS4: 369.994,
                 PianoKey.G4: 391.995,
                 PianoKey.GS4: 415.305,
                 PianoKey.A4: 440.000,
                 PianoKey.AS4: 466.164,
                 PianoKey.B4: 493.883,
                 PianoKey.C5: 523.251]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        audioRecordingsTableView.delegate = self
        audioRecordingsTableView.dataSource = self
        
        let oscMixer = AKMixer(oscillator)
        
        let reverb = AKReverb(oscMixer)
        reverb.loadFactoryPreset(.largeHall)
        reverb.dryWetMix = 0.5
        
        do {
            
            tape = try AKAudioFile()
            
            player = try AKAudioPlayer(file: tape!)
            
            let mixer = AKMixer(player, reverb)
            AudioKit.output = mixer
            
            AudioKit.start()
            
            recorder = try AKNodeRecorder(node: oscMixer, file: tape)
            
        } catch let error as NSError {
            print("There's an error: \(error)")
        }
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


    @IBAction func keyTouchUp(_ sender: Any) {
        noteOff()
    }
    
    @IBAction func keyTouchDown(_ sender: UIButton) {
        noteOn(note: PianoKey(rawValue: sender.tag) ?? PianoKey.C4)
    }
    
    // Record Functions
    @IBAction func toggleRecorder(_ sender: Any) {
        if recorder.isRecording {
            recorder.stop()
            recordAudioButton.setTitle("Record Audio", for: .normal)
            let fileName = "Audio_Recording_\(Recordings.getSavedRecordings().count + 1)"
            tape?.exportAsynchronously(name: fileName, baseDir: .documents, exportFormat: .mp4, callback: callback)
            
        } else {
            
            do {
                try recorder.record()
            } catch {
                AKLog("Couldn't record")
            }
            recordAudioButton.setTitle("Done", for: .normal)
        }
    }
    
    // Keyboard Functions
    func noteOn(note: PianoKey) {
        
        // start from the correct note if amplitude is zero
        if oscillator.amplitude == 0 {
            oscillator.rampTime = 0
        }
        oscillator.frequency = frequencies[note] ?? 0
        
        // Still use rampTime for volume
        oscillator.rampTime = currentRampTime
        oscillator.amplitude = currentAmplitude
        oscillator.play()
    }
    
    func noteOff() {
        oscillator.amplitude = 0
    }
    
    // Playback Functions
    func callback(processedFile: AKAudioFile?, error: NSError?) {
        print("Export completed!")
        
        // Check if processed file is valid (different from nil)
        if let converted = processedFile {
            print("Export succeeded, converted file: \(converted.fileNamePlusExtension)")
            // Print the exported file's duration
            print("Exported File Duration: \(converted.duration) seconds")
            
            performUIUpdatesOnMain {
                
                // Replace the file being played
                try? self.player.replace(file: converted)
                let newTitle = "Audio Recording \(Recordings.getSavedRecordings().count + 1)"
                let newRecording = Recording(title: newTitle, fileName: converted.fileNamePlusExtension)
                Recordings.addToSavedRecordings(recording: newRecording)
                self.audioRecordingsTableView.reloadData()
                
                // Clear the recorder
                do {
                    try self.recorder.reset()
                } catch {
                    AKLog("Couldn't reset.")
                }
            }
            
            
        } else {
            // An error occured. So, print the Error
            print("Error: \(String(describing: error?.localizedDescription))")
        }
    }
}

extension ViewController: UITableViewDelegate {
    
}

extension ViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return Recordings.getSavedRecordings().count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "AudioRecordingTableViewCell", for: indexPath) as! AudioRecordingTableViewCell
        
        cell.audioRecordingTitleLabel.text = Recordings.getSavedRecordings()[indexPath.row].title
        cell.fileName = Recordings.getSavedRecordings()[indexPath.row].fileName
        cell.delegate = self
        
        return cell
    }
    
}

extension ViewController: AudioRecordingCellDelegate {
    
    fileprivate func startPlayer(_ cell: AudioRecordingTableViewCell) {
        // If the tape is not empty, we can play it !...
        if player.audioFile.duration > 0 {
            player.completionHandler = self.playbackComplete
            player.play()
            cell.playButton.setTitle("Stop", for: .normal)
            activePlaybackIndexPath = audioRecordingsTableView.indexPath(for: cell)
        }
    }
    
    fileprivate func stopPlayer(_ cell: AudioRecordingTableViewCell) {
        player.stop()
        cell.playButton.setTitle("Play", for: .normal)
        activePlaybackIndexPath = nil
    }
    
    fileprivate func play(_ fileName: String, _ cell: AudioRecordingTableViewCell) {
        
        do {
            let akAudioFile = try AKAudioFile(readFileName: fileName, baseDir: .documents)
            try player.replace(file: akAudioFile)
            startPlayer(cell)
        } catch let error as NSError {
            print("There's an error: \(error)")
        }
    }
    
    func didTapPlay(forAudioRecordingFile fileName: String, cell: AudioRecordingTableViewCell) {
        
        var activePlaybackCell: AudioRecordingTableViewCell?
        
        // If playback cell active, confirm whether it's still visible
        if let indexPath = activePlaybackIndexPath,
            let cell = self.audioRecordingsTableView.cellForRow(at: indexPath)
            as? AudioRecordingTableViewCell {
            activePlaybackCell = cell
        }
        
        if cell == activePlaybackCell,
            player.isPlaying {
            stopPlayer(cell)
        } else if cell == activePlaybackCell,
            !player.isPlaying {
            
            do {
                try player.reloadFile()
            } catch {
                AKLog("Couldn't reload file.")
            }
            startPlayer(cell)
        } else if let activePlaybackCell = activePlaybackCell,
            player.isPlaying {
            stopPlayer(activePlaybackCell)
            
            repeat {
                //statements
            } while player.isPlaying
            
            play(fileName, cell)
        } else {
            if player.isPlaying {player.stop()}
            play(fileName, cell)
        }

    }
    
    func playbackComplete() {

        if let indexPath = activePlaybackIndexPath,
            let cell = self.audioRecordingsTableView.cellForRow(at: indexPath)
                as? AudioRecordingTableViewCell {
            cell.playButton.setTitle("Play", for: .normal)
            activePlaybackIndexPath = nil
        }
    }
    
    
}
