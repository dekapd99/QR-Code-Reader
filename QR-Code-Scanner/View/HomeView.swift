//
//  RoomCode.swift
//  QR-Code-Scanner
//
//  Created by Deka Primatio on 27/09/23.
//

import SwiftUI

struct HomeView: View {
    var body: some View {
        VStack {
            Spacer()
            
            HStack {
                Text("Room")
                    .font(.system(size: 15, weight: .semibold))
                
                Spacer()
                
                Text("RECEPTIONIST")
                    .fontWeight(.bold)
            }
            .padding()
            .background(Color(.lightGray))
            
            Spacer()
            
            Text("19:30")
                .font(.system(size: 40, weight: .bold))
            
            Spacer()
            
            HStack {
                Spacer()
                
                VStack(spacing: 10) {
                    Image(systemName: "qrcode.viewfinder")
                        .font(.system(size: 45))
                    Text("Scan")
                        .font(.system(size: 15, weight: .semibold))
                }
                .background(RoundedRectangle(cornerRadius: 10, style: .circular)
                    .fill(Color(.lightGray))
                    .frame(width: 117, height: 107)
                )

                
                Spacer()
                
                VStack(spacing: 10) {
                    Image(systemName: "questionmark.circle")
                        .font(.system(size: 45))
                    Text("Hint")
                        .font(.system(size: 15, weight: .semibold))
                }
                .background(RoundedRectangle(cornerRadius: 10, style: .circular)
                    .fill(Color(.lightGray))
                    .frame(width: 117, height: 107)
                )
                
                Spacer()
            }
            
            Spacer()
            
            HStack {
                Spacer()
                
                VStack(spacing: 10) {
                    Image(systemName: "mic.fill")
                        .font(.system(size: 35))
                    Text("Voice Input")
                        .font(.system(size: 15, weight: .semibold))
                }
                .background(RoundedRectangle(cornerRadius: 10, style: .circular)
                    .fill(Color(.lightGray))
                    .frame(width: 117, height: 107)
                )
                
                Spacer()
                
                VStack(spacing: 10) {
                    Image(systemName: "wand.and.stars.inverse")
                        .font(.system(size: 45))
                    Text("Abilities")
                        .font(.system(size: 15, weight: .semibold))
                }
                .background(RoundedRectangle(cornerRadius: 10, style: .circular)
                    .fill(Color(.lightGray))
                    .frame(width: 117, height: 107)
                )
                
                Spacer()
            }
            
            Spacer()
            
            Spacer()
        }
    }
}

struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        HomeView()
    }
}
