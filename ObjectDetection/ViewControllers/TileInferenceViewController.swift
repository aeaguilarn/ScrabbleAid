//
//  TileInferenceViewController.swift
//  ObjectDetection
//
//  Created by Andrés Aguilar on 5/25/20.
//  Copyright © 2020 Y Media Labs. All rights reserved.
//

import UIKit
import Vision
import MLKit

class TileInferenceViewController: UIViewController {

    @IBOutlet weak var locationBox: UIImageView!
    @IBOutlet weak var scannedBoardImageView: UIImageView!
    @IBOutlet weak var selectedCellImageView: UIImageView!
    @IBOutlet weak var yesButton: UIButton!
    @IBOutlet weak var noButton: UIButton!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var buttonPromptLabel: UILabel!
    
    
    //If yesButton clicked, run text recognition on each tile on the scrabble board
    @IBAction func yesButton(_ sender: Any) {
        
        //Make buttons disappear
        self.yesButton.isHidden = true
        self.yesButton.isEnabled = false
        self.noButton.isHidden = true
        self.noButton.isEnabled = false
        
        //Make button prompt disappear
        self.buttonPromptLabel.isHidden = true
        
        //Start activity indicator
        self.activityIndicator.isHidden = false
        self.activityIndicator.startAnimating()
        
        recognizeTiles(image: image, x: x, y: y, width: cellWidth, height: cellHeight, nextCol: nextCol, nextRow: nextRow) {returnedArray in
            guard let returnedArray = returnedArray else {return}
            self.cellTextArray = returnedArray
            print(self.cellTextArray.count)
            self.performSegue(withIdentifier: "SegueToNextScreen", sender: self)
        }
        
    }
    
    //Prepare for segue
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "SegueToNextScreen" {
            let vc = segue.destination as! BoardViewController
            vc.cellTextArray = self.cellTextArray
        }
    }
    
    //Board information infered by last view controller
    var scannedBoard : CVPixelBuffer?
    var boardCoordinates = [Int]()
    var boardWidth = 0
    var boardHeight = 0
    
    //Array to hold recognized letter tiles
    var cellTextArray = [String]()
    
    //Image to be displayed on view
    lazy var ciimage : CIImage = CIImage(cvPixelBuffer: scannedBoard!)
    lazy var image : UIImage = self.convert(cimage: ciimage)
    
    //Dimensions and locations of individual tiles in the board
    lazy var cellWidth = CGFloat(boardWidth) * 0.05
    lazy var cellHeight = CGFloat(boardHeight) * 0.057
    lazy var x = (CGFloat(boardWidth) * 0.2275 + CGFloat(boardCoordinates[0])) - (cellWidth / 2)
    lazy var y = (CGFloat(boardHeight) * 0.02 + CGFloat(boardCoordinates[1])) - (cellHeight / 2)
    
    //Space between each row and column of the board
    lazy var nextCol = (CGFloat(boardWidth) * 0.043)
    lazy var nextRow = (CGFloat(boardHeight) * 0.047)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //Display image taken from last screen
        self.scannedBoardImageView.image = image
        
        //Hide activity indicator
        self.activityIndicator.isHidden = true
        
        //Draw board location box
        self.locationBox.frame.origin.x = CGFloat(boardCoordinates[0])
        self.locationBox.frame.origin.y = CGFloat(boardCoordinates[1])
        self.locationBox.frame.size.width = CGFloat(boardWidth)
        self.locationBox.frame.size.height = CGFloat(boardHeight) - 5
        
        //Display image of center tile in view
        let crop_box = CGRect(x: x + nextCol * 7, y: y + nextRow * 7, width: cellWidth, height: cellHeight)
        let cropped_image = self.cropImage(image, toRect: crop_box, viewWidth: view.frame.width, viewHeight: view.frame.height)
        self.selectedCellImageView.image = cropped_image
    }
    
    //Perform text recognition
    func recognizeTiles(image : UIImage, x : CGFloat, y : CGFloat, width : CGFloat, height : CGFloat, nextCol : CGFloat, nextRow : CGFloat, completion: @escaping ([String]?) -> Void) {
        
        var arrayToReturn = [String]()
        
        //Intialize text recognizer
        let textRecognizer = TextRecognizer.textRecognizer()
        
        let alphabet = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz"
        for row in 0...14 {
            for col in 0...14 {
                
                //Crop image of tile at (row, col)
                let crop_box = CGRect(x: x + (nextCol * CGFloat(col)), y: y + (nextRow * CGFloat(row)), width: width, height: height)
                
                let cropped_image = self.cropImage(image, toRect: crop_box, viewWidth: view.frame.width, viewHeight: view.frame.height)
                
                //Create vision image from cropped Image
                let vision_image = VisionImage(image: cropped_image!)
                vision_image.orientation = cropped_image!.imageOrientation
                
                //dispatchGroup.enter()
                //Recognize text in vision image
                textRecognizer.process(vision_image) { result, error in
                  guard error == nil, let result = result else {
                    // Error handling
                    print("error")
                    return
                  }
                    if result.blocks.count == 0 {
                        arrayToReturn.append("")
                    }
                    else {
                        //If text is recognized, make sure we only extract letters, not numbers or punctuation
                        var appended = false
                        for text in result.blocks {
                            if alphabet.contains(String(text.text.prefix(1))) {
                                arrayToReturn.append(String(text.text.prefix(1)))
                                print(String(text.text.prefix(1)))
                                appended = true
                                break
                            }
                        }
                        
                        //Make sure to at lease append something
                        if appended == false {
                            arrayToReturn.append("")
                        }
                    }
                    
                    if row == 14 && col == 14 {
                        print("Text Recognizer COMPLETE")
                        return completion(arrayToReturn)
                    }
                }
            }
        }
    }
    
    //Convert image from CIImage to UIImage
    func convert(cimage:CIImage) -> UIImage
     {
         let context:CIContext = CIContext.init(options: nil)
         let cgImage:CGImage = context.createCGImage(cimage, from: cimage.extent)!
         let image:UIImage = UIImage.init(cgImage: cgImage)
         return image

     }
    
    //Crop image to specified CGRect
    func cropImage(_ inputImage: UIImage, toRect cropRect: CGRect, viewWidth: CGFloat, viewHeight: CGFloat) -> UIImage?
    {
        let imageViewScale = max(inputImage.size.width / viewWidth,
                                 inputImage.size.height / viewHeight)

        // Scale cropRect to handle images larger than shown-on-screen size
        let cropZone = CGRect(x:cropRect.origin.x * imageViewScale,
                              y:cropRect.origin.y * imageViewScale,
                              width:cropRect.size.width * imageViewScale,
                              height:cropRect.size.height * imageViewScale)

        // Perform cropping in Core Graphics
        guard let cutImageRef: CGImage = inputImage.cgImage?.cropping(to:cropZone)
        else {
            return nil
        }

        // Return image to UIImage
        let croppedImage: UIImage = UIImage(cgImage: cutImageRef)
        return croppedImage
    }
}
