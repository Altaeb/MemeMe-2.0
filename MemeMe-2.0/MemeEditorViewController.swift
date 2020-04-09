//
//  MemeEditorViewController.swift
//  MemeMe-2.0
//
//  Created by Abdalfattah Altaeb on 4/9/20.
//  Copyright © 2020 Abdalfattah Altaeb. All rights reserved.
//

import UIKit

class MemeEditorViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {


    //MARK: IBoutlets

    @IBOutlet weak var imagePickerView: UIImageView!
    @IBOutlet weak var cameraButton: UIBarButtonItem!
    @IBOutlet weak var shareButton: UIBarButtonItem!
    @IBOutlet weak var topTextField: UITextField!
    @IBOutlet weak var bottomTextField: UITextField!
    @IBOutlet weak var navBar: UIToolbar!
    @IBOutlet weak var toolBar: UIToolbar!
    @IBOutlet weak var scrollView: UIScrollView!

    //MARK: Properties

    let memeData = (UIApplication.shared.delegate as!
    AppDelegate).memes


    //MARK: LifeCycle Methods

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.

        setTextFields(textField: topTextField, string: AppModel.defaultTopTextFieldText)
        setTextFields(textField: bottomTextField, string: AppModel.defaultBottomTextFieldText)
        scrollView.delegate = self;
        scrollView.backgroundColor = UIColor.black
    }


    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        //To Hide Navigation Controller & Tab Bar Controller on this Scene
        self.navigationController?.isNavigationBarHidden = true
        self.tabBarController?.tabBar.isHidden = true;

        //To set the font of the textfields if any selected
        if AppModel.currentFontIndex != -1 {

            topTextField.font = UIFont(name: AppModel.selectedFont, size: 40)
            bottomTextField.font = UIFont(name: AppModel.selectedFont, size: 40)
        }

        // if there's an image in the imageView, enable the share button
        if let _ = imagePickerView.image {
            shareButton.isEnabled = true
        } else {
            shareButton.isEnabled = false
        }

        //To enable or disable camera bar button if camera is available for use or not
        cameraButton.isEnabled = UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.camera)

        // Subscribe to keyboard notifications to allow the view to raise when necessary
        self.subscribeToKeyboardNotifications()
    }


    override func viewWillDisappear(_ animated: Bool) {

        super.viewWillDisappear(animated)
        unsubscribeFromKeyboardNotifications()
    }


    // MARK: UIImagePickerController Functions

    @IBAction func pickAnImageFromAlbum(_ sender: AnyObject) {
        //To pick an image from Photos Albums
        presentImagePickerWith(sourceType: UIImagePickerControllerSourceType.photoLibrary)
    }


    @IBAction func pickAnImageFromCamera (sender: AnyObject) {
        // To take a image directly from camera
        presentImagePickerWith(sourceType: UIImagePickerControllerSourceType.camera)
    }


    // MARK: UIImagePickerController Delegates

    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        // To select an image and set it to imageView
        if let image = info[UIImagePickerControllerOriginalImage] as? UIImage {

            imagePickerView.image = image
            self.view.layoutIfNeeded()
            setZoomScaleForImage(scrollViewSize: scrollView.bounds.size)
            scrollView.zoomScale = scrollView.minimumZoomScale
            centerImage()
            self.dismiss(animated: true, completion: nil)
        }
    }


    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        // To dismiss imagePicker when cancel button is clicked
        dismiss(animated: true, completion: nil)
    }


    // MARK: Notification Funtions

    func subscribeToKeyboardNotifications() {

        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: NSNotification.Name.UIKeyboardWillShow, object: nil)

        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: NSNotification.Name.UIKeyboardWillHide, object: nil)

    }


    func unsubscribeFromKeyboardNotifications() {

        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UIKeyboardWillShow, object: nil)

        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UIKeyboardWillHide, object: nil)
    }


    // MARK: Keyboard Related Methods and Delegates

    func keyboardWillShow(notification: NSNotification) {
        //setting frame of view when keyboard shows

        if bottomTextField.isFirstResponder {

            view.frame.origin.y = -getKeyboardHeight(notification: notification)
        }
    }


    func keyboardWillHide(notification: NSNotification) {

        view.frame.origin.y = 0
    }


    func getKeyboardHeight(notification: NSNotification) -> CGFloat {
        //getting height of keyboard for setting view's frame accordingly
        let userInfo = notification.userInfo!
        let keyboardSize = userInfo[UIKeyboardFrameEndUserInfoKey] as! NSValue // of CGRect
        return keyboardSize.cgRectValue.height
    }


    // MARK: Generating Meme Objects

    // Create a UIImage that combines the Image View and the Textfields
    func generateMemedImage() -> UIImage {

        configureBars(hidden: true)

        // render view to an image
        UIGraphicsBeginImageContext(self.view.frame.size)
        self.view.drawHierarchy(in: self.view.frame, afterScreenUpdates: true)
        let memedImage : UIImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()

        configureBars(hidden: false)

        return memedImage
    }


    func save(memedImage: UIImage) {

        let meme = Meme(topText: topTextField.text! as NSString!, bottomText: bottomTextField.text! as NSString!,  image: imagePickerView.image, memedImage: memedImage)

        // Add it to the memes array in the Application Delegate
        (UIApplication.shared.delegate as!
            AppDelegate).memes.append(meme)
    }


    //MARK: Top Bar Button Actions

    @IBAction func shareAction(_ sender: AnyObject) {

        let memedImage = generateMemedImage()

        let shareActivityViewController = UIActivityViewController(activityItems: [memedImage], applicationActivities: nil)

        shareActivityViewController.completionWithItemsHandler = { activity, completed, items, error in

            if completed {

                //save the image
                self.save(memedImage: memedImage)

                //Dismiss the shareActivityViewController
                self.dismiss(animated: true, completion: nil)

                //Unwind to SentMemeTableView
                self.performSegue(withIdentifier: AppModel.memeEditorSegueIdentifier, sender: nil)

            }

        }

        present(shareActivityViewController, animated: true, completion: nil)
    }


    @IBAction func cancelAction(_ sender: AnyObject) {


        let alert = UIAlertController(title: AppModel.alert.alertTitle , message: AppModel.alert.alertMessage, preferredStyle: .actionSheet)

        let clear = UIAlertAction(title: "Clear Meme Editor", style: .destructive) { (UIAlertAction) in

            self.imagePickerView.image = nil
            self.resetTextfieldText()
            self.shareButton.isEnabled = false
        }

        let dismiss = UIAlertAction(title: "Dismiss Meme Editor", style: .destructive, handler: { (UIAlertAction) in

            self.dismiss(animated: true, completion: nil)
        })

        let cancel = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)


        alert.addAction(clear)
        alert.addAction(dismiss)
        alert.addAction(cancel)

        self.present(alert, animated: true, completion: nil)
    }


    //MARK: Helper Functions

    override func viewWillLayoutSubviews() {

        self.view.layoutIfNeeded()

        setZoomScaleForImage(scrollViewSize: scrollView.bounds.size)

        if scrollView.zoomScale < scrollView.minimumZoomScale || scrollView.zoomScale == 1{

            scrollView.zoomScale = scrollView.minimumZoomScale
        }

        centerImage()

    }


    func presentImagePickerWith(sourceType: UIImagePickerControllerSourceType){

        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.sourceType = sourceType
        self.present(imagePicker, animated: true, completion:nil)
    }


    func resetTextfieldText(){

        topTextField.text = AppModel.defaultTopTextFieldText
        bottomTextField.text = AppModel.defaultBottomTextFieldText
    }


    func configureBars(hidden: Bool) {

        navBar.isHidden = hidden
        toolBar.isHidden = hidden
    }


    override var prefersStatusBarHidden: Bool {
        //Hide Status Bar
        return true
    }


    //MARK: Pop Animation

    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {

        super.viewWillTransition(to: size, with: coordinator)

        coordinator.animate(alongsideTransition: { (UIViewControllerTransitionCoordinatorContext) in

            self.topTextField.transform = CGAffineTransform(scaleX: 1.2, y: 1.2)
            self.bottomTextField.transform = CGAffineTransform(scaleX: 1.2, y: 1.2)

        }) { (UIViewControllerTransitionCoordinatorContext) in

            UIView.animate(withDuration: 0.5, animations: {

                self.topTextField.transform = CGAffineTransform.identity
                self.bottomTextField.transform = CGAffineTransform.identity

            })
        }
    }


    @IBAction func setFont(_ sender: AnyObject) {

        self.performSegue(withIdentifier: AppModel.fontsTableViewSegueIdentifier, sender: nil)
    }
}


