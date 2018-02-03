//
//  DrawingVC.swift
//  Number Reco
//
//  Created by Kethinedi Pavand on 1/31/18.
//  Copyright © 2018 Kethinedi Pavand. All rights reserved.
//

import UIKit
import CoreML
import Vision

class DrawingVC: UIViewController {

    @IBOutlet weak var drawingimageView: UIImageView!
    @IBOutlet weak var predictionLable: UILabel!
    var lastPoint = CGPoint.zero
    var swiped = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        swiped=false
        drawingimageView.image=nil
        if let touch = touches.first{
            lastPoint=touch.location(in: drawingimageView)
            print(lastPoint)
        }
        
    }
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        swiped=true
        if let touch=touches.first{
            let currentPoint=touch.location(in: drawingimageView)
            drawLine(fromPoint: lastPoint, toPoint: currentPoint)
            lastPoint=currentPoint
        }
        
    }
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        if swiped == false{
            drawLine(fromPoint: lastPoint, toPoint: lastPoint)
        }
        
    }

    
    @IBAction func predictBtnWasPressed(_ sender: Any) {
        guard let predictionImage = drawingimageView.image else{return}
        makePrediction(image(with: predictionImage, scaledTo: CGSize(width: 28.0, height: 28.0)))
    }
    
    
    func drawLine(fromPoint:CGPoint,toPoint:CGPoint){
        UIGraphicsBeginImageContext(drawingimageView.frame.size)
        let context = UIGraphicsGetCurrentContext()
        drawingimageView.image?.draw(in:CGRect(x: 0, y: 0, width: drawingimageView.frame.size.width, height: drawingimageView.frame.size.height))
        context?.move(to: CGPoint(x: fromPoint.x, y: fromPoint.y))
        context?.addLine(to: CGPoint(x: toPoint.x, y: toPoint.y))
        context?.setLineCap(.round)
        context?.setLineWidth(10.0)
        context?.setStrokeColor(#colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0))
        context?.setBlendMode(.normal)
        context?.strokePath()
        drawingimageView.image=UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext()
        
    }
    
    func makePrediction(_ image:UIImage){
        guard let model = try? VNCoreMLModel(for: num_rec_1().model) else {return}
        let request = VNCoreMLRequest(model : model, completionHandler : resultsMethod)
        guard let ciImage = CIImage(image : image) else {return}
        let handler = VNImageRequestHandler(ciImage: ciImage, options: [:])
        do{
            try handler.perform([request])
        }catch{
            debugPrint(error)
        }
    }
    
    func resultsMethod(request: VNRequest, error:Error?){
        guard let results = request.results,
        let resultsArray = results[0] as? VNCoreMLFeatureValueObservation,
            let mulitArrayValue = resultsArray.featureValue.multiArrayValue else{return}
        var prediction : NSNumber = 0
        var compare: NSNumber = 0
        var atIndex: Int = 0
        var i:Int = 0
        while i<mulitArrayValue.count {
            compare = mulitArrayValue[i]
            if compare.floatValue > prediction.floatValue{
                prediction = compare
                atIndex = i
            }
            i = i+1
        }
        predictionLable.text = "Digit may be : \(atIndex)"
    }
    
    func image(with image:UIImage, scaledTo newSize:CGSize)-> UIImage{
        UIGraphicsBeginImageContextWithOptions(newSize, false, 1.0)
        image.draw(in: CGRect(x: 0, y: 0, width: newSize.width, height: newSize.height))
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        drawingimageView.image = newImage
        return newImage ?? UIImage()
        
    }
    
    
    
    
    
    
    
    
    
    
    
    
    

}

