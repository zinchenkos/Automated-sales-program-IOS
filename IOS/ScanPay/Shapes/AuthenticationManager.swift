//
//  AuthenticationManager.swift
//  ScanPay
//
//  Created by Pasha Boyko on 18.05.2020.
//  Copyright © 2020 Pasha Boyko. All rights reserved.
//
import SwiftUI
import Combine
import LocalAuthentication
import KeychainSwift
import CryptoKit



class AuthenticationManager: ObservableObject {
    
    @Published var isLoggedIn = false
    private var keychain = KeychainSwift()
    
    private var cancellableSet: Set<AnyCancellable> = []
    
    @Published var email = ""
    @Published var password = ""
    @Published var confirmedPassword = ""
    @Published var name = ""
    @Published var phone = ""
    
    @Published var canLogin = false
    @Published var canSignup = false
    @Published var canSignupNamePhone = false
    
    @Published var emailValidation = FormValidation()
    @Published var passwordValidation = FormValidation()
    @Published var nameValidation = FormValidation()
    @Published var phoneValidation = FormValidation()
    @Published var confirmedPasswordValidation = FormValidation()
    @Published var similarityValidation = FormValidation()
            
    private var userDefaults = UserDefaults.standard
    private var laContext = LAContext()
    
    struct Config {
        static let recommendedLength = 6
        static let specialCharacters = "!@#$%^&*()?/|\\:;"
        static let emailPredicate = NSPredicate(format:"SELF MATCHES %@", "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}")
        static let passwordPredicate = NSPredicate(format:"SELF MATCHES %@", "^(?=.*[A-Z])(?=.*[!@#$&*])(?=.*[0-9])(?=.*[a-z]).{8,}$")
    }
    
    
    
    private var phonePublisher: AnyPublisher<FormValidation, Never> {
        self.$phone.debounce(for: 0.2, scheduler: RunLoop.main)
        .removeDuplicates()
            .map { phone in
                
                if phone.isEmpty{
                    return FormValidation(success: false, message: "")
                }
                
                return FormValidation(success: true, message: "")
        }.eraseToAnyPublisher()
    }
    
    
    private var namePublisher: AnyPublisher<FormValidation, Never> {
        self.$name.debounce(for: 0.2, scheduler: RunLoop.main)
        .removeDuplicates()
            .map { name in
                
                if name.isEmpty{
                    return FormValidation(success: false, message: "")
                }
                
                return FormValidation(success: true, message: "")
        }.eraseToAnyPublisher()
    }
    
    
    
    
    private var emailPublisher: AnyPublisher<FormValidation, Never> {
        self.$email.debounce(for: 0.2, scheduler: RunLoop.main)
        .removeDuplicates()
            .map { email in
                
                if email.isEmpty{
                    return FormValidation(success: false, message: "")
                }
                

                if !Config.emailPredicate.evaluate(with: email){
                    return FormValidation(success: false, message: "Invalid email address")
                }
                
                return FormValidation(success: true, message: "")
        }.eraseToAnyPublisher()
    }
    
    private var passwordPublisher: AnyPublisher<FormValidation, Never> {
        self.$password.debounce(for: 0.2, scheduler: RunLoop.main)
            .removeDuplicates()
            .map { password in
                
                if password.isEmpty{
                    return FormValidation(success: false, message: "")
                }
                if password.count < Config.recommendedLength{
                    return FormValidation(success: false, message: "The password length must be greater than \(Config.recommendedLength) ")
                }
                
                
                if !Config.passwordPredicate.evaluate(with: password){
                    return FormValidation(success: false, message: "The password is must contain numbers, uppercase and special characters")
                }
                
                return FormValidation(success: true, message: "")
        }.eraseToAnyPublisher()
    }
    
    private var confirmPasswordPublisher: AnyPublisher<FormValidation, Never> {
         self.$confirmedPassword.debounce(for: 0.2, scheduler: RunLoop.main)
                   .removeDuplicates()
                    
                   .map { password in
                       
                       if password.isEmpty{
                           return FormValidation(success: false, message: "")
                       }
                    
                       if password.count < Config.recommendedLength{
                           return FormValidation(success: false, message: "The password length must be greater than \(Config.recommendedLength) ")
                       }
                       

                       
                    if !Config.passwordPredicate.evaluate(with: password){
                           return FormValidation(success: false, message: "The password is must contain numbers, uppercase and special characters")
                       }
                    
                       
                       return FormValidation(success: true, message: "")
               }.eraseToAnyPublisher()
    }
    
    private var similarityPublisher: AnyPublisher<FormValidation, Never> {
        Publishers.CombineLatest($password, $confirmedPassword)
            .map { password, confirmedPassword in
                
                if password.isEmpty || confirmedPassword.isEmpty{
                     return FormValidation(success: false, message: "")
                }
                
                if password != confirmedPassword{
                     return FormValidation(success: false, message: "Passwords do not match!")
                }
                 return FormValidation(success: true, message: "")
        }.eraseToAnyPublisher()
    }
    
    
    
    init() {
        
        namePublisher
            .assign(to: \.nameValidation, on: self)
            .store(in: &self.cancellableSet)
        
        phonePublisher
        .assign(to: \.phoneValidation, on: self)
        .store(in: &self.cancellableSet)
        
        emailPublisher
            .assign(to: \.emailValidation, on: self)
            .store(in: &self.cancellableSet)
        
        passwordPublisher
            .assign(to: \.passwordValidation, on: self)
            .store(in: &self.cancellableSet)
        
        confirmPasswordPublisher
            .assign(to: \.confirmedPasswordValidation, on: self)
            .store(in: &self.cancellableSet)
        
        similarityPublisher
            .assign(to: \.similarityValidation, on: self)
            .store(in: &self.cancellableSet)
        
        // Login
        Publishers.CombineLatest(emailPublisher, passwordPublisher)
            .map { emailValidation, passwordValidation  in
                emailValidation.success && passwordValidation.success
        }.assign(to: \.canLogin, on: self)
            .store(in: &self.cancellableSet)
        

        Publishers.CombineLatest4(emailPublisher, passwordPublisher, confirmPasswordPublisher,  Publishers.Merge3(similarityPublisher, namePublisher,phonePublisher))
            .map { emailValidation, passwordValidation, confirmedPasswordValidation, similarityValidation  in
                emailValidation.success && passwordValidation.success && confirmedPasswordValidation.success && similarityValidation.success
        }.assign(to: \.canSignup, on: self)
            .store(in: &self.cancellableSet)
        
        Publishers.CombineLatest(namePublisher,phonePublisher).map{ nameValidation, phoneValidation in nameValidation.success && phoneValidation.success}.assign(to: \.canSignupNamePhone, on: self)
        .store(in: &self.cancellableSet)
    

    
    }
    
    
}
