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
                    CameraView(frameSize: size, session: $session)
                    
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
            
        }
    }
    
    ///Activating Scanning Animation Method
    func activateScannerAnimation() {
        //Adding Delay for Each Reversal
        withAnimation(.easeInOut(duration: 0.85).delay(0.1).repeatForever(autoreverses: true)) {
            isScanning = true
        }
    }
    
    ///Checking Camera Permission
    func checkCameraPermission() {
        Task {
            switch AVCaptureDevice.authorizationStatus(for: .video) {
            case .authorized:
                cameraPermission = .approved
            case .notDetermined:
                ///Requesting Camera Access
                if await AVCaptureDevice.requestAccess(for: .video) {
                    ///Permission Granted
                    cameraPermission = .approved
                } else {
                    ///Permission Denied
                    cameraPermission = .denied
                }
            case .denied, .restricted:
                cameraPermission = .denied
            default: break
                
            }
        }
    }
}

//MARK: - PREVIEW
struct ScannerView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
