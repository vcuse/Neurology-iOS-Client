//
//  HomeView.swift
//  Neurology-iOS-Client-App
//
//  Created by Lauren Viado on 7/31/24.
//

import SwiftUI

struct HomeView: View {
    var onlineUsers = ["34680986443", "7492082646", "8827649022"]
    
    var body: some View {
        VStack {
            Text("Hello, user!")
                .font(/*@START_MENU_TOKEN@*/.title/*@END_MENU_TOKEN@*/)
                .bold()
                .padding(10)
            Text("Your Peer ID: blah blah blah")
                .bold()
            Text("Online Now:")
                .font(.headline)
                .padding(10)
            
            VStack(alignment: .leading) {
                if onlineUsers.isEmpty {
                    Text("Hmm, nobody's here right now!")
                        .padding()
                        .background(Color.yellow)
                        .cornerRadius(10)
                        .shadow(radius: 5)
                } else {
                    VStack(alignment: .leading) {
                        ForEach(onlineUsers, id: \.self) { user in
                            OnlineUserItemView(uuid: user)
                        }
                    }
                    .background(Color.yellow)
                    .cornerRadius(10)
                    .shadow(radius: 5)
                }
            }
            .padding(10)
            
            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        .padding()
    }
}

struct OnlineUserItemView: View {
    let uuid: String
    
    var body: some View{
        HStack {
            Text(uuid)
                .padding(10)
            
            Spacer()
            
            Button(action: {
                //action for call button
            }) {
                Text("Call")
                    .foregroundColor(.black)
                    .padding(10)
                    .background(Color.white)
                    .cornerRadius(10)
            }
            .padding(.trailing)
        }
        .padding(5)
        .background(Color.yellow)
        .cornerRadius(10)
    }
}

#Preview {
    HomeView()
}
