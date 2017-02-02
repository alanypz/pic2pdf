//
//  ViewController.swift
//  Converter
//
//  Created by Alan Yepez on 11/8/15.
//  Copyright © 2015 alanypz. All rights reserved.
//

import UIKit
import QuickLook

//  Class which interfaces between the UI and the Model (PDF class). Represents the View.
class CollectionViewController: UICollectionViewController {
    
    @IBOutlet weak var previewBarButton: UIBarButtonItem!
    
    @IBOutlet weak var shareBarButton: UIBarButtonItem!

    @IBOutlet weak var trashBarButton: UIBarButtonItem!

    @IBOutlet weak var contentModeBarButton: UIBarButtonItem!

    //  Instance of PDF class.
    let pdf = PDF()
    
    // Set collection view grid and optimize for iPhone.
    override func viewDidLoad() {
        
        super.viewDidLoad()
                
        if let flowLayout = collectionView?.collectionViewLayout as? CollectionViewFlowLayout {
            
            flowLayout.minimumInteritemSpacing = 1
            
            flowLayout.minimumLineSpacing = 1
            
            switch traitCollection.userInterfaceIdiom {
            
            case .Phone:
                
                let length = (view.frame.width - 3) / 4
                
                flowLayout.itemSize = CGSize(width: length, height: length)
                
            default:
                
                flowLayout.itemSize = CGSize(width: 120, height: 120)
            
            }
            
        }
        
    }
    
    // MARK:- Navigation
    
    //  Export/share icon for main view.
    @IBAction func share(sender: UIBarButtonItem) {
        
        if !pdf.isRendered {
            
            pdf.render()
            
        }
        
        let activity = UIActivityViewController(activityItems: [pdf.previewItemURL], applicationActivities: nil)
        
        activity.completionWithItemsHandler = { (activityType, completed, returnedItems, activityError) in
        
        }
        
        presentViewController(activity, animated: true, completion: nil)
        
    }
    
    //  Preview button in main view. Reponsible for calling render() in PDF.
    @IBAction func preview(sender: UIBarButtonItem) {
        
        if !pdf.isRendered {
        
            pdf.render()
        
        }
        
        let preview = QLPreviewController()
        
        preview.dataSource = self
        
        preview.delegate = self
        
        presentViewController(preview, animated: true, completion: nil)
        
    }
    
    //  Removes any PDF files in pdf object. Resets view collection grid.
    @IBAction func trash(sender: UIBarButtonItem) {
    
        let count = pdf.numberOfImages
        
        pdf.reset()
        
        collectionView?.performBatchUpdates({
            
            for index in 0..<count {
            
                self.collectionView?.deleteItemsAtIndexPaths([NSIndexPath(forItem: index, inSection: 0)])
            
            }
            
            }, completion: nil)
        
        // Disable icons which require presence of images.
        self.previewBarButton.enabled = false
        
        self.shareBarButton.enabled = false
        
        self.trashBarButton.enabled = false
    
    }
    
    // MARK: - Collection View Data Source
    
