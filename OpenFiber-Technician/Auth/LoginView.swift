import SwiftUI

struct LoginView: View {
    @ObservedObject var appVM: AppViewModel
    @ObservedObject var jobsVM: JobsViewModel
    
    @State private var username: String = ""
    @State private var password: String = ""
    
    @State private var isLoggedIn = false
    @State private var showError = false
    
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 24) {
                
                Spacer()
                
                Image(systemName: "person.3.fill")
                    .font(.system(size: 70))
                    .foregroundStyle(.blue)
                
                Text("Team Login")
                    .font(.title2.bold())
                
                VStack(spacing: 16) {
                    
                    TextField("Username", text: $username)
                        .textFieldStyle(.roundedBorder)
                    
                    SecureField("Password", text: $password)
                        .textFieldStyle(.roundedBorder)
                }
                
                Button {
                    login()
                } label: {
                    Text("Login")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.borderedProminent)
                .controlSize(.large)
                
                if showError {
                    Text("Invalid credentials")
                        .foregroundColor(.red)
                        .font(.caption)
                }
                
                Spacer()
            }
            .padding()
            .background(
                LinearGradient(
                    colors: [.blue.opacity(0.2), .white],
                    startPoint: .top,
                    endPoint: .bottom
                )
            )
            .navigationDestination(isPresented: $isLoggedIn) {
                MainTabView(jobsVM: jobsVM)
            }
        }
    }
    
    private func login() {
        
        // Fake Teams
        let teamA = Team(
            id: "teamA",
            name: "Team A",
            username: "TeamA",
            password: "1234"
        )

        let teamB = Team(
            id: "teamB",
            name: "Team B",
            username: "TeamB",
            password: "1234"
        )
        let teams = [teamA, teamB]
        
        // Check login
        if let team = teams.first(where: {
            $0.username == username && $0.password == password
        }) {
            appVM.setTeam(team)
            jobsVM.setTeam(team)
            isLoggedIn = true
            
            print("LOGGED IN:", team.id)
        } else {
            showError = true
        }
    }
}
