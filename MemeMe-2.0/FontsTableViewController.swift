//
//  FontsTableViewController.swift
//  MemeMe-2.0
//
//  Created by Abdalfattah Altaeb on 4/9/20.
//  Copyright © 2020 Abdalfattah Altaeb. All rights reserved.
//

import UIKit

class FontsTableViewController: UITableViewController {

    //MARK: Properties

    let fontData = AppModel.fontsAvailable

    //MARK: LifeCycle Methods

    override func viewDidLoad() {

        let done = UIBarButtonItem.init(barButtonSystemItem: .done, target: self, action: #selector(dismissViewController))
        navigationItem.leftBarButtonItem = done
    }

    override func viewWillAppear(_ animated: Bool) {
        navigationController?.isNavigationBarHidden = false
    }

    // MARK: - Table view data source

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {

        return fontData.count
    }

    //MARK: Table View Delegates

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {


        let cell = tableView.dequeueReusableCell(withIdentifier: AppModel.fontsCellReuseIdentifier, for: indexPath)

        cell.textLabel?.text = fontData[indexPath.row]
        cell.textLabel?.font = UIFont(name: fontData[indexPath.row], size: 20)

        if indexPath.row == AppModel.currentFontIndex {

            cell.accessoryType = .checkmark

        } else {

            cell.accessoryType = .none
        }

        return cell
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {

        AppModel.currentFontIndex = indexPath.row
        AppModel.selectedFont = fontData[indexPath.row]
        tableView.reloadData()

    }

    @objc func dismissViewController() {

        dismiss(animated: true, completion: nil)
    }

}
