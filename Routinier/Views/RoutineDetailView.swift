//
//  RoutineDetailView.swift
//  Routinier
//

import SwiftUI

struct RoutineDetailView: View {
    let routine: Routine

    var body: some View {
        VStack {
            Text(routine.name)
                .font(.largeTitle)
            Text("Due: \(routine.nextDueDate, formatter: dateFormatter)")
        }
        .padding()
    }
}
