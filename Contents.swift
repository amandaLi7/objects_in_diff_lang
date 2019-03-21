import UIKit
import CoreML
import PlaygroundSupport
import ARKit
import SpriteKit

class ViewController : UIViewController, ARSKViewDelegate, ARSessionDelegate {
    
    let model = ImageClassifier()
    var sceneView: ARSKView!
    var pixelBuffer: CVPixelBuffer?
    var mlpredictiontext: String = ""
    
    override func loadView() {
        sceneView = ARSKView(frame:CGRect(x: 0.0, y: 0.0, width: 500.0, height: 600.0))
        // Set the view's delegate
        sceneView.delegate = self
        
        // Show statistics such as fps and node count
        sceneView.showsFPS = true
        sceneView.showsNodeCount = true
        
        // Load the SKScene from 'Scene.sks'
        if let scene = SKScene(fileNamed: "Scene") {
            sceneView.presentScene(scene)
        }

        let config = ARWorldTrackingConfiguration()
        config.planeDetection = .horizontal
        // Playground note: You can't use the audio capture capabilities
        // of an ARSession with a Swift Playground.
        // config.providesAudioData = true
        
        // Now we'll get messages when planes were detected...
        sceneView.session.delegate = self
        
        self.view = sceneView
        sceneView.session.run(config)
        

    }
    
    public func getPredictionFromModel(cvbuffer: CVPixelBuffer?){
        //from AnimalClassifier getPredictionFromModel()
        do {
            let object = try model.prediction(image: cvbuffer!)
            mlpredictiontext = object.classLabel
            print("###### \(object.classLabel)")
            //classLabelProbability.text = "\(object.classLabelProbs[classLabel.text!]!)"
        } catch {
            print(error)
        }
    }
    
    public func buffer(from image: UIImage) -> CVPixelBuffer? {
        let attrs = [kCVPixelBufferCGImageCompatibilityKey: kCFBooleanTrue, kCVPixelBufferCGBitmapContextCompatibilityKey: kCFBooleanTrue] as CFDictionary
        var pixelBuffer : CVPixelBuffer?
        let status = CVPixelBufferCreate(kCFAllocatorDefault, Int(image.size.width), Int(image.size.height), kCVPixelFormatType_32ARGB, attrs, &pixelBuffer)
        guard (status == kCVReturnSuccess) else {
            return nil
        }
        
        CVPixelBufferLockBaseAddress(pixelBuffer!, CVPixelBufferLockFlags(rawValue: 0))
        let pixelData = CVPixelBufferGetBaseAddress(pixelBuffer!)
        
        let rgbColorSpace = CGColorSpaceCreateDeviceRGB()
        let context = CGContext(data: pixelData, width: Int(image.size.width), height: Int(image.size.height), bitsPerComponent: 8, bytesPerRow: CVPixelBufferGetBytesPerRow(pixelBuffer!), space: rgbColorSpace, bitmapInfo: CGImageAlphaInfo.noneSkipFirst.rawValue)
        
        context?.translateBy(x: 0, y: image.size.height)
        context?.scaleBy(x: 1.0, y: -1.0)
        
        UIGraphicsPushContext(context!)
        image.draw(in: CGRect(x: 0, y: 0, width: image.size.width, height: image.size.height))
        UIGraphicsPopContext()
        CVPixelBufferUnlockBaseAddress(pixelBuffer!, CVPixelBufferLockFlags(rawValue: 0))
        
        return pixelBuffer
    }

    // MARK: - ARSKViewDelegate
    func view(_ view: ARSKView, nodeFor anchor: ARAnchor) -> SKNode? {
        // You can use this to create a sprite from an emoji,
        // like an alien monster (👾), a cat (🐱), or more (🥛, 🍩, 📦)
        //let spriteNode = SKLabelNode(text: "👾")
        let spriteNode = SKLabelNode(text: "HI!!! \(mlpredictiontext)")
        spriteNode.horizontalAlignmentMode = .center
        spriteNode.verticalAlignmentMode = .center
        // Or you could create and configure a node for the anchor added to the view's session.
//        let image = #imageLiteral(resourceName: "PearLogo.png")
//        let spriteTexture = SKTexture(cgImage: image.cgImage!)
//        let spriteNode = SKSpriteNode(texture: spriteTexture)
        return spriteNode;
    }
    
    func session(_ session: ARSession, didFailWithError error: Error) {
        // Present an error message to the user
    }
    
    func sessionWasInterrupted(_ session: ARSession) {
        // Inform the user that the session has been interrupted, for example, by presenting an overlay
    }
    
    func sessionInterruptionEnded(_ session: ARSession) {
        // Reset tracking and/or remove existing anchors if consistent tracking is required
    }
}

PlaygroundPage.current.liveView = ViewController()
PlaygroundPage.current.needsIndefiniteExecution = true

//: This is our Scene, which doesn't do a heck of a lot.
public class Scene: SKScene {
    
    public override required init(size:CGSize) {
        super.init(size:size)
    }
    
    public required init(coder: NSCoder) {
        super.init(coder:coder)!
    }
    public override func didMove(to view: SKView) {
        // Setup your scene here
    }
    
    public override func update(_ currentTime: TimeInterval) {
        // Called before each frame is rendered
        
        let vc = ViewController()
        let pixbuff: CVPixelBuffer? = vc.sceneView.session.currentFrame?.capturedImage
        if pixbuff == nil { return }
        let coreImage = CIImage(cvPixelBuffer: pixbuff!)
        let buffer = vc.buffer(from: convert(image: coreImage))
        vc.getPredictionFromModel(cvbuffer: buffer)
    }
    
    private func convert(image: CIImage) -> UIImage
    {
        let context:CIContext = CIContext.init(options: nil)
        let cgImage:CGImage = context.createCGImage(image, from: image.extent)!
        let image:UIImage = UIImage.init(cgImage: cgImage)
        return image
    }
}



