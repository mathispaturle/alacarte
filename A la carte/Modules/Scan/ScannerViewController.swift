//
//  ScannerViewController.swift
//  A la carte
//
//  Created by Sopra on 23/02/2021.
//

import AVFoundation
import UIKit
import PureLayout

class ScannerViewController: UIViewController, AVCaptureMetadataOutputObjectsDelegate {
    
    private enum Segues {
        static let results = "showResults"
    }
    
    var captureSession: AVCaptureSession!
    var previewLayer: AVCaptureVideoPreviewLayer!
    var detectionView = UIView()

    override func viewDidLoad() {
        super.viewDidLoad()
        performSegue(withIdentifier: Segues.results, sender: "oEmetjIYIwbMRf6xspPOioBNSIO2-fE0E8pu9CAO8M9PXceCF")
//        setupScanner()
//        addOverlay()
    }

    func setupScanner() {
        view.backgroundColor = UIColor.black
        captureSession = AVCaptureSession()

        guard let videoCaptureDevice = AVCaptureDevice.default(for: .video) else { return }
        let videoInput: AVCaptureDeviceInput

        do {
            videoInput = try AVCaptureDeviceInput(device: videoCaptureDevice)
        } catch {
            return
        }

        if (captureSession.canAddInput(videoInput)) {
            captureSession.addInput(videoInput)
        } else {
            failed()
            return
        }

        let metadataOutput = AVCaptureMetadataOutput()

        if (captureSession.canAddOutput(metadataOutput)) {
            captureSession.addOutput(metadataOutput)

            metadataOutput.setMetadataObjectsDelegate(self, queue: DispatchQueue.main)
            metadataOutput.metadataObjectTypes = [.qr]
        } else {
            failed()
            return
        }

        previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        previewLayer.frame = view.bounds
        previewLayer.videoGravity = .resizeAspectFill
        view.layer.addSublayer(previewLayer)

        captureSession.startRunning()
    }
    
    func failed() {
        let ac = UIAlertController(title: "Scanning not supported", message: "Your device does not support scanning a code from an item. Please use a device with a camera.", preferredStyle: .alert)
        ac.addAction(UIAlertAction(title: "OK", style: .default))
        present(ac, animated: true)
        captureSession = nil
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        if captureSession?.isRunning == false {
            captureSession.startRunning()
        }
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)

        if captureSession?.isRunning == true {
            captureSession.stopRunning()
        }
    }

    func metadataOutput(_ output: AVCaptureMetadataOutput, didOutput metadataObjects: [AVMetadataObject], from connection: AVCaptureConnection) {
        captureSession.stopRunning()

        if let metadataObject = metadataObjects.first {
            guard let readableObject = metadataObject as? AVMetadataMachineReadableCodeObject else { return }
            guard let stringValue = readableObject.stringValue else { return }
            AudioServicesPlaySystemSound(SystemSoundID(kSystemSoundID_Vibrate))
            found(code: stringValue)
        }

        dismiss(animated: true)
    }

    func found(code: String) {
        print(code)
        performSegue(withIdentifier: Segues.results, sender: code)
    }

    override var prefersStatusBarHidden: Bool {
        return true
    }

    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return .portrait
    }
    
    // MARK: Overlay scan methods
    func addOverlay() {
        detectionView = createOverlay()
        view.addSubview(detectionView)
        createSubview()
    }

    func createOverlay() -> UIView {
        let overlayView = UIView(frame: view.frame)
        overlayView.backgroundColor = .white

        let path = CGMutablePath()

        path.addRoundedRect(in: CGRect(x: 0,
                                       y: 0,
                                       width: overlayView.frame.width,
                                       height: overlayView.frame.height), cornerWidth: 0, cornerHeight:0)

        path.closeSubpath()

        let shape = CAShapeLayer()
        shape.path = path
        shape.lineWidth = 0.2
        shape.strokeColor = UIColor.light.cgColor
        shape.fillColor = UIColor.light.cgColor

        overlayView.layer.addSublayer(shape)

        path.addRect(CGRect(origin: .zero, size: overlayView.frame.size))

        let maskLayer = CAShapeLayer()
        maskLayer.backgroundColor = UIColor.black.cgColor
        maskLayer.path = path
        maskLayer.fillRule = CAShapeLayerFillRule.evenOdd

        overlayView.layer.mask = maskLayer
        overlayView.clipsToBounds = true

        let cornersView = CornersView(frame: CGRect(
                                        x: BarCodeConstants.safeDistanceOverlay + BarCodeConstants.paddingCornersLayer,
                                        y: overlayView.center.y - BarCodeConstants.overlayHalfHeight + BarCodeConstants.paddingCornersLayer,
                                        width: overlayView.frame.width - BarCodeConstants.overlayWidth - 2 * BarCodeConstants.paddingCornersLayer,
                                        height: overlayView.frame.width - BarCodeConstants.overlayWidth - 2 * BarCodeConstants.paddingCornersLayer))
        
        cornersView.color = .white
        cornersView.thickness = 12
        cornersView.backgroundColor = .clear
        cornersView.radius = 0
        view.addSubview(cornersView)
        return overlayView
    }
    
    private enum BarCodeConstants {
        static let exitButtonHeight = CGFloat(44)
        static let exitButtonWidth = CGFloat(44)
        static let safeDistanceExitButtonX = CGFloat(10)
        static let safeDistanceExitButtonY = CGFloat(20)
        static let safeDistanceOverlay = CGFloat(40)
        static let overlayHalfHeight = CGFloat(130)
        static let overlayWidth = CGFloat(80)
        static let cornerHeight = CGFloat(0)
        static let cornerWidth = CGFloat(0)
        static let safeDistanceLabelX = CGFloat(20)
        static let topDistanceFrameLabel = CGFloat(60)
        static let paddingLabel = CGFloat(15)
        static let paddingCornersLayer = CGFloat(16)
    }
    
    private func createSubview() {
        let header = UIView(forAutoLayout: ())
        view.addSubview(header)
        header.autoPinEdge(.top, to: .top, of: view, withOffset: BarCodeConstants.safeDistanceOverlay)
        header.autoPinEdge(.leading, to: .leading, of: view)
        header.autoPinEdge(.trailing, to: .trailing, of: view)
        
        let dismiss = UIImageView(forAutoLayout: ())
        dismiss.image = UIImage(systemName: "xmark")
        dismiss.tintColor = .white
        
        let gesture = UITapGestureRecognizer(target: self, action: #selector(closeScreen(_:)))
        dismiss.addGestureRecognizer(gesture)
        dismiss.isUserInteractionEnabled = true
        header.addSubview(dismiss)
        
        dismiss.autoSetDimensions(to: CGSize(width: 24, height: 24))
        dismiss.autoPinEdge(.top, to: .top, of: header, withOffset: 32)
        dismiss.autoPinEdge(.leading, to: .leading, of: header, withOffset: 32)
        
        
    }
    
    @objc func closeScreen(_ sender: UITapGestureRecognizer) {
        dismiss(animated: true, completion: nil)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == Segues.results {
            let targetController = segue.destination as! ResultsViewController
            
            if let sender = sender as? String {
                targetController.qrQuery = sender
            }
        }
    }
}

