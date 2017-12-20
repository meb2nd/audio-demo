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
    
    var oscillator = AKOscillator(waveform: AKTable(.sawtooth))
    var currentAmplitude = 0.1
    var currentRampTime = 0.2
    
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
        
        
        let oscMixer = AKMixer(oscillator)
        
        let reverb = AKReverb(oscMixer)
        reverb.loadFactoryPreset(.largeHall)
        reverb.dryWetMix = 0.5
        
        let tape = try! AKAudioFile()
        
        let player = try! AKAudioPlayer(file: tape)
        
        let mixer = AKMixer(player, reverb)
        AudioKit.output = mixer
        
        AudioKit.start()
        
        let recorder = try! AKNodeRecorder(node: oscMixer, file: tape)
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
    
    // Helper Functions
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
}

