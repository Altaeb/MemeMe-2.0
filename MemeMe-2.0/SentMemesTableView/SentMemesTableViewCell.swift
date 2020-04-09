//
//  SentMemesTableViewCell.swift
//  MemeMe-2.0
//
//  Created by Abdalfattah Altaeb on 4/9/20.
//  Copyright © 2020 Abdalfattah Altaeb. All rights reserved.
//

import UIKit

class SentMemesTableViewCell: UITableViewCell {

    //MARK: Properties

    @IBOutlet weak var memedImage: UIImageView!
    @IBOutlet weak var topText: UILabel!
    @IBOutlet weak var bottomText: UILabel!

    //MARK: Custom Cell's Functions

    func updateCell(_ meme: Meme) {

        //update cell's view
        memedImage.image = meme.memedImage
        topText.text = meme.topText as String?
        bottomText.text = meme.bottomText as String?
    }
}
