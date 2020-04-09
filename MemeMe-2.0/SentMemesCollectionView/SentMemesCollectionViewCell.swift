//
//  SentMemesCollectionViewCell.swift
//  MemeMe-2.0
//
//  Created by Abdalfattah Altaeb on 4/9/20.
//  Copyright © 2020 Abdalfattah Altaeb. All rights reserved.
//

import UIKit

class SentMemesCollectionViewCell: UICollectionViewCell {

    //MARK: Outlets

    @IBOutlet weak var memedImage: UIImageView!

    //MARK: Custom Cell's Functions

    func updateCell(_ meme: Meme) {

        //update cell's view
        memedImage.image = meme.memedImage
    }
}
