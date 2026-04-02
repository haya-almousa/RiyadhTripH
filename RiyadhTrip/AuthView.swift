//
//  AuthView.swift
//  RiyadhTrip
//
//  Created by Haya almousa on 17/02/2026.
//

import SwiftUI
import FirebaseAuth

struct AuthView: View {
    enum Mode { case signUp, signIn }

    @State private var mode: Mode = .signUp
    @State private var firstName: String = ""
    @State private var lastName: String = ""
    @State private var email: String = ""
    @State private var password: String = ""
    @State private var confirmPassword: String = ""
    @State private var isLoading: Bool = false
    @State private var errorMessage: String = ""
    @FocusState private var focusedField: Field?
    @State private var navigateToProfile: Bool = false
    @State private var signedUpDisplayName: String = ""

    enum Field: Hashable { case firstName, lastName, email, password, confirmPassword }

    var body: some View {
        NavigationStack {
            ZStack {
                // Background Image
                Image("الدرعيه")
                    .resizable()
                    .scaledToFill()
                    .ignoresSafeArea()

                // Dark overlay to make text readable
                LinearGradient(
                    colors: [
                        Color.black.opacity(0.15),
                        Color.black.opacity(0.55)
                    ],
                    startPoint: .top,
                    endPoint: .bottom
                )
                .ignoresSafeArea()

                VStack {
                    Spacer(minLength: 60)

                    // Title text on image (left aligned)
                    VStack(alignment: .leading, spacing: 8) {
                        Text("اكتشفي")
                            .font(.system(size: 42, weight: .bold))
                        Text("أفضل الأماكن!")
                            .font(.system(size: 42, weight: .bold))
                    }
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal, 24)

                    Spacer()

                    // Bottom Card
                    VStack(spacing: 16) {

                        if !errorMessage.isEmpty {
                            Text(errorMessage)
                                .font(.footnote)
                                .foregroundStyle(.red)
                                .multilineTextAlignment(.center)
                        }

                        // Fields
                        if mode == .signUp {
                            HStack(spacing: 12) {
                                TextField("الاسم الأول", text: $firstName)
                                    .textInputAutocapitalization(.words)
                                    .autocorrectionDisabled(true)
                                    .padding(14)
                                    .background(Color(.systemGray6))
                                    .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
                                    .focused($focusedField, equals: .firstName)
                                    .submitLabel(.next)
                                    .multilineTextAlignment(.trailing)

                                TextField("اسم العائلة", text: $lastName)
                                    .textInputAutocapitalization(.words)
                                    .autocorrectionDisabled(true)
                                    .padding(14)
                                    .background(Color(.systemGray6))
                                    .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
                                    .focused($focusedField, equals: .lastName)
                                    .submitLabel(.next)
                                    .multilineTextAlignment(.trailing)
                            }
                        }

                        TextField("البريد الإلكتروني", text: $email)
                            .textInputAutocapitalization(.never)
                            .keyboardType(.emailAddress)
                            .autocorrectionDisabled(true)
                            .padding(14)
                            .background(Color(.systemGray6))
                            .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
                            .focused($focusedField, equals: .email)
                            .submitLabel(.next)
                            .multilineTextAlignment(.trailing)

                        SecureField("كلمة المرور", text: $password)
                            .textContentType(.password)
                            .padding(14)
                            .background(Color(.systemGray6))
                            .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
                            .focused($focusedField, equals: .password)
                            .submitLabel(mode == .signUp ? .next : .go)
                            .multilineTextAlignment(.trailing)

                        if mode == .signUp {
                            SecureField("تأكيد كلمة المرور", text: $confirmPassword)
                                .textContentType(.password)
                                .padding(14)
                                .background(Color(.systemGray6))
                                .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
                                .focused($focusedField, equals: .confirmPassword)
                                .submitLabel(.go)
                                .multilineTextAlignment(.trailing)
                        }

                        // Primary button
                        Button {
                            handlePrimaryAction()
                        } label: {
                            ZStack {
                                if isLoading {
                                    ProgressView().tint(.white)
                                } else {
                                    Text(primaryButtonTitle)
                                        .font(.system(size: 20, weight: .semibold))
                                }
                            }
                            .frame(maxWidth: .infinity)
                            .frame(height: 58)
                        }
                        .buttonStyle(.plain)
                        .foregroundStyle(.white)
                        .background(Color(red: 0.73, green: 0.67, blue: 0.86))
                        .clipShape(RoundedRectangle(cornerRadius: 28, style: .continuous))
                        .disabled(!isFormValid || isLoading)

                        // Secondary toggle
                        Button {
                            withAnimation(.easeInOut) { toggleMode() }
                        } label: {
                            Text(secondaryButtonTitle)
                                .font(.system(size: 18, weight: .semibold))
                                .foregroundStyle(Color(red: 0.63, green: 0.53, blue: 0.78))
                        }
                        .buttonStyle(.plain)

                    }
                    .padding(.horizontal, 22)
                    .padding(.top, 22)
                    .padding(.bottom, 28)
                    .background(.white)
                    .clipShape(RoundedRectangle(cornerRadius: 28, style: .continuous))
                    .padding(.horizontal, 8)
                    .padding(.bottom, 5)
                }
            }
            .onSubmit { handleSubmitFromKeyboard() }
        }
        .navigationDestination(isPresented: $navigateToProfile) {
            ProfileView(displayName: signedUpDisplayName)
        }
    }

    private var primaryButtonTitle: String {
        mode == .signUp ? "إنشاء حساب جديد" : "تسجيل الدخول"
    }

    private var secondaryButtonTitle: String {
        mode == .signUp ? "لدي حساب بالفعل" : "إنشاء حساب جديد"
    }

    private var isFormValid: Bool {
        switch mode {
        case .signUp:
            return !firstName.trimmingCharacters(in: .whitespaces).isEmpty &&
                   !lastName.trimmingCharacters(in: .whitespaces).isEmpty &&
                   isValidEmail(email) &&
                   password.count >= 6 &&
                   password == confirmPassword
        case .signIn:
            return isValidEmail(email) && !password.isEmpty
        }
    }

    private func handlePrimaryAction() {
        errorMessage = ""
        guard isFormValid else {
            errorMessage = validationMessage()
            return
        }

        isLoading = true

        switch mode {
        case .signUp:
            // Create user with Firebase Auth
            Auth.auth().createUser(withEmail: email, password: password) { authResult, error in
                if let error = error {
                    // Show localized Firebase error
                    self.errorMessage = error.localizedDescription
                    self.isLoading = false
                    return
                }

                guard let user = authResult?.user else {
                    self.errorMessage = "حدث خطأ غير متوقع. حاول مرة أخرى."
                    self.isLoading = false
                    return
                }

                // Build display name from first/last name or fallback
                let fullName = "\(firstName.trimmingCharacters(in: .whitespaces)) \(lastName.trimmingCharacters(in: .whitespaces))".trimmingCharacters(in: .whitespaces)
                let nameToSet = fullName.isEmpty ? displayNameFallback() : fullName
                self.signedUpDisplayName = nameToSet

                // Update profile displayName in Firebase
                let changeRequest = user.createProfileChangeRequest()
                changeRequest.displayName = nameToSet
                changeRequest.commitChanges { commitError in
                    // Even if commit fails, we still proceed to profile, but show message
                    if let commitError = commitError { self.errorMessage = commitError.localizedDescription }
                    self.isLoading = false
                    self.navigateToProfile = true
                }
            }

        case .signIn:
            // Sign in with Firebase Auth
            Auth.auth().signIn(withEmail: email, password: password) { authResult, error in
                if let error = error {
                    self.errorMessage = error.localizedDescription
                    self.isLoading = false
                    return
                }

                // Use user's displayName if available; otherwise fallback
                let display = authResult?.user.displayName?.trimmingCharacters(in: .whitespacesAndNewlines)
                self.signedUpDisplayName = (display?.isEmpty == false) ? display! : displayNameFallback()
                self.isLoading = false
                self.navigateToProfile = true
            }
        }
    }

    private func handleSubmitFromKeyboard() {
        switch focusedField {
        case .firstName: focusedField = .lastName
        case .lastName: focusedField = .email
        case .email: focusedField = .password
        case .password:
            if mode == .signUp { focusedField = .confirmPassword } else { handlePrimaryAction() }
        case .confirmPassword:
            handlePrimaryAction()
        case .none:
            break
        }
    }

    private func toggleMode() {
        mode = (mode == .signUp) ? .signIn : .signUp
        errorMessage = ""
        if mode == .signIn {
            confirmPassword = ""
            firstName = ""
            lastName = ""
        }
    }

    private func isValidEmail(_ email: String) -> Bool {
        let pattern = #"^[A-Z0-9._%+-]+@[A-Z0-9.-]+\.[A-Z]{2,}$"#
        return email.range(of: pattern, options: [.regularExpression, .caseInsensitive]) != nil
    }

    private func validationMessage() -> String {
        switch mode {
        case .signUp:
            if firstName.trimmingCharacters(in: .whitespaces).isEmpty { return "الاسم الأول مطلوب" }
            if lastName.trimmingCharacters(in: .whitespaces).isEmpty { return "اسم العائلة مطلوب" }
            if !isValidEmail(email) { return "بريد إلكتروني غير صالح" }
            if password.count < 6 { return "كلمة المرور يجب أن تكون 6 أحرف على الأقل" }
            if password != confirmPassword { return "كلمتا المرور غير متطابقتين" }
            return "تحقق من المدخلات"
        case .signIn:
            if !isValidEmail(email) || password.isEmpty { return "الرجاء إدخال البريد وكلمة المرور بشكل صحيح" }
            return ""
        }
    }
    
    private func displayNameFallback() -> String {
        // Fallback in case names are empty; you can customize this.
        return "المستخدم"
    }
}

#Preview {
    AuthView()
}
