import SwiftUI

struct MainTabView: View {
    
    @ObservedObject var jobsVM: JobsViewModel
    @EnvironmentObject var appVM: AppViewModel
    
    var body: some View {
        TabView {
            
            JobsListView(viewModel: jobsVM)
                .tabItem {
                    Label("Jobs", systemImage: "list.bullet")
                }
            
            TechnicianMapView(viewModel: jobsVM)
                .tabItem {
                    Label("Map", systemImage: "map")
                }
            
            AgendaView(viewModel: jobsVM)
                .tabItem {
                    Label("Agenda", systemImage: "calendar")
                }
            
            ProfileView(jobsVM: jobsVM)
                .environmentObject(appVM)
                .tabItem {
                    Label("Profile", systemImage: "person")
            }
        }
    }
}
