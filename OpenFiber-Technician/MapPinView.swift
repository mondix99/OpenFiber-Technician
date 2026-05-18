import SwiftUI

struct MapPinView: View {

    var status: JobStatus

    var body: some View {
        ZStack {
            Circle()
                .fill(status.indicatorColor)
                .frame(width: 20, height: 20)
            
            Circle()
                .stroke(Color.white, lineWidth: 2)
                .frame(width: 20, height: 20)
        }
    }
}
