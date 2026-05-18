import SwiftUI
import MapKit

struct TechnicianMapView: View {
    
    @ObservedObject var viewModel: JobsViewModel
    
    @State private var region = MKCoordinateRegion(
        center: CLLocationCoordinate2D(
            latitude: 45.1847,
            longitude: 9.1582
        ),
        span: MKCoordinateSpan(
            latitudeDelta: 0.05,
            longitudeDelta: 0.05
        )
    )
    
    var body: some View {
        NavigationStack {
            
            Map(coordinateRegion: $region,
                annotationItems: viewModel.filteredJobs) { job in
                
                MapAnnotation(coordinate: job.coordinate) {
                    
                    NavigationLink {
                        JobDetailsView(jobId: job.id, viewModel: viewModel)
                    } label: {
                        MapPinView(status: job.status)
                    }
                }
            }
            .navigationTitle("Jobs Map")
        }
    }
}
