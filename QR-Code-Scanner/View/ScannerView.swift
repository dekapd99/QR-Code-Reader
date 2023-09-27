//
//  ScannerView.swift
//  QR-Code-Scanner
//
//  Created by Deka Primatio on 26/09/23.
//

import SwiftUI
import AVKit

struct ScannerView: View {
    ///QR Code Scanner Properties
    @State private var isScanning: Bool = false
    @State private var session: AVCaptureSession = .init()
    @State private var cameraPermission: Permission = .idle
    ///QR Scanner AV Output
    @State private var qrOutput: AVCaptureMetadataOutput = .init()
    ///Error Properties
    @State private var errorMessage: String = ""
    @State private var showError: Bool = false
    @Environment(\.openURL) private var openURL
    ///Camera QR Output Delegate
    @StateObject private var qrDelegate = QRScannerDelegate()
    ///Scanned Code
    @State private var scannedCode: String = ""
    
    var body: some View {
        VStack(spacing: 8) {
            Button {
                
            } label: {
                Image(systemName: "xmark.circle")
                    .font(.title3)
                    .foregroundColor(.accentColor)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            
            Text("Place the QR code inside the area")
                .font(.title3)
                .foregroundColor(.black.opacity(0.8))
                .padding(.top, 20)
            
            Text("Scanning will start automatically")
                .font(.callout)
                .foregroundColor(.gray)
            
            Spacer(minLength: 0)
            
            //Scanner
            GeometryReader {
                let size = $0.size
                
                ZStack {
                    CameraView(frameSize: CGSize(width: size.width, height: size.width), session: $session)
                    //Making it Little Smaller
                        .scaleEffect(0.97)
                    
                    ForEach(0...4, id: \.self) { index in
                        let rotation = Double(index) * 90
                        
                        RoundedRectangle(cornerRadius: 2, style: .circular)
                            ///Trimming to Get Scanner Like Edges
                            .trim(from: 0.61, to: 0.64)
                            .stroke(Color.blue, style: StrokeStyle(lineWidth: 5, lineCap: .round, lineJoin: .round))
                            .rotationEffect(.init(degrees: rotation))
                    }
                }
                ///Square Shape
                .frame(width: size.width, height: size.width)
                ///Scanner Animation
                .overlay(alignment: .top, content: {
                    Rectangle()
                        .fill(Color.blue)
                        .frame(height: 2.5)
                        .shadow(color: .black.opacity(0.8), radius: 8, x: 0, y: isScanning ? 15 : -15)
                        .offset(y: isScanning ? size.width : 0)
                })
                
                ///To Make it Center
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
            .padding(.horizontal, 45)
            
            Spacer(minLength: 15)
            
            Button {
                if !session.isRunning && cameraPermission == .approved {
                    reactivateCamera()
                    activateScannerAnimation()
                }
            } label: {
                Image(systemName: "qrcode.viewfinder")
                    .font(.largeTitle)
                    .foregroundColor(.gray)
            }
            
            Spacer(minLength: 45)
        }
        .padding(15)
        ///Checking Camera Permission, when the View is Visible
        .onAppear(perform: checkCameraPermission)
        .alert(errorMessage, isPresented: $showError) {
            ///Showing Setting's Button, if permission is denied
            if cameraPermission == .denied {
                Button("Settings") {
                    let settingsString = UIApplication.openSettingsURLString
                    if let settingsURL = URL(string: settingsString) {
                        ///Opening App's Setting, Using openURL SwiftUI API
                        openURL(settingsURL)
                    }
                }
                
                ///Along with Cancel Button
                Button("Cancel", role: .cancel) {
                    
                }
            }
        }
        .onChange(of: qrDelegate.scannedCode) { newValue in
            if let code = newValue {
                scannedCode = code
                ///When the First Code Scan is Available, immediately stop the Camera
                session.stopRunning()
                ///Stopping Scanner Animation
                deActivateScannerAnimation()
                ///Clearing the Data on Delegate
                qrDelegate.scannedCode = nil
            }
        }
    }
    ///
    func reactivateCamera() {
        DispatchQueue.global(qos: .background).async {
            session.startRunning()
        }
    }
    
    ///Activating Scanning Animation Method
    func activateScannerAnimation() {
        //Adding Delay for Each Reversal
        withAnimation(.easeInOut(duration: 0.85).delay(0.1).repeatForever(autoreverses: true)) {
            isScanning = true
        }
    }
    
    ///De-Activating Scanning Animation Method
    func deActivateScannerAnimation() {
        //Adding Delay for Each Reversal
        withAnimation(.easeInOut(duration: 0.85)) {
            isScanning = false
        }
    }
    
    ///Checking Camera Permission
    func checkCameraPermission() {
        Task {
            switch AVCaptureDevice.authorizationStatus(for: .video) {
            case .authorized:
                cameraPermission = .approved
                if session.inputs.isEmpty {
                    //New Setup
                    setupCamera()
                } else {
                    ///Already Existing One
                    session.startRunning()
                }
            case .notDetermined:
                ///Requesting Camera Access
                if await AVCaptureDevice.requestAccess(for: .video) {
                    ///Permission Granted
                    cameraPermission = .approved
                    setupCamera()
                } else {
                    ///Permission Denied
                    cameraPermission = .denied
                    ///Presenting Error Message
                    presentError("Please Provide Access to Camera for Scanning Codes")
                }
            case .denied, .restricted:
                cameraPermission = .denied
                presentError("Please Provide Access to Camera for Scanning Codes")
            default: break
                
            }
        }
    }
    ///Setting Up Camera
    func setupCamera() {
        do {
            ///Finding Back Camera
            guard let device = AVCaptureDevice.DiscoverySession(deviceTypes: [.builtInWideAngleCamera], mediaType: .video, position: .back).devices.first else {
                presentError("Unknown Device Error")
                return
            }
            
            ///Camera Input
            let input = try AVCaptureDeviceInput(device: device)
            ///For Extra Safety
            ///Checking Whether Input & Output Can Be Added to the Session
            guard session.canAddInput(input), session.canAddOutput(qrOutput) else {
                presentError("Unknown Input/Output Error")
                return
            }
            
            ///Adding Input & Output to Camera Session
            session.beginConfiguration()
            session.addInput(input)
            session.addOutput(qrOutput)
            ///Setting Output Config to Read QR Codes
            qrOutput.metadataObjectTypes = [.qr]
            ///Adding Delegate to Retreive the Fetched QR Code from Camera
            qrOutput.setMetadataObjectsDelegate(qrDelegate, queue: .main)
            session.commitConfiguration()
            ///Note Session must Started on Background Thread
            DispatchQueue.global(qos: .background).async {
                session.startRunning()
            }
            activateScannerAnimation()
        } catch {
            presentError(error.localizedDescription)
        }
    }
    
    ///Presenting Error
    func presentError(_ message: String) {
        errorMessage = message
        showError.toggle()
    }
    
}

//MARK: - PREVIEW
struct ScannerView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
