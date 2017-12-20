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

class AudioRecordingTableViewCell: UITableViewCell {

    @IBOutlet weak var playButton: UIButton!
    @IBOutlet weak var audioRecordingTitleLabel: UILabel!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    @IBAction func playTapped(_ sender: Any) {
    }
}
