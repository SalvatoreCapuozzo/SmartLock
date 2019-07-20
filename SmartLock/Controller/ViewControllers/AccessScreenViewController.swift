//
//  AccessScreenViewController.swift
//  SmartLock
//
//  Created by Salvatore Capuozzo on 01/07/2019.
//  Copyright © 2019 Salvatore Capuozzo. All rights reserved.
//

import UIKit
import LocalAuthentication
import Vision
import AVFoundation
import CoreBluetooth

class AccessScreenViewController: AppViewController, UITableViewDelegate, UITableViewDataSource, CountdownTimerDelegate {
    var interphoneTableView: UITableView!
    var sequenceHandler = VNSequenceRequestHandler()
    var faceView: FaceView!
    var cameraView: UIView!
    var searchTextField: UITextField!
    var manualButton: UIView!
    var codeButton: UIView!
    var settingsButton: UIView!
    var timerView: CountdownTimer!
    
    let session = AVCaptureSession()
    var previewLayer: AVCaptureVideoPreviewLayer!
    
    var showDetection: Bool = false
    
    let dataOutputQueue = DispatchQueue(
        label: "video data queue",
        qos: .userInitiated,
        attributes: [],
        autoreleaseFrequency: .workItem)
    
    var isAccessScreenActive: Bool = false
    
    var stillPhoto: UIImage!
    var currentUserName: String = ""
    
    /// - Tag: MLModelSetup
    lazy var classificationRequest: VNCoreMLRequest = {
        do {
            // Insert here model to recognize faces
            let model = try VNCoreMLModel(for: SmartLockModel_1450859332().model)
            
            let request = VNCoreMLRequest(model: model, completionHandler: { [weak self] request, error in
                DispatchQueue.main.async {
                    guard let results = request.results else {
                        print("Unable to classify image.\n\(error!.localizedDescription)")
                        return
                    }
                    // The `results` will always be `VNClassificationObservation`s, as specified by the Core ML model in this project.
                    let classifications = results as! [VNClassificationObservation]
                    
                    if classifications.isEmpty {
                        print("Nothing recognized.")
                    } else {
                        self?.push(data: classifications)
                    }
                }
            })
            request.imageCropAndScaleOption = .centerCrop
            return request
        } catch {
            fatalError("Failed to load Vision ML model: \(error)")
        }
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUserInterface()
        
        self.isAccessScreenActive = true
        
        configureCaptureSession()
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(tappedOnScreen))
        self.view.addGestureRecognizer(tapGesture)
        
        tapGesture.cancelsTouchesInView = false

        session.startRunning()
        
        DataController().deleteData(entityName: "User")
        
        DataController().addUser(name: "Maria Luisa", surname: "Farina", code: "270693", number: "3387499411", isFamily: true, isManager: false)
        DataController().addUser(name: "Salvatore", surname: "Capuozzo", code: "190596", number: "3394272543", isFamily: true, isManager: true)
 
        DataController().addUser(name: "Filippo", surname: "Ferrandino", code: "123456", number: "3382705855", isFamily: true, isManager: false)
        DataController().addUser(name: "Federica", surname: "Ventriglia", code: "789012", number: "3272487201", isFamily: true, isManager: false)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.isAccessScreenActive = true
        
        DataController().fetchData(entity: .user) {
            (outcome, results) in
            if outcome! {
                self.users = results
                self.interphoneTableView.reloadData()
            }
        }
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        self.isAccessScreenActive = false
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return users.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "reuseIdentifier") as! InterphoneTableViewCell
        
        cell.nameLabel.text = "\(String(describing: users[indexPath.row]["surname"]!)) \(String(describing: users[indexPath.row]["name"]!))"
        cell.clipsToBounds = true
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return self.interphoneTableView.frame.size.height/6.5
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let cell = tableView.cellForRow(at: indexPath) as! InterphoneTableViewCell
        
        guard let name = cell.nameLabel.text else {
            return
        }
        
        let phoneNumber = users[indexPath.row]["number"] as! String
        
        GSMessage.showMessageAddedTo("Stai bussando \(name) \n ...", type: .info, options: [
            .animationDuration(0.3),
            .autoHide(true),
            .autoHideDelay(2.0),
            .cornerRadius(10.0),
            .height(100),
            .hideOnTap(true),
            .position(.bottom),
            .textAlignment(.center),
            .textColor(.white),
            .textNumberOfLines(2),
            ]
            , inView: self.view, inViewController: self)
        
        print("Sto chiamando \(name) al \(phoneNumber)")
        self.sendToDevice(textToSend: phoneNumber, completion: {})
       
