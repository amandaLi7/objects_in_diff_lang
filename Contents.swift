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
    let translationArray: [String: [String]] = ["backpack": ["la mochila", "书包"], "bookcase": ["la estantería", "书架"], "calculator": ["la calculadora", "计算器"], "carpet": ["la alfombra", "地毯"], "clock": ["el reloj", "钟"], "computer": ["la computadora", "计算机"], "curtain/window shade": ["la cortina", "窗帘"], "door": ["la puerta", "门"], "drinking cup": ["el vaso", "杯子"], "floor": ["el suelo", "地板"], "lamp": ["la lámpara", "灯"], "notebook": ["el cuaderno", "笔记本"], "paper": ["el papel", "纸"], "pencil": ["el lápiz", "铅笔"], "phone": ["el teléfono", "电话"], "shoe": ["los zapatos", "鞋子"], "wall": ["la pared", "墙"], "watch": ["el reloj", "手表"], "water bottle": ["la botella de agua", "水瓶"]]
    var spanOrChinese: Bool = true //true - Spanish, false - Chinese
    let languages = ["Spanish", "Chinese"]
    var languagePicker: UISegmentedControl!
    
    override func loadView() {
        sceneView = ARSKView(frame:CGRect(x: 0.0, y: 0.0, width: 500.0, height: 600.0))
        sceneView.delegate = self
        
        sceneView.showsFPS = true
        sceneView.showsNodeCount = true
        
        // Load the SKScene from 'Scene.sks'
        if let scene = SKScene(fileNamed: "Scene") {
            sceneView.presentScene(scene)
        }

        let config = ARWorldTrackingConfiguration()
        config.planeDetection = [.horizontal, .vertical]
        // Playground note: You can't use the audio capture capabilities
        // of an ARSession with a Swift Playground.
        // config.providesAudioData = true
        
        sceneView.session.delegate = self
        
        self.view = sceneView
        
        languagePicker = UISegmentedControl(items: ["Spanish", "Chinese"])
        languagePicker.addTarget(self, action: #selector(languageChosen), for: .valueChanged)
        self.view.addSubview(languagePicker)
        languagePicker.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([languagePicker.topAnchor.constraint(equalTo: view.topAnchor, constant: 10), languagePicker.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 10)])
        
        sceneView.session.run(config)
    }
    
    @objc func languageChosen(){
        let idx = languagePicker.selectedSegmentIndex
        let lang = (idx == UISegmentedControl.noSegment) ? "none" : languages[idx]
        if lang == "Spanish"{
            spanOrChinese = true
        } else if lang == "Chinese"{
            spanOrChinese = false
        } else{
            return
        }
    }
    
    public func getPredictionFromModel(cvbuffer: CVPixelBuffer?){
        do {
            let object = try model.prediction(image: cvbuffer!)
            let objInEng = object.classLabel
            
            if spanOrChinese{
                //in spanish
                for key in translationArray.keys{
                    if key == objInEng{
                        mlpredictiontext = translationArray[key]![0]
                    }
                }
            } else {
                //in chinese
                for key in translationArray.keys{
                    if key == objInEng{
                        mlpredictiontext = translationArray[key]![1]
                    }
                }
            }
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
        let spriteNode = SKLabelNode(text: "")
        spriteNode.fontColor = UIColor(red: 0.2, green: 0.6, blue: 0.9, alpha: 1)
        let pixbuff: CVPixelBuffer? = sceneView.session.currentFrame?.capturedImage
        if pixbuff != nil {
            getPredictionFromModel(cvbuffer: pixbuff!)
            spriteNode.text = "\(mlpredictiontext)"
            spriteNode.horizontalAlignmentMode = .center
            spriteNode.verticalAlignmentMode = .center
        } else {
            spriteNode.text = "FAILED!"
            spriteNode.horizontalAlignmentMode = .center
            spriteNode.verticalAlignmentMode = .center
        }
    
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
    }
}



