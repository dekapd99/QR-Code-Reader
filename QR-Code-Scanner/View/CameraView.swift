//
//  CameraView.swift
//  QR-Code-Scanner
//
//  Created by Deka Primatio on 26/09/23.
//

import SwiftUI
import AVKit

///Camera View Using AVCaptureVideoPreviewLayer
struct CameraView: UIViewRepresentable {
    var frameSize: CGSize
    ///Camera Session
    @Binding var session: AVCaptureSession
    
    ///Defining Camera Frame Size
    func makeUIView(context: Context) -> UIView {
        let view = UIView(frame: CGRect(origin: .zero, size: frameSize))
        view.backgroundColor = .clear
        
        let cameraLayer = AVCaptureVideoPreviewLayer(session: session)
        cameraLayer.frame = .init(origin: .zero, size: frameSize)
        cameraLayer.videoGravity = .resizeAspectFill
        cameraLayer.masksToBounds = true
        view.layer.addSublayer(cameraLayer)
        
        return view
    }
    
    ///Update UI
    func updateUIView(_ uiView: UIViewType, context: Context) {
        
    }
}
