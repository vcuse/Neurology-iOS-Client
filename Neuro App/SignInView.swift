//
//  SignInView.swift
//  Neurology-iOS-Client-App
//
//  Created by Lauren Viado on 8/6/24.
//

import SwiftUI

struct SignInView: View {
    @State private var username: String = ""
    @State private var password: String = ""
    @State private var isPasswordVisible: Bool = false
    @EnvironmentObject var signalingClient: SignalingClient

    var body: some View {
        GeometryReader { _ in
            VStack(spacing: 30) {
                Text("Hello, user!")
                    .font(.title)
                    .bold()
                    .padding(30)

                VStack(alignment: .leading) {
                    Text("Username")
                        .font(.headline)
                        .padding(.top)
                        .padding(.leading)
                        .padding(.trailing)

                    TextField("Enter your username", text: $username)
                        .padding()
                        .background(Color(.systemGray6))
                        .cornerRadius(5)
                        .autocapitalization(/*@START_MENU_TOKEN@*/.none/*@END_MENU_TOKEN@*/)
                        .disableAutocorrection(true)
                        .padding(.leading)
                        .padding(.trailing)
                        .padding(.bottom)

                    HStack {
                        Text("Password")
                            .font(.headline)
                            .padding(.top)
                            .padding(.leading)
                            .padding(.trailing)

                        Button(action: {
                            isPasswordVisible.toggle()
                        }, label: {
                            Image(systemName: isPasswordVisible ? "eye.fill" : "eye.slash.fill")
                                .foregroundColor(.gray)
                        })
                        .padding(.bottom, -13)
                        .padding(.leading, -5)
                    }

                    HStack {
                        if isPasswordVisible {
                            TextField("Enter your password", text: $password)
                                .padding()
                                .background(Color(.systemGray6))
                                .cornerRadius(5)
                                .autocapitalization(/*@START_MENU_TOKEN@*/.none/*@END_MENU_TOKEN@*/)
                                .disableAutocorrection(true)
                                .padding(.leading)
                                .padding(.trailing)
                                .padding(.bottom)
                        } else {
                            SecureField("Enter your password", text: $password)
                                .padding()
                                .background(Color(.systemGray6))
                                .cornerRadius(5)
                                .autocapitalization(/*@START_MENU_TOKEN@*/.none/*@END_MENU_TOKEN@*/)
                                .disableAutocorrection(true)
                                .padding(.leading)
                                .padding(.trailing)
                                .padding(.bottom)
                        }

                    }

                }

                Button(action: {
                    // add sign in functionality here
                    login()
                    //print("Login failed")
                }, label: {
                    Text("Sign In")
                        .foregroundColor(.black)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.yellow)
                        .cornerRadius(20)
                })
                .padding(20)
            }

        }

    }
    
    func login() {
            // Call your REST API for login
            signalingClient.login(username: username, password: password) { success in
                if success {
                    // Navigate to HomeView (handled in parent view)
                    print("Login succeeded")
                } else {
                    // Show error message
                    print("Login failed")
                }
            }
    }
    

}

#Preview {
    SignInView()
}