    // Prevent movement of "+" object in collection view.
    override func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        return pdf.numberOfImages + 1
        
    }
    
    override func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        
        if indexPath.item == pdf.numberOfImages {
            
            return collectionView.dequeueReusableCellWithReuseIdentifier("Add", forIndexPath: indexPath)
            
        }
            
        else {
            
            let cell = collectionView.dequeueReusableCellWithReuseIdentifier("Cell", forIndexPath: indexPath) as! CollectionViewCell
            
            cell.imageView.image = pdf[indexPath.item]
            
            return cell
            
        }
        
    }
    
    //  Disallow re-ordering images in collection view if it involves moving "+" object.
    override func collectionView(collectionView: UICollectionView, canMoveItemAtIndexPath indexPath: NSIndexPath) -> Bool {
        
        return indexPath.item != pdf.images.count
        
    }
    
    override func collectionView(collectionView: UICollectionView, moveItemAtIndexPath sourceIndexPath: NSIndexPath, toIndexPath destinationIndexPath: NSIndexPath) {
        
        pdf.moveImage(moveImageAtIndex: sourceIndexPath.item, toIndex: destinationIndexPath.item)
        
    }
    
    // MARK: - Collection View Delegate
    
    // Move order of images in collection view.
    override func collectionView(collectionView: UICollectionView, targetIndexPathForMoveFromItemAtIndexPath originalIndexPath: NSIndexPath, toProposedIndexPath proposedIndexPath: NSIndexPath) -> NSIndexPath {
    
       return proposedIndexPath.item == pdf.numberOfImages ? originalIndexPath : proposedIndexPath

    }

    override func collectionView(collectionView: UICollectionView, shouldSelectItemAtIndexPath indexPath: NSIndexPath) -> Bool {
        
        return indexPath.item == pdf.images.count
        
    }
    
    //  Check for presence of Camera and Photo Library on selecting "+".
    override func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        
        let controller = UIAlertController(title: "Select Source", message: "Either Camera or Photo Library", preferredStyle: .ActionSheet)
        
        let cell = collectionView.cellForItemAtIndexPath(indexPath)!
        
        controller.popoverPresentationController?.sourceView = cell
        
        controller.popoverPresentationController?.sourceRect = cell.frame
        
        if UIImagePickerController.isSourceTypeAvailable(.Camera) {
            
            controller.addAction(UIAlertAction(title: "Camera", style: .Default) { (action) in
                
                self.showCamera()
                
                })
            
        }
        
        if UIImagePickerController.isSourceTypeAvailable(.PhotoLibrary) {
            
            controller.addAction(UIAlertAction(title: "Library", style: .Default) { (action) in
                
                self.showPhotoLibrary()
                
                })
            
        }
        
        controller.addAction(UIAlertAction(title: "Cancel", style: .Cancel, handler: nil))
        
        presentViewController(controller, animated: true, completion: nil)
        
    }
    
    // Launch camera.
    private func showCamera() {
        
        let picker = UIImagePickerController()
        
        picker.allowsEditing = false
        
        picker.delegate = self
        
        picker.sourceType = .Camera
        
        presentViewController(picker, animated: true, completion: nil)
        
    }
    
    // Launch photo library.
    private func showPhotoLibrary() {
        
        let picker = UIImagePickerController()
        
        picker.allowsEditing = false
        
        picker.delegate = self
        
        picker.modalPresentationStyle = .FormSheet
        
        picker.sourceType = .PhotoLibrary
        
        presentViewController(picker, animated: true, completion: nil)
        
    }
    
}

//MARK:- Image Picker Controller Delegate

// Verify addition of images and enable icons if appropriate.
extension CollectionViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {
        
        dismissViewControllerAnimated(true) {
            
            guard let image = info[UIImagePickerControllerOriginalImage] as? UIImage else { return }
            
            let indexPath = NSIndexPath(forItem: self.pdf.numberOfImages, inSection: 0)
            
            self.pdf.appendImage(image)
            
            self.previewBarButton.enabled = true
            
            self.shareBarButton.enabled = true
            
            self.trashBarButton.enabled = true
            
            self.collectionView?.performBatchUpdates({
                
                self.collectionView?.insertItemsAtIndexPaths([indexPath])
                
                }, completion: nil)
            
        }
        
    }
    
}

//MARK:- Preview Controller Data Source

extension CollectionViewController: QLPreviewControllerDataSource {

    func numberOfPreviewItemsInPreviewController(controller: QLPreviewController) -> Int {
        
        return 1
        
    }
    
    func previewController(controller: QLPreviewController, previewItemAtIndex index: Int) -> QLPreviewItem {
        
        return pdf
        
    }
    
}

//MARK:- Preview Controller Delegate

extension CollectionViewController: QLPreviewControllerDelegate {

}
