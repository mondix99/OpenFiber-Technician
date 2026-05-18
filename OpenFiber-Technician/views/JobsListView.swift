import SwiftUI

struct JobsListView: View {
    
    @ObservedObject var viewModel: JobsViewModel
    
    @State private var searchText: String = ""
    @State private var selectedFilter: JobStatus?
    
    
    @State private var showDocumentPicker = false

    // search bar
    
    var displayedJobs: [Job] {
        viewModel.filteredJobs.filter { job in
            let matchesSearch =
            searchText.isEmpty ||
            job.customerName.lowercased().contains(searchText.lowercased()) ||
            job.address.lowercased().contains(searchText.lowercased())
            
            let matchesFilter =
            selectedFilter == nil ||
            job.status == selectedFilter
            
            return matchesSearch && matchesFilter
        }
    }
    
    var body: some View {
        NavigationStack {
            
            VStack {
                
                // Filter Bar
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack {
                        FilterButton(title: "All", isSelected: selectedFilter == nil) {
                            selectedFilter = nil
                        }
                        
                        FilterButton(title: "New", isSelected: selectedFilter == .new) {
                            selectedFilter = .new
                        }
                        
                        FilterButton(title: "In Progress", isSelected: selectedFilter == .working) {
                            selectedFilter = .working
                        }
                        
                        FilterButton(title: "Completed", isSelected: selectedFilter == .completed) {
                            selectedFilter = .completed
                        }
                    }
                    .padding(.horizontal)
                }
                
                // Jobs List
                List(displayedJobs) { job in
                    NavigationLink {
                        JobDetailsView(jobId: job.id, viewModel: viewModel)
                    } label: {
                        JobCardView(job: job)
                    }
                }
                .listStyle(.plain)
            }
            .navigationTitle("My Jobs")
            .searchable(text: $searchText, prompt: "Search customer or address")
            
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        showDocumentPicker = true
                    } label: {
                        Label("Import PDF", systemImage: "doc.badge.plus")
                    }
                }
            }
        }
        .sheet(isPresented: $showDocumentPicker) {
            DocumentPicker { url in
                print("PDF selected:", url)
            }

        }
    }
}

#Preview {
    let vm = JobsViewModel()
    vm.setTeam(Team(id: "teamA", name: "Team A", username: "TeamA", password: "1234"))
    return JobsListView(viewModel: vm)
}

