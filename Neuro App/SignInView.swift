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

    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // Background gradient
                LinearGradient(colors: [.gray, .white, .gray], startPoint: .topLeading, endPoint: .bottomTrailing)
                    .edgesIgnoringSafeArea(.all)
                    .hueRotation(.degrees(45))
                    .onAppear {
                        withAnimation(
                            .easeInOut(duration: 2)
                            .repeatForever(autoreverses: true)){}
                }

                // Centered Black Box
                VStack(spacing: 20) {
                    // Left-aligned Title and Subtitle
                    VStack(alignment: .leading, spacing: 5) {
                        Text("Login")
                            .font(.largeTitle)
                            .bold()
                            .foregroundColor(
                                Color(UIColor { traitCollection in
                                    return traitCollection.userInterfaceStyle == .dark ? .white : .black
                                })
                            )
                        
                        Text("Enter your credentials to access your account")
                            .font(.subheadline)
                            .foregroundColor(.gray)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal)

                    VStack(alignment: .leading, spacing: 15) {
                        // Username Field
                        Text("Username")
                            .font(.headline)
                            .foregroundColor(
                                Color(UIColor { traitCollection in
                                    return traitCollection.userInterfaceStyle == .dark ? .white : .black
                                })
                            )

                        TextField("Enter your username", text: $username)
                            .padding(10)
                            .cornerRadius(5)
                            .overlay(
                                RoundedRectangle(cornerRadius: 5)
                                    .stroke(Color.gray, lineWidth: 1)
                                )
                            .autocapitalization(.none)
                            .disableAutocorrection(true)

                        // Password Field
                        Text("Password")
                            .font(.headline)
                            .foregroundColor(
                                Color(UIColor { traitCollection in
                                    return traitCollection.userInterfaceStyle == .dark ? .white : .black
                                })
                            )

                        ZStack(alignment: .trailing) {
                            if isPasswordVisible {
                                TextField("Enter your password", text: $password)
                                    .padding(10)
                                    .cornerRadius(5)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 5)
                                            .stroke(Color.gray, lineWidth: 1)
                                        )
                                    .autocapitalization(.none)
                                    .disableAutocorrection(true)
                            } else {
                                SecureField("Enter your password", text: $password)
                                    .padding(10)
                                    .cornerRadius(5)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 5)
                                            .stroke(Color.gray, lineWidth: 1)
                                        )
                                    .autocapitalization(.none)
                                    .disableAutocorrection(true)
                            }

                            Button(action: {
                                isPasswordVisible.toggle()
                            }, label: {
                                Image(systemName: isPasswordVisible ? "eye.fill" : "eye.slash.fill")
                                    .foregroundColor(.gray)
                            })
                            .padding(.trailing, 15) // Position inside the gray box
                        }
                    }
                    .padding(.horizontal)
                    .padding(.bottom)
                    
                    // Sign In Button with Outline
                    Button(action: {
                        // Add sign-in functionality here
                    }, label: {
                        Text("Sign In")
                            .bold()
                            .foregroundColor(
                                Color(UIColor { traitCollection in
                                    return traitCollection.userInterfaceStyle == .dark ? .white : .black
                                })
                            )
                            .padding(10)
                            .frame(maxWidth: .infinity)
                            .background(
                                Color(UIColor { traitCollection in
                                    return traitCollection.userInterfaceStyle == .dark ? .black : .white
                                })
                            )
                            .cornerRadius(10)
                            .overlay(
                                RoundedRectangle(cornerRadius: 10)
                                    .stroke(Color.gray, lineWidth: 1) // Outline
                                )
                    })
                    .frame(maxWidth: geometry.size.width * 0.9) // Matches input field width
                    .padding(.horizontal)

                    // Sign Up Button with Outline
                    Button(action: {
                        // Add sign-up functionality here
                    }, label: {
                        Text("Create Account")
                            .bold()
                            .foregroundColor(
                                Color(UIColor { traitCollection in
                                    return traitCollection.userInterfaceStyle == .dark ? .white : .black
                                })
                            )
                            .padding(10)
                            .frame(maxWidth: .infinity)
                            .background(
                                Color(UIColor { traitCollection in
                                    return traitCollection.userInterfaceStyle == .dark ? .black : .white
                                })
                            )
                            .cornerRadius(10)
                            .overlay(
                                RoundedRectangle(cornerRadius: 10)
                                    .stroke(Color.gray, lineWidth: 1) // Outline
                                )
                    })
                    .frame(maxWidth: geometry.size.width * 0.9) // Matches input field width
                    .padding(.horizontal)
                }
                .padding()
                .padding(.bottom, 15)
                .frame(width: geometry.size.width * 0.9)
                .background(
                    Color(UIColor { traitCollection in
                        return traitCollection.userInterfaceStyle == .dark ? .black : .white
                    })
                )
                .cornerRadius(15)
                .shadow(radius: 10)
            }
        }
    }
}

#Preview {
    SignInView()
}
