import SwiftUI

@main
struct OpenFiber_TechnicianApp: App {
    
    @StateObject var appVM = AppViewModel()
    @StateObject var jobsVM = JobsViewModel()
    
    var body: some Scene {
        WindowGroup {
            Group {
                if appVM.currentTeam == nil {
                    
                    // lo stato della schermata
                    // siccome non c'e ancora utente stiamo per renderzare la pagina login
                    LoginView(appVM: appVM, jobsVM: jobsVM)
                    
                } else {
                    
                    MainTabView(jobsVM: jobsVM)
                    
                }
            }
            .environmentObject(appVM)
            .preferredColorScheme(appVM.isDarkMode ? .dark : .light)
        }
    }
}

