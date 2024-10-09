//
//  SignInView.swift
//  Neurology-iOS-Client-App
//
//  Created by Lauren Viado on 8/6/24.
//  Modified by Grace Gillam on 10/8/24.
//

import SwiftUI

struct SignInView: View {
    @State private var username: String = ""
    @State private var password: String = ""
    @State private var isPasswordVisible: Bool = false
    
    var body: some View {
        ZStack{
            LinearGradient(gradient: Gradient(colors: [Color.blue.opacity(1.0), Color.black.opacity(1.0)]),
                           startPoint: .top,
                           endPoint: .bottom)
            .edgesIgnoringSafeArea(/*@START_MENU_TOKEN@*/.all/*@END_MENU_TOKEN@*/)
            //.animation(Animation.linear(duration: 3).repeatForever(autoreverses:true))
            VStack(spacing: 20){
                Text("Login")
                    .font(.system(size: 40, weight: .bold))
                    .foregroundColor(.white)
                TextField("Username", text: $username)
                    .padding()
                    .background(Color.white)
                    .cornerRadius(10)
                    .shadow(radius: 5)
                    .padding(.horizontal, 30)
                SecureField("Password", text: $password)
                    .padding()
                    .background(Color.white)
                    .cornerRadius(10)
                    .shadow(radius: 5)
                    .padding(.horizontal, 30)
                Button(action: {
                    //login logic goes here
                }){
                    Text("Sign In")
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(width: 330, height: 50)
                        .background(Color.blue)
                        .cornerRadius(10)
                        .shadow(radius: 5)
                }
                .padding(.top, 10)
            }
            .padding(.bottom, 150)
        }
    }
}

struct SignInView_Previews: PreviewProvider{
    static var previews: some View{
        SignInView()
    }
}
