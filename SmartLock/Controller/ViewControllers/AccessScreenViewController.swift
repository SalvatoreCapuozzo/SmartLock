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

class AccessScreenViewController: AppViewController, UITableViewDelegate, UITableViewDataSource {
    var interphoneTableView: UITableView!
    var sequenceHandler = VNSequenceRequestHandler()
    var faceView: FaceView!
    var cameraView: UIView!
    var searchTextField: UITextField!
    var manualButton: UIView!
    var codeButton: UIButton!
    
    let session = AVCaptureSession()
    var previewLayer: AVCaptureVideoPreviewLayer!
    var showDetection: Bool = false
    
    let dataOutputQueue = DispatchQueue(
        label: "video data queue",
        qos: .userInitiated,
        attributes: [],
        autoreleaseFrequency: .workItem)
    
    var isAccessScreenActive: Bool = false
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUserInterface(type: 3)
        
        self.isAccessScreenActive = true
        
        configureCaptureSession()
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(tappedOnScreen))
        self.view.addGestureRecognizer(tapGesture)
        
        session.startRunning()
        
        DataController().deleteData(entityName: "User")
        
        DataController().addUser(name: "Maria Luisa", surname: "Farina", code: "270693", isFamily: true, isManager: false)
        DataController().addUser(name: "Salvatore", surname: "Capuozzo", code: "190596", isFamily: true, isManager: true)
 
        DataController().addUser(name: "Filippo", surname: "Ferrandino", code: "123456", isFamily: true, isManager: false)
        DataController().addUser(name: "Federica", surname: "Ventriglia", code: "789012", isFamily: true, isManager: false)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.isAccessScreenActive = true
        
        DataController().fetchData(entityName: "User") {
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
    
    override func setupUserInterface(type: Int) {
        super.setupUserInterface(type: type)
        // Interphone TableView Setup
        interphoneTableView = UITableView(frame: CGRect(x: 0, y: 0, width: self.view.frame.size.width*2/3, height: self.view.frame.size.height*3/5))
        interphoneTableView.center = CGPoint(x: self.view.frame.size.width/2, y: self.view.frame.size.height - interphoneTableView.frame.size.height/2 - 16)
        interphoneTableView.backgroundColor = .clear
        
        interphoneTableView.layer.cornerRadius = 20
        interphoneTableView.layer.masksToBounds = true
        interphoneTableView.layer.borderColor = UIColor.white.cgColor
        interphoneTableView.layer.borderWidth = 5
        
        self.view.addSubview(interphoneTableView)
        
        self.interphoneTableView.delegate = self
        self.interphoneTableView.dataSource = self
        
        self.interphoneTableView.separatorColor = .clear
        self.interphoneTableView.separatorStyle = .none
        
        interphoneTableView.register(InterphoneTableViewCell.self, forCellReuseIdentifier: "reuseIdentifier")
        
        codeButton = UIButton(frame: CGRect(x: self.view.frame.size.width - self.view.frame.size.width/10 - 8, y: UIApplication.shared.statusBarFrame.height + 8, width: self.view.frame.size.width/10, height: self.view.frame.size.width/10))
        codeButton.setImage(UIImage.init(named: "keypad")?.withRenderingMode(.alwaysTemplate), for: .normal)
        codeButton.imageView?.tintColor = .white
        codeButton.addTarget(self, action: #selector(goToCode), for: .touchUpInside)
        self.view.addSubview(codeButton)
        
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
        
        // Seatch TextField Setup
        searchTextField = CustomBuilder.makeTextField(width: self.view.frame.size.width*2/3, height: self.interphoneTableView.frame.size.height/9, placeholder: "Inserisci condomino da cercare", keyboardType: .alphabet, capitalized: false, isSecure: false)
        searchTextField.center = CGPoint(x: self.view.frame.size.width/2, y: self.view.frame.size.height - interphoneTableView.frame.size.height - searchTextField.frame.size.height)
        searchTextField.addTarget(self, action: #selector(textFieldDidChange), for: .editingChanged)
        self.view.addSubview(searchTextField)
        
        // Background Setup
        switch type {
        case 1:
            // Green Gradient
            manualButton = CustomBuilder.makeButton(width: self.view.frame.size.width/6, height: self.view.frame.size.width/6, text: "", color: UIColor(red: 0/255, green: 255/255, blue: 128/255, alpha: 1), textColor: .clear)
            manualButton.center = CGPoint(x: self.view.frame.size.width/2, y: self.view.frame.size.height/8)
            manualButton.layer.cornerRadius = manualButton.frame.size.height/4
            manualButton.layer.zPosition = self.interphoneTableView.layer.zPosition
            let faceid = #imageLiteral(resourceName: "faceid").withRenderingMode(.alwaysTemplate)
            manualButton.subButton()?.setImage(faceid, for: .normal)
            manualButton.subButton()?.imageEdgeInsets = UIEdgeInsets(top: 8, left: 8, bottom: 8, right: 8)
            manualButton.subButton()?.imageView!.contentMode = .scaleAspectFit
            manualButton.subButton()?.tintColor = .white
            manualButton.subButton()?.addTarget(self, action: #selector(scanUser), for: .touchUpInside)
            self.view.addSubview(manualButton)
        case 2:
            // Green Waves
            manualButton = CustomBuilder.makeButton(width: self.view.frame.size.width/6, height: self.view.frame.size.width/6, text: "", color: CustomColor.leafGreen.uiColor(), textColor: .clear)
            manualButton.center = CGPoint(x: self.view.frame.size.width/2, y: self.view.frame.size.height/8)
            manualButton.layer.cornerRadius = manualButton.frame.size.height/4
            manualButton.layer.zPosition = self.interphoneTableView.layer.zPosition
            let faceid = #imageLiteral(resourceName: "faceid").withRenderingMode(.alwaysTemplate)
            manualButton.subButton()?.setImage(faceid, for: .normal)
            manualButton.subButton()?.imageEdgeInsets = UIEdgeInsets(top: 8, left: 8, bottom: 8, right: 8)
            manualButton.subButton()?.imageView!.contentMode = .scaleAspectFit
            manualButton.subButton()?.tintColor = .white
            manualButton.subButton()?.addTarget(self, action: #selector(scanUser), for: .touchUpInside)
            self.view.addSubview(manualButton)
        case 3:
            // Blue Waves
            manualButton = CustomBuilder.makeButton(width: self.view.frame.size.width/6, height: self.view.frame.size.width/6, text: "", color: CustomColor.sparklingBlue.uiColor(), textColor: .clear)
            manualButton.center = CGPoint(x: self.view.frame.size.width/2, y: self.view.frame.size.height/8)
            manualButton.layer.cornerRadius = manualButton.frame.size.height/4
            manualButton.layer.zPosition = self.interphoneTableView.layer.zPosition
            let faceid = #imageLiteral(resourceName: "faceid").withRenderingMode(.alwaysTemplate)
            manualButton.subButton()?.setImage(faceid, for: .normal)
            manualButton.subButton()?.imageEdgeInsets = UIEdgeInsets(top: 8, left: 8, bottom: 8, right: 8)
            manualButton.subButton()?.imageView!.contentMode = .scaleAspectFit
            manualButton.subButton()?.tintColor = .white
            manualButton.subButton()?.addTarget(self, action: #selector(scanUser), for: .touchUpInside)
            self.view.addSubview(manualButton)
            
            codeButton.tintColor = CustomColor.sparklingBlue.uiColor()
        default:
            print("Invalid type")
        }
    }
    
    @objc func textFieldDidChange() {
        if self.searchTextField.text == "" {
            DataController().fetchData(entityName: "User") {
                (outcome, results) in
                if outcome! {
                    self.users = results
                    self.interphoneTableView.reloadData()
                }
            }
        } else {
            DataController().fetchData(entityName: "User", searchBy: [.nameOrSurname: self.searchTextField?.text as AnyObject]) {
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
    
    @objc func scanUser() {
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
                            GSMessage.showMessageAddedTo("Accesso effettuato con successo", type: .success, options: [.height(100), .textNumberOfLines(2)], inView: self.view, inViewController: self)
                            
                            self.sendToDevice(textToSend: "apri", completion: {})
                            
                            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 10.0) {
                                self.justScanned = false
                            }
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
                                DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 2.0) {
                                    self.justScanned = false
                                }
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
        
        if !justScanned && isAccessScreenActive {
            justScanned = true
            scanUser()
        }
    }
}
