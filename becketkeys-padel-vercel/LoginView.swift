import SwiftUI

struct LoginView: View {
    @EnvironmentObject private var authViewModel: AuthViewModel
    @State private var previewName = ""
    @State private var previewEmail = ""

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    VStack(spacing: 10) {
                        Image(systemName: "figure.tennis")
                            .font(.system(size: 54))
                            .padding(18)
                            .background(.indigo.opacity(0.12), in: Circle())

                        Text(SchoolConfig.appTitle)
                            .font(.largeTitle.bold())

                        Text("Staff court booking for \(SchoolConfig.schoolName)")
                            .multilineTextAlignment(.center)
                            .foregroundStyle(.secondary)
                    }
                    .padding(.top, 32)

                    VStack(alignment: .leading, spacing: 12) {
                        Label("Morning bookings: 7:00–8:00", systemImage: "sun.max")
                        Label("After-school bookings: 15:30–17:00", systemImage: "sunset")
                        Label("Online sync via CloudKit", systemImage: "icloud")
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding()
                    .background(.thinMaterial, in: RoundedRectangle(cornerRadius: 18))

                    Button {
                        Task { await authViewModel.startMicrosoftSignIn() }
                    } label: {
                        Label("Sign in with Microsoft 365", systemImage: "building.2.crop.circle")
                            .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.borderedProminent)
                    .controlSize(.large)

                    VStack(alignment: .leading, spacing: 10) {
                        Text("Preview login for setup/testing")
                            .font(.headline)
                        TextField("Staff name", text: $previewName)
                            .textFieldStyle(.roundedBorder)
                        TextField("Staff email", text: $previewEmail)
                            .textInputAutocapitalization(.never)
                            .keyboardType(.emailAddress)
                            .autocorrectionDisabled()
                            .textFieldStyle(.roundedBorder)
                        Button("Use preview login") {
                            authViewModel.signInForPreview(name: previewName, email: previewEmail)
                        }
                        .buttonStyle(.bordered)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding()
                    .background(Color(.secondarySystemBackground), in: RoundedRectangle(cornerRadius: 18))
                }
                .padding()
            }
            .navigationBarTitleDisplayMode(.inline)
            .overlay {
                if authViewModel.isLoading {
                    ProgressView("Signing in…")
                }
            }
            .alert("Sign-in issue", isPresented: Binding(
                get: { authViewModel.errorMessage != nil },
                set: { if !$0 { authViewModel.errorMessage = nil } }
            )) {
                Button("OK", role: .cancel) {}
            } message: {
                Text(authViewModel.errorMessage ?? "")
            }
        }
    }
}
