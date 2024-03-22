//
//  ContentView.swift
//  Insult Timer
//
//  Created by Ian Searcy-Gardner on 3/10/24.
//

import SwiftUI
import AVFoundation

struct ContentView: View {
    
    @ObservedObject var viewModel = TimerViewModel()
    @Environment(\.scenePhase) private var scenePhase
    
    var body: some View {
        ZStack {
            VStack {
                // Title
                if !viewModel.timerActive && !viewModel.timerPaused {
                    Text("The Insult Timer")
                        .font(.largeTitle)
                        .padding()
                }
                // Conditional display of Circular progress indicator
                if viewModel.timerActive || viewModel.timerPaused {
                    ZStack {
                        Circle()
                            .stroke(lineWidth: 20)
                            .opacity(0.3)
                            .foregroundColor(Color.gray) // Neutral background circle
                        
                        Circle()
                            .trim(from: 0.0, to: viewModel.progress)
                            .stroke(style: StrokeStyle(lineWidth: 20, lineCap: .round, lineJoin: .round))
                            .foregroundColor(viewModel.timerActive ? Color.green : Color.gray) // Change color based on timerActive
                            .rotationEffect(Angle(degrees: -90))
                            .animation(.linear, value: viewModel.progress)

                        // Timer display now inside the circle
                        Text(viewModel.timeString(from: viewModel.countdownTime))
                            .font(.largeTitle)
                            .padding()
                    }
                    .frame(width: 300, height: 300) // Ensure this frame size matches the size of your circle
                    .padding()
                }

                
                // Conditional display of Picker View
                if !viewModel.timerActive && !viewModel.timerPaused {
                    HStack {
                        pickerComponent(range: 0..<24, selection: $viewModel.selectedHours, unit: "hours")
                        pickerComponent(range: 0..<60, selection: $viewModel.selectedMinutes, unit: "min")
                        pickerComponent(range: 0..<60, selection: $viewModel.selectedSeconds, unit: "sec")
                    }
                }
                
                // Buttons
                
            }
            VStack {
                Spacer()
                buttonsView()
                    .padding(.bottom, 30)
            }
        }
        .onChange(of: scenePhase) { newPhase in
                    switch newPhase {
                    case .background:
                        viewModel.appMovedToBackground()
                    case .active:
                        viewModel.appReturnedToForeground()
                    default:
                        break
                    }
                }
    }
    
    func pickerComponent(range: Range<Int>, selection: Binding<Int>, unit: String) -> some View {
        HStack(spacing: 0) {
            Picker("", selection: selection) {
                ForEach(range, id: \.self) { value in
                    Text("\(value)").tag(value)
                }
            }
            .pickerStyle(.wheel)
            .labelsHidden()
            .frame(width: 50, height: 150)
            .clipped()
            
            Text(unit)
                .frame(alignment: .leading) // Adjust frame to control the position more precisely if needed
                .padding(.leading, -5) // Negative padding to bring text closer to the picker, adjust as needed
        }
        .frame(width: 100, alignment: .center) // Adjust this frame to control the overall size and alignment of the picker component
    }
    
    @ViewBuilder
    func buttonsView() -> some View {
        HStack {
            Spacer()
            Button(action: {
                // Cancel action
                viewModel.cancelTimer()
            }) {
                Text("Cancel")
                    .foregroundColor(.white)
                    .frame(width: 100, height: 100)
                    .background(Color.gray)
                    .clipShape(Circle())
            }
            .disabled(!viewModel.timerActive && !viewModel.timerPaused) // Disable "Cancel" button when the timer isn't active or paused
            Spacer()
            Button(action: {
                // Start/Pause/Resume action
                viewModel.startTimer()
            }) {
                Text(viewModel.timerActive ? "Pause" : (viewModel.timerPaused ? "Resume" : "Start"))
                    .foregroundColor(.white)
                    .frame(width: 100, height: 100)
                    .background(viewModel.timerActive ? Color.red : (viewModel.selectedHours == 0 && viewModel.selectedMinutes == 0 && viewModel.selectedSeconds == 0 ? Color.green.opacity(0.5) : Color.green))
                    .clipShape(Circle())
            }
            .disabled(viewModel.selectedHours == 0 && viewModel.selectedMinutes == 0 && viewModel.selectedSeconds == 0) // Here's the existing condition for disabling the start button
            Spacer()
        }
        .padding()
    }
}

#Preview {
    ContentView()
}
