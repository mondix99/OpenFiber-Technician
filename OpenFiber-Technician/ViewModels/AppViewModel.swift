import Foundation
internal import Combine

class AppViewModel: ObservableObject {
    
    // global state per chiarare il current utente
    @Published var currentTeam: Team?
    
    @Published var isDarkMode: Bool = false
    
    func setTeam(_ team: Team) {
        self.currentTeam = team
    }
}