extension MemeEditorViewController: UITextFieldDelegate {

    //MARK: UITextField Extention

    func setTextFields(textField: UITextField, string: String) {

        //set textview's default behaviour
        textField.defaultTextAttributes = AppModel.memeTextAttributes
        textField.text = string
        textField.textAlignment = NSTextAlignment.center
        textField.delegate = self;
    }


    func textFieldDidBeginEditing(_ textField: UITextField) {

        //Erase the default text when editing
        if textField == topTextField && textField.text == AppModel.defaultTopTextFieldText {

            textField.text = ""

        } else if textField == bottomTextField && textField.text == AppModel.defaultBottomTextFieldText {

            textField.text = ""
        }
    }


    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {

        var text = textField.text as NSString?
        text = text!.replacingCharacters(in: range, with: string) as NSString?

        //to ensure capitalization works even if someone pastes text
        textField.text = text?.uppercased
        return false
    }


    func textFieldShouldReturn(_ textField: UITextField) -> Bool {

        //Allows the user to use the return key to hide keyboard
        textField.resignFirstResponder()
        return true
    }


    func textFieldDidEndEditing(_ textField: UITextField) {

        //To set default text if textfields text is empty
        if textField == topTextField && textField.text!.isEmpty {

            textField.text = AppModel.defaultTopTextFieldText;

        }else if textField == bottomTextField && textField.text!.isEmpty {

            textField.text = AppModel.defaultBottomTextFieldText;
        }
    }
}