//        print("Bussa \(name)")
    }
    
    
    override func setupUserInterface() {
        super.setupUserInterface()
        // Interphone TableView Setup
        interphoneTableView = UITableView(frame: CGRect(x: 0, y: 0, width: self.view.frame.size.width*2/3, height: self.view.frame.size.height*3/5))
        interphoneTableView.center = CGPoint(x: self.view.frame.size.width/2, y:self.view.frame.size.height - interphoneTableView.frame.size.height/2 - 16)
        interphoneTableView.backgroundColor = .clear
        interphoneTableView.topAnchor.constraint(equalTo: self.view.topAnchor, constant: 10)
        interphoneTableView.layer.cornerRadius = 20
        interphoneTableView.layer.masksToBounds = true
        interphoneTableView.layer.borderColor = UIColor.white.cgColor
        interphoneTableView.layer.borderWidth = 5
        self.view.addSubview(interphoneTableView)
        
//        interphoneTableView.topAnchor.constraint(equalTo: .manualButton.bottomAnchor, constant: 20)
        
        self.interphoneTableView.delegate = self
        self.interphoneTableView.dataSource = self
        self.interphoneTableView.allowsSelection = true
        self.interphoneTableView.isUserInteractionEnabled = true
        self.interphoneTableView.separatorColor = .clear
        self.interphoneTableView.separatorStyle = .none
        interphoneTableView.register(InterphoneTableViewCell.self, forCellReuseIdentifier: "reuseIdentifier")

        // CameraView Setup
        cameraView = UIView(frame: CGRect(x: 8, y: 24, width: self.view.frame.size.width/4, height: self.view.frame.size.height/4))
        cameraView.layer.cornerRadius = 20
        cameraView.layer.masksToBounds = true
        self.view.addSubview(cameraView)
        
        // FaceView Setup
        faceView = FaceView(frame: CGRect(x: 8, y: 24, width: self.view.frame.size.width/4, height: self.view.frame.size.height/4))
        faceView.backgroundColor = .clear
        faceView.layer.zPosition = cameraView.layer.zPosition + 1
        if self.showDetection {
            self.view.addSubview(faceView)
        }
        
        // Manual Button Setup
        manualButton = StyleManager.shared.getButton(size: CGSize(width: self.view.frame.size.width/6, height: self.view.frame.size.width/6), center:  CGPoint(x: self.view.frame.size.width/2, y: self.view.frame.size.height/8), image: #imageLiteral(resourceName: "faceid"))
        manualButton.subButton()?.addTarget(self, action: #selector(scanUser), for: .touchUpInside)
        manualButton.layer.zPosition = self.interphoneTableView.layer.zPosition
        self.view.addSubview(manualButton)
        
        // Seatch TextField Setup
        searchTextField = CustomBuilder.makeTextField(width: self.view.frame.size.width*2/3, height: self.interphoneTableView.frame.size.height/9, placeholder: "Inserisci condomino da cercare", keyboardType: .alphabet, capitalized: false, isSecure: false)
        searchTextField.center = CGPoint(x: self.view.frame.size.width/2, y: self.view.frame.size.height - interphoneTableView.frame.size.height - searchTextField.frame.size.height)
        searchTextField.addTarget(self, action: #selector(textFieldDidChange), for: .editingChanged)
        self.view.addSubview(searchTextField)
        
        // Code Button Setup
        let codeButtonCenter = CGPoint(x: self.view.frame.size.width - self.view.frame.size.width/12 - 8, y: UIApplication.shared.statusBarFrame.height + 8 + self.view.frame.size.width/12)
        codeButton = StyleManager.shared.getButton(size: CGSize(width: self.view.frame.size.width/8, height: self.view.frame.size.width/8), center: codeButtonCenter, image: #imageLiteral(resourceName: "keypad"))
        codeButton.subButton()?.addTarget(self, action: #selector(goToCode), for: .touchUpInside)
        codeButton.layer.zPosition = self.interphoneTableView.layer.zPosition
        self.view.addSubview(codeButton)
        
//        codeButton = StyleManager.shared.getButton(size: CGSize(width: self.view.frame.size.width/3, height: self.view.frame.size.width/8), center: CGPoint(x: self.view.frame.size.width/2, y: self.view.frame.size.height - interphoneTableView.frame.height/3 + 32), text: "Accedi con Codice")
//        codeButton.subButton()?.addTarget(self, action: #selector(goToCode), for: .touchUpInside)
//        codeButton.layer.zPosition = self.interphoneTableView.layer.zPosition
//        self.view.addSubview(codeButton)
        // Settings Button Setup
        let settingsButtonCenter = CGPoint(x: self.view.frame.size.width - self.view.frame.size.width/12 - 8, y: self.view.frame.height - 8 - self.view.frame.size.width/12)
        settingsButton = StyleManager.shared.getButton(size: CGSize(width: self.view.frame.size.width/12, height: self.view.frame.size.width/12), center: settingsButtonCenter, image: #imageLiteral(resourceName: "settings"))
        settingsButton.backgroundColor = CustomColor.defaultBlue.uiColor()
        settingsButton.subButton()?.addTarget(self, action: #selector(goToSettings), for: .touchUpInside)
        settingsButton.layer.zPosition = self.interphoneTableView.layer.zPosition
        self.view.addSubview(settingsButton)
       
        
        // Countdown Timer Setup
        timerView = CountdownTimer(frame: CGRect(x: 0, y: 0, width: self.view.frame.size.width/8, height: self.view.frame.size.width/8))
        timerView.center = CGPoint(x: self.view.frame.size.width/2, y: self.view.frame.size.height/4)
        timerView.lineWidth = 3.0
        timerView.lineColor = .white
        timerView.trailLineColor = self.view.backgroundColor!
        timerView.backgroundColor = .clear
        timerView.isLabelHidden = true
        timerView.start(beginingValue: 0)
        timerView.delegate = self
        self.view.addSubview(timerView)
  
        
    }
    
    @objc func textFieldDidChange() {
        if self.searchTextField.text == "" {
            DataController().fetchData(entity: .user) {
                (outcome, results) in
                if outcome! {
                    self.users = results
                    self.interphoneTableView.reloadData()
                }
            }
        } else {
            DataController().fetchData(entity: .user, searchBy: [.nameOrSurname: self.searchTextField?.text as AnyObject]) {
                (outcome, results) in
                if outcome! {
                    self.users = results
                    self.interphoneTableView.reloadData()
                    
                }
            }
        }
    }
    
    @objc func goToCode() {
        performSegue(withIdentifier: "code-access", sender: nil)
    }
    
    @objc func goToSettings() {
       GSMessage.showMessageAddedTo("Questa funzionalità non è momentaneamente disponibile", type: .warning, options: [.height(100), .textNumberOfLines(2),.position(.bottom)], inView: self.view, inViewController: self)
    }
    
    @objc func scanUser() {
        self.classifyCurrentFrame(frame: self.stillPhoto)
        self.justScanned = true
        let myContext = LAContext()
        let myLocalizedReasonString = "Posizionati di fronte alla fotocamera per la scansione"
        
        var authError: NSError?
        if #available(iOS 8.0, macOS 10.12.1, *) {
            if myContext.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &authError) {
                myContext.evaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, localizedReason: myLocalizedReasonString) { success, evaluateError in
                    
                    DispatchQueue.main.async {
                        if success {
                            // User authenticated successfully, take appropriate action
                            
                            //test senza modulo bluetooth: commentare 
                            //GSMessage.showMessageAddedTo("Grazie \(self.currentUserName)\nAccesso effettuato con successo", type: .success, options: [.height(100), .textNumberOfLines(2)], inView: self.view, inViewController: self)
                            
                            if UserDefaults.standard.bool(forKey: "deviceConnected") {
                                GSMessage.showMessageAddedTo("Grazie \(self.currentUserName)\nAccesso effettuato con successo", type: .success, options: [.height(100), .textNumberOfLines(2)], inView: self.view, inViewController: self)
                            }
                            
                            self.timerView.start(beginingValue: 10)
                            self.sendToDevice(textToSend: "apri", completion: {})
                            
                        } else {
                            // User did not authenticate successfully, look at error and take appropriate action
                            GSMessage.showMessageAddedTo("Accesso fallito, prova con codice", type: .error, options: [.height(100), .textNumberOfLines(2)], inView: self.view, inViewController: self)
                            
                            self.justScanned = true
                            // Call Code Access ViewController
                            let message = "Effettuare l'accesso con codice?"
                            let alert = UIAlertController(title: "Accesso", message: message, preferredStyle: UIAlertController.Style.alert)
                            alert.addAction(UIAlertAction(title: "Sì", style: UIAlertAction.Style.default, handler: { [unowned self] (action: UIAlertAction!) in
                                self.performSegue(withIdentifier: "code-access", sender: nil)
                            }))

                            alert.addAction(UIAlertAction(title: "No", style: .cancel, handler: { [unowned self] (action: UIAlertAction!) in
                                self.timerView.start(beginingValue: 3)
                            }))
                            self.present(alert, animated: true, completion: nil)
                        }
                    }
                }
            } else {
                // Could not evaluate policy; look at authError and present an appropriate message to user
                GSMessage.showMessageAddedTo("Non è possibile effettuare la scansione", type: .error, options: [.height(100), .textNumberOfLines(2)], inView: self.view, inViewController: self)
            }
        } else {
            // Fallback on earlier versions
            
            GSMessage.showMessageAddedTo("Funzione di scansione non supportata", type: .error, options: [.height(100), .textNumberOfLines(2)], inView: self.view, inViewController: self)
        }
    }
    
    // Core ML Methods
    
    // Classification method.
    func classify(_ image: CGImage) {
        DispatchQueue.global(qos: .userInitiated).async {
            let handler = VNImageRequestHandler(cgImage: image)
            do {
                try handler.perform([self.classificationRequest])
            } catch {
                /*
                 This handler catches general image processing errors. The `classificationRequest`'s
                 completion handler `processClassifications(_:error:)` catches errors specific
                 to processing that request.
                 */
                print("Failed to perform classification.\n\(error.localizedDescription)")
            }
        }
    }
    
    func classifyCurrentFrame(frame: UIImage) {
        let cgImage = frame.cgImage!
        classify(cgImage)
    }
    
    // Convenience method for closing the TableView.
    func push(data: [VNClassificationObservation]) {
        for res in data {
            print("\(res.identifier) \(res.confidence)")
        }
        let orderedData = data.sorted(by: ({
            (a, b) -> Bool in
            return a.confidence > b.confidence
        }))
        if let first = orderedData.first {
            DataController().fetchData(entity: .user, searchBy: [.modelIdentifier: first.identifier as AnyObject]) {
                (outcome, results) in
                if outcome! {
                    self.currentUserName = results.first?["name"] as! String
                }
            }
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if let touch = touches.first {
            let location = touch.location(in: self.view)
            if location.x < self.view.frame.size.width/4 && location.y < self.view.frame.size.height/4 {
                self.showDetection = !self.showDetection
                if showDetection {
                    self.view.addSubview(faceView)
                } else {
                    self.faceView.removeFromSuperview()
                }
            }
        }
    }
    
    func timerDidEnd() {
        self.justScanned = false
    }
    
    func configureCaptureSession() {
        // Define the capture device we want to use
        guard let camera = AVCaptureDevice.default(.builtInWideAngleCamera,
                                                   for: .video,
                                                   position: .front) else {
                                                    //fatalError("No front video camera available")
                                                    print("No front video camera available")
                                                    return
        }
        
        // Connect the camera to the capture session input
        do {
            let cameraInput = try AVCaptureDeviceInput(device: camera)
            session.addInput(cameraInput)
        } catch {
            fatalError(error.localizedDescription)
        }
        
        // Create the video data output
        let videoOutput = AVCaptureVideoDataOutput()
        videoOutput.setSampleBufferDelegate(self, queue: dataOutputQueue)
        videoOutput.videoSettings = [kCVPixelBufferPixelFormatTypeKey as String: kCVPixelFormatType_32BGRA]
        
        // Add the video output to the capture session
        session.addOutput(videoOutput)
        
        let videoConnection = videoOutput.connection(with: .video)
        videoConnection?.videoOrientation = .portrait
        
        // Configure the preview layer
        previewLayer = AVCaptureVideoPreviewLayer(session: session)
        previewLayer.videoGravity = .resizeAspectFill
        // Modifica della finestra
        previewLayer.frame = cameraView.bounds
        cameraView.layer.insertSublayer(previewLayer, at: 0)
    }
}

extension AccessScreenViewController: AVCaptureVideoDataOutputSampleBufferDelegate {
    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        guard let imageBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else {
            return
        }
        
        guard let image = getImageFromSampleBuffer(sampleBuffer) else {
            return
        }
        
        // Save UIImage got from buffer in an accessible variable
        self.stillPhoto = image
        
        let detectFaceRequest = VNDetectFaceLandmarksRequest(completionHandler: detectedFace)
        
        do {
            try sequenceHandler.perform(
                [detectFaceRequest],
                on: imageBuffer,
                orientation: .leftMirrored)
        } catch {
            print(error.localizedDescription)
        }
    }
    
    func getImageFromSampleBuffer(_ sampleBuffer: CMSampleBuffer) -> UIImage? {
        guard let pixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else {
            return nil
        }
        CVPixelBufferLockBaseAddress(pixelBuffer, .readOnly)
        let baseAddress = CVPixelBufferGetBaseAddress(pixelBuffer)
        let width = CVPixelBufferGetWidth(pixelBuffer)
        let height = CVPixelBufferGetHeight(pixelBuffer)
        let bytesPerRow = CVPixelBufferGetBytesPerRow(pixelBuffer)
        let colorSpace = CGColorSpaceCreateDeviceRGB()
        let bitmapInfo = CGBitmapInfo(rawValue: CGImageAlphaInfo.premultipliedFirst.rawValue | CGBitmapInfo.byteOrder32Little.rawValue)
        guard let context = CGContext(data: baseAddress, width: width, height: height, bitsPerComponent: 8, bytesPerRow: bytesPerRow, space: colorSpace, bitmapInfo: bitmapInfo.rawValue) else {
            return nil
        }
        guard let cgImage = context.makeImage() else {
            return nil
        }
        let image = UIImage(cgImage: cgImage, scale: 1, orientation:.right)
        CVPixelBufferUnlockBaseAddress(pixelBuffer, .readOnly)
        return image
    }
    
}

extension AccessScreenViewController {
    func convert(rect: CGRect) -> CGRect {
        let origin = previewLayer.layerPointConverted(fromCaptureDevicePoint: rect.origin)
        
        let size = previewLayer.layerPointConverted(fromCaptureDevicePoint: rect.size.cgPoint)
        
        return CGRect(origin: origin, size: size.cgSize)
    }
    
    func landmark(point: CGPoint, to rect: CGRect) -> CGPoint {
        let absolute = point.absolutePoint(in: rect)
        
        let converted = previewLayer.layerPointConverted(fromCaptureDevicePoint: absolute)
        
        return converted
    }
    
    func landmark(points: [CGPoint]?, to rect: CGRect) -> [CGPoint]? {
        guard let points = points else {
            return nil
        }
        
        return points.compactMap { landmark(point: $0, to: rect) }
    }
    
    func updateFaceView(for result: VNFaceObservation) {
        defer {
            DispatchQueue.main.async {
                self.faceView.setNeedsDisplay()
            }
        }
        
        let box = result.boundingBox
        faceView.boundingBox = convert(rect: box)
        
        guard let landmarks = result.landmarks else {
            return
        }
        
        if let leftEye = landmark(
            points: landmarks.leftEye?.normalizedPoints,
            to: result.boundingBox) {
            faceView.leftEye = leftEye
        }
        
        if let rightEye = landmark(
            points: landmarks.rightEye?.normalizedPoints,
            to: result.boundingBox) {
            faceView.rightEye = rightEye
        }
        
        if let leftEyebrow = landmark(
            points: landmarks.leftEyebrow?.normalizedPoints,
            to: result.boundingBox) {
            faceView.leftEyebrow = leftEyebrow
        }
        
        if let rightEyebrow = landmark(
            points: landmarks.rightEyebrow?.normalizedPoints,
            to: result.boundingBox) {
            faceView.rightEyebrow = rightEyebrow
        }
        
        if let nose = landmark(
            points: landmarks.nose?.normalizedPoints,
            to: result.boundingBox) {
            faceView.nose = nose
        }
        
        if let outerLips = landmark(
            points: landmarks.outerLips?.normalizedPoints,
            to: result.boundingBox) {
            faceView.outerLips = outerLips
        }
        
        if let innerLips = landmark(
            points: landmarks.innerLips?.normalizedPoints,
            to: result.boundingBox) {
            faceView.innerLips = innerLips
        }
        
        if let faceContour = landmark(
            points: landmarks.faceContour?.normalizedPoints,
            to: result.boundingBox) {
            faceView.faceContour = faceContour
        }
    }
    
    func detectedFace(request: VNRequest, error: Error?) {
        guard
            let results = request.results as? [VNFaceObservation],
            let result = results.first
            else {
                faceView.clear()
                return
        }
        
        updateFaceView(for: result)
        
        let devConnected = UserDefaults.standard.bool(forKey: "deviceConnected")
        
        //test senza modulo bluetooth
        /*
        if !justScanned && isAccessScreenActive {
            justScanned = true
            scanUser()
        }*/
       
        if !justScanned && isAccessScreenActive && devConnected {
            justScanned = true
            scanUser()
        }
    }
}
