// Copyright 2019 The TensorFlow Authors. All Rights Reserved.
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//    http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

import UIKit

class ViewController: UIViewController {
    
    var scannedImage : CVPixelBuffer?
    var boardCoordinates = [0, 0]
    var boardWidth : Int?
    var boardHeight : Int?
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let vc = segue.destination as! TileInferenceViewController
        vc.scannedBoard = self.scannedImage
        vc.boardCoordinates = self.boardCoordinates
        vc.boardWidth = self.boardWidth!
        vc.boardHeight = self.boardHeight!
    }
    
    @IBOutlet weak var scanButton: UIButton!
    
    // MARK: Storyboards Connections
    @IBOutlet weak var previewView: PreviewView!
    @IBOutlet weak var overlayView: OverlayView!
    
    // MARK: Constants
    private let displayFont = UIFont.systemFont(ofSize: 14.0, weight: .medium)
    private let edgeOffset: CGFloat = 2.0
    private let labelOffset: CGFloat = 10.0
    private let animationDuration = 0.5
    private let collapseTransitionThreshold: CGFloat = -30.0
    private let expandThransitionThreshold: CGFloat = 30.0
    private let delayBetweenInferencesMs: Double = 200
    
    // MARK: Instance Variables
    private var initialBottomSpace: CGFloat = 0.0
    
    // Holds the results at any time
    private var result: Result?
    private var previousInferenceTimeMs: TimeInterval = Date.distantPast.timeIntervalSince1970 * 1000
    
    // MARK: Controllers that manage functionality
    private lazy var cameraFeedManager = CameraFeedManager(previewView: previewView)
    private var modelDataHandler: ModelDataHandler? =
        ModelDataHandler(modelFileInfo: MobileNetSSD.modelInfo, labelsFileInfo: MobileNetSSD.labelsInfo)
    
    // MARK: View Handling Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //Makes button disabled by default
        scanButton.isEnabled = false
        scanButton.setTitleColor(UIColor.systemBlue, for: .disabled)
        scanButton.setBackgroundImage(UIImage(named: "disabled-button.png"), for: .disabled)
        
        guard modelDataHandler != nil else {
            fatalError("Failed to load model")
        }
        cameraFeedManager.delegate = self
        overlayView.clearsContextBeforeDrawing = true
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        cameraFeedManager.checkCameraConfigurationAndStartSession()
        print("Started Session")
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        cameraFeedManager.stopSession()
        print("Stopped Session")
    }
}

// MARK: CameraFeedManagerDelegate Methods
extension ViewController: CameraFeedManagerDelegate {
    
    func didOutput(pixelBuffer: CVPixelBuffer) {
        self.scannedImage = pixelBuffer
        runModel(onPixelBuffer: pixelBuffer)
    }
    
    // MARK: Session Handling Alerts
    func sessionRunTimeErrorOccured() {}
    
    func sessionWasInterrupted(canResumeManually resumeManually: Bool) {}
    
    func sessionInterruptionEnded() {}
    
    func presentVideoConfigurationErrorAlert() {
        
        let alertController = UIAlertController(title: "Confirguration Failed", message: "Configuration of camera has failed.", preferredStyle: .alert)
        let okAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
        alertController.addAction(okAction)
        
        present(alertController, animated: true, completion: nil)
    }
    
    func presentCameraPermissionsDeniedAlert() {
        
        let alertController = UIAlertController(title: "Camera Permissions Denied", message: "Camera permissions have been denied for this app. You can change this by going to Settings", preferredStyle: .alert)
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        let settingsAction = UIAlertAction(title: "Settings", style: .default) { (action) in
            
            UIApplication.shared.open(URL(string: UIApplication.openSettingsURLString)!, options: [:], completionHandler: nil)
        }
        
        alertController.addAction(cancelAction)
        alertController.addAction(settingsAction)
        
        present(alertController, animated: true, completion: nil)
        
    }
    
    /** This method runs the live camera pixelBuffer through tensorFlow to get the result.
     */
    @objc  func runModel(onPixelBuffer pixelBuffer: CVPixelBuffer) {
        
        // Run the live camera pixelBuffer through tensorFlow to get the result
        
        let currentTimeMs = Date().timeIntervalSince1970 * 1000
        
        guard  (currentTimeMs - previousInferenceTimeMs) >= delayBetweenInferencesMs else {
            return
        }
        
        previousInferenceTimeMs = currentTimeMs
        result = self.modelDataHandler?.runModel(onFrame: pixelBuffer)
        
        guard let displayResult = result else {
            return
        }
        
        let width = CVPixelBufferGetWidth(pixelBuffer)
        let height = CVPixelBufferGetHeight(pixelBuffer)
        
        DispatchQueue.main.async {
            
            // Draws the bounding boxes and displays class names and confidence scores.
            self.drawAfterPerformingCalculations(onInferences: displayResult.inferences, withImageSize: CGSize(width: CGFloat(width), height: CGFloat(height)))
        }
    }
    