extension MemeEditorViewController: UIScrollViewDelegate {

    //MARK: UIScrollView Extention

    func viewForZooming(in scrollView: UIScrollView) -> UIView? {

        return imagePickerView
    }


    func scrollViewDidZoom(_ scrollView: UIScrollView) {

        centerImage()
    }


    //MARK: Set Zoom Scale

    func setZoomScaleForImage(scrollViewSize: CGSize) {

        if let image = imagePickerView.image {

            let imageSize = image.size

            let widthScale = scrollViewSize.width / imageSize.width
            let heightScale = scrollViewSize.height / imageSize.height

            //this will help for both potrait and landscape oriented images
            let minScale = min(widthScale, heightScale)

            scrollView.minimumZoomScale = minScale
            scrollView.maximumZoomScale = 3.0
        }
    }


    //MARK: Center Image

    func centerImage() {

        if imagePickerView.image != nil {

            let scrollViewSize = scrollView.bounds.size
            let imageSize = imagePickerView.frame.size

            let horizontalSpace = imageSize.width < scrollViewSize.width ? (scrollViewSize.width - imageSize.width) / 2 : 0
            let verticalSpace = imageSize.height < scrollViewSize.height ? (scrollViewSize.height - imageSize.height) / 2 : 0

            scrollView.contentInset = UIEdgeInsets(top: verticalSpace, left: horizontalSpace, bottom: verticalSpace, right: horizontalSpace)
        }
    }

}
