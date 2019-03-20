//
// ImageClassifier.swift
//
// This file was automatically generated and should not be edited.
//

import CoreML


/// Model Prediction Input Type
@available(macOS 10.13, iOS 11.0, tvOS 11.0, watchOS 4.0, *)
public class ImageClassifierInput : MLFeatureProvider {
    
    /// Input image to be classified as color (kCVPixelFormatType_32BGRA) image buffer, 299 pixels wide by 299 pixels high
    var image: CVPixelBuffer
    
    public var featureNames: Set<String> {
        get {
            return ["image"]
        }
    }
    
    public func featureValue(for featureName: String) -> MLFeatureValue? {
        if (featureName == "image") {
            return MLFeatureValue(pixelBuffer: image)
        }
        return nil
    }
    
    public init(image: CVPixelBuffer) {
        self.image = image
    }
}

/// Model Prediction Output Type
@available(macOS 10.13, iOS 11.0, tvOS 11.0, watchOS 4.0, *)
public class ImageClassifierOutput : MLFeatureProvider {
    
    /// Source provided by CoreML
    
    private let provider : MLFeatureProvider
    
    
    /// Probability of each category as dictionary of strings to doubles
    public lazy var classLabelProbs: [String : Double] = {
        [unowned self] in return self.provider.featureValue(for: "classLabelProbs")!.dictionaryValue as! [String : Double]
        }()
    
    /// Most likely image category as string value
    public lazy var classLabel: String = {
        [unowned self] in return self.provider.featureValue(for: "classLabel")!.stringValue
        }()
    
    public var featureNames: Set<String> {
        return self.provider.featureNames
    }
    
    public func featureValue(for featureName: String) -> MLFeatureValue? {
        return self.provider.featureValue(for: featureName)
    }
    
    public init(classLabelProbs: [String : Double], classLabel: String) {
        self.provider = try! MLDictionaryFeatureProvider(dictionary: ["classLabelProbs" : MLFeatureValue(dictionary: classLabelProbs as [AnyHashable : NSNumber]), "classLabel" : MLFeatureValue(string: classLabel)])
    }
    
    public init(features: MLFeatureProvider) {
        self.provider = features
    }
}


/// Class for model loading and prediction
@available(macOS 10.13, iOS 11.0, tvOS 11.0, watchOS 4.0, *)
public class ImageClassifier {
    var model: MLModel
    
    /// URL of model assuming it was installed in the same bundle as this class
    class var urlOfModelInThisBundle : URL {
        let bundle = Bundle(for: ImageClassifier.self)
        return bundle.url(forResource: "ImageClassifier", withExtension:"mlmodelc")!
    }
    
    /**
     Construct a model with explicit path to mlmodelc file
     - parameters:
     - url: the file url of the model
     - throws: an NSError object that describes the problem
     */
    public init(contentsOf url: URL) throws {
        self.model = try MLModel(contentsOf: url)
    }
    
    /// Construct a model that automatically loads the model from the app's bundle
    public convenience init() {
        try! self.init(contentsOf: type(of:self).urlOfModelInThisBundle)
    }
    
    /**
     Construct a model with configuration
     - parameters:
     - configuration: the desired model configuration
     - throws: an NSError object that describes the problem
     */
    @available(macOS 10.14, iOS 12.0, tvOS 12.0, watchOS 5.0, *)
    public convenience init(configuration: MLModelConfiguration) throws {
        try self.init(contentsOf: type(of:self).urlOfModelInThisBundle, configuration: configuration)
    }
    
    /**
     Construct a model with explicit path to mlmodelc file and configuration
     - parameters:
     - url: the file url of the model
     - configuration: the desired model configuration
     - throws: an NSError object that describes the problem
     */
    @available(macOS 10.14, iOS 12.0, tvOS 12.0, watchOS 5.0, *)
    public init(contentsOf url: URL, configuration: MLModelConfiguration) throws {
        self.model = try MLModel(contentsOf: url, configuration: configuration)
    }
    
    /**
     Make a prediction using the structured interface
     - parameters:
     - input: the input to the prediction as ImageClassifierInput
     - throws: an NSError object that describes the problem
     - returns: the result of the prediction as ImageClassifierOutput
     */
    public func prediction(input: ImageClassifierInput) throws -> ImageClassifierOutput {
        return try self.prediction(input: input, options: MLPredictionOptions())
    }
    
    /**
     Make a prediction using the structured interface
     - parameters:
     - input: the input to the prediction as ImageClassifierInput
     - options: prediction options
     - throws: an NSError object that describes the problem
     - returns: the result of the prediction as ImageClassifierOutput
     */
    public func prediction(input: ImageClassifierInput, options: MLPredictionOptions) throws -> ImageClassifierOutput {
        let outFeatures = try model.prediction(from: input, options:options)
        return ImageClassifierOutput(features: outFeatures)
    }
    
    /**
     Make a prediction using the convenience interface
     - parameters:
     - image: Input image to be classified as color (kCVPixelFormatType_32BGRA) image buffer, 299 pixels wide by 299 pixels high
     - throws: an NSError object that describes the problem
     - returns: the result of the prediction as ImageClassifierOutput
     */
    public func prediction(image: CVPixelBuffer) throws -> ImageClassifierOutput {
        let input_ = ImageClassifierInput(image: image)
        return try self.prediction(input: input_)
    }
    
    /**
     Make a batch prediction using the structured interface
     - parameters:
     - inputs: the inputs to the prediction as [ImageClassifierInput]
     - options: prediction options
     - throws: an NSError object that describes the problem
     - returns: the result of the prediction as [ImageClassifierOutput]
     */
    @available(macOS 10.14, iOS 12.0, tvOS 12.0, watchOS 5.0, *)
    public func predictions(inputs: [ImageClassifierInput], options: MLPredictionOptions = MLPredictionOptions()) throws -> [ImageClassifierOutput] {
        let batchIn = MLArrayBatchProvider(array: inputs)
        let batchOut = try model.predictions(from: batchIn, options: options)
        var results : [ImageClassifierOutput] = []
        results.reserveCapacity(inputs.count)
        for i in 0..<batchOut.count {
            let outProvider = batchOut.features(at: i)
            let result =  ImageClassifierOutput(features: outProvider)
            results.append(result)
        }
        return results
    }
}
