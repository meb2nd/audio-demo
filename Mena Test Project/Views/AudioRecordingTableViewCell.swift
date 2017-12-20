//
//  AudioRecordingTableViewCell.swift
//  Mena Test Project
//
//  Created by Pete Barnes on 12/20/17.
//  Copyright © 2017 modacity. All rights reserved.
//

import UIKit

protocol AudioRecordingCellDelegate {
    func didTapPlay(forAudioRecordingFile fileName: String, cell: AudioRecordingTableViewCell)
}

// MARK: - AudioRecordingTableViewCell

class AudioRecordingTableViewCell: UITableViewCell {

    // MARK: - Outlets
    
    @IBOutlet weak var playButton: UIButton!
    @IBOutlet weak var audioRecordingTitleLabel: UILabel!
    
    // MARK: - Properties
    
    var fileName: String?
    var delegate: AudioRecordingCellDelegate?
    
    // MARK: - Lifcycle
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    // MARK: - Selection State
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    // MARK: - Actions
    @IBAction func playTapped(_ sender: Any) {
        
        guard let fileName = fileName else {
            return
        }
        
        delegate?.didTapPlay(forAudioRecordingFile: fileName, cell: self)
    }
}
