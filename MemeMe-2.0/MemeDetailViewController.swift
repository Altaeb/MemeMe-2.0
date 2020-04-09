//
//  MemeDetailViewController.swift
//  MemeMe-2.0
//
//  Created by Abdalfattah Altaeb on 4/9/20.
//  Copyright © 2020 Abdalfattah Altaeb. All rights reserved.
//

import UIKit

class MemeDetailViewController: UIViewController {

    //MARK: Outlets & Properties

    @IBOutlet weak var memedImage: UIImageView!
    var meme: Meme! = nil

    //MARK: LifeCycle Methods

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        //Hide Tab Bar Controller Here
        tabBarController?.tabBar.isHidden = true

        //Set the memed Image to show
        memedImage.image = meme.memedImage
    }
}