    /**
     This method takes the results, translates the bounding box rects to the current view, draws the bounding boxes, classNames and confidence scores of inferences.
     */
    func drawAfterPerformingCalculations(onInferences inferences: [Inference], withImageSize imageSize:CGSize) {
        
        self.overlayView.objectOverlays = []
        self.overlayView.setNeedsDisplay()
        
        guard !inferences.isEmpty else {
            return
        }
        
        var objectOverlays: [ObjectOverlay] = []
        
        for inference in inferences {
            
            // Translates bounding box rect to current view.
            var convertedRect = inference.rect.applying(CGAffineTransform(scaleX: self.overlayView.bounds.size.width / imageSize.width, y: self.overlayView.bounds.size.height / imageSize.height))
            
            if convertedRect.origin.x < 0 {
                convertedRect.origin.x = self.edgeOffset
            }
            
            if convertedRect.origin.y < 0 {
                convertedRect.origin.y = self.edgeOffset
            }
            
            if convertedRect.maxY > self.overlayView.bounds.maxY {
                convertedRect.size.height = self.overlayView.bounds.maxY - convertedRect.origin.y - self.edgeOffset
            }
            
            if convertedRect.maxX > self.overlayView.bounds.maxX {
                convertedRect.size.width = self.overlayView.bounds.maxX - convertedRect.origin.x - self.edgeOffset
            }
            
            let confidenceValue = Int(inference.confidence * 100.0)
            let string = "\(inference.className)  (\(confidenceValue)%)"
            
            let size = string.size(usingFont: self.displayFont)
            //print("\(convertedRect.maxX), \(convertedRect.maxY)")
            
            //Since the cordinates are a little shifted, shift bouding boxes accordingly
            if convertedRect.origin.x < 150 {
                convertedRect.origin.x -= 35
            }
            else {
                convertedRect.origin.x += 35
            }
            let objectOverlay = ObjectOverlay(name: string, borderRect: convertedRect, nameStringSize: size, color: inference.displayColor, font: self.displayFont)
            
            if inference.className != "Scrabble Board" {
                objectOverlays.append(objectOverlay)
            }
        }
        
        if objectOverlays.count == 4 {
            //Get board coordinates
            var boardX = 0
            var boardY = 0
            for corner in objectOverlays {
                if corner.borderRect.origin.x < 150 && corner.borderRect.origin.y < 150 {
                    boardX = Int(corner.borderRect.origin.x)
                    boardY = Int(corner.borderRect.origin.y)
                    self.boardCoordinates[0] = (Int(boardX))
                    self.boardCoordinates[1] = (Int(boardY))
                    break
                }
            }
            //Get board width
            for corner in objectOverlays {
                let width = Int(Float(corner.borderRect.maxX) - Float(boardX))
                if  width > 200 {
                    self.boardWidth = width
                    break
                }
            }
            
            //Get board height
            for corner in objectOverlays {
                let height = Int(Float(corner.borderRect.maxY) - Float(boardY) - 5)
                if  height > 200 {
                    self.boardHeight = height
                    break
                }
            }
            scanButton.isEnabled = true
            scanButton.setTitleColor(UIColor.white, for: .normal)
            scanButton.setBackgroundImage(UIImage(named: "enabled-button.png"), for: .normal)
        }
        else {
            scanButton.isEnabled = false
            scanButton.setTitleColor(UIColor.systemBlue, for: .disabled)
            scanButton.setBackgroundImage(UIImage(named: "disabled-button.png"), for: .disabled)
        }
        
        // Hands off drawing to the OverlayView
        self.draw(objectOverlays: objectOverlays)
        
    }
    
    /** Calls methods to update overlay view with detected bounding boxes and class names.
     */
    func draw(objectOverlays: [ObjectOverlay]) {
        
        self.overlayView.objectOverlays = objectOverlays
        self.overlayView.setNeedsDisplay()
    }
    
    
    
    
    
    
    
    
}


