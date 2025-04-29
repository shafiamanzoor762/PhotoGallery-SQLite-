//
//  ContentView.swift
//  photoGallery
//
//  Created by apple on 21/04/2025.
//

import SwiftUI
import AVKit

struct ContentView: View {
//    private var dbhandler = DBHandler()
    
    private var player: AVPlayer?
    
    private let images: [String] = ["person.3.fill", "map.fill", "party.popper.fill", "calendar"]
    private let description: [String] = ["Face recognition for photo grouping", "Auto-sort by captured places", "Organize memories by occasions", "Timeline-based photo categorization"]
    
    @State private var currentIndex = 0
    private let autoScrollInterval = 1.0 // Change image every 1 second
    
    @State private var showBottomNavBar = false
    
    init() {
            if let path = Bundle.main.path(forResource: "photo-gallery-spline-1", ofType: "mp4") {
                let url = URL(fileURLWithPath: path)
                player = AVPlayer(url: url)
                player?.actionAtItemEnd = .none // Prevents stopping when video ends

                // Listen for when the video ends
                NotificationCenter.default.addObserver(
                    forName: .AVPlayerItemDidPlayToEndTime,
                    object: player?.currentItem,
                    queue: .main
                ) { [weak player] _ in
                    player?.seek(to: .zero) // Restart from beginning
                    player?.play() // Play again
                }
            }
        }
    
    var body: some View {
        if showBottomNavBar == false {
            ZStack{
                Color.lightPurple
                VStack{
                    //Spacer()
                    if let player = player {
                        VideoPlayer(player: player)
                            .onAppear {
                                player.play()
                                player.rate = 0.7  // Set playback speed to 0.3x
                            }
                            .onDisappear {
                                player.pause()  // Stop video when view disappears
                            }
                            .frame(width:400, height: 349.5) // Adjust video size
                        //.backgroundStyle(.purple)
                    } else {
                        Text("Video not found")
                            .foregroundColor(.red)
                    }
                    ZStack{
                        Color.white
                        VStack{
                            Spacer()
                            VStack(spacing:12){
                                Text("Build Your Memories")
                                    .font(.title.bold())
                                
                                VStack {
                                    // Carousel
                                    TabView(selection: $currentIndex) {
                                        ForEach(0..<images.count, id: \.self) { index in
                                            VStack{
                                                Image(systemName:images[index]).font(.largeTitle).foregroundStyle(Color.darkPurple)
                                                //.resizable()
                                                //.scaledToFill()
                                                Text(description[index])
                                                    .foregroundStyle(.black)
                                            }
                                            .frame(width: UIScreen.main.bounds.width - 90, height: 150).background(Color.lightPink)
                                            //.border(Color.lightPink, width: 2)
                                            .clipShape(RoundedRectangle(cornerRadius: 20))
                                            .shadow(radius: 5, x: 5, y: 5)
                                            .scaleEffect(currentIndex == index ? 1 : 0.8) // Apply scaling effect
                                            .opacity(currentIndex == index ? 1 : 0.6) // Opacity transition
                                            .animation(.easeInOut(duration: 0.4), value: currentIndex) // Smooth animation
                                            .tag(index) // Tag for TabView selection
                                        }
                                    }
                                    .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never)) // Hides page indicator
                                    .frame(height: 180) // Fixed height for carousel
                                    .onAppear(perform: startAutoScroll) // Start auto-scrolling when view appears
                                    
                                    // Navigation Buttons
                                    HStack {
                                        Button(action: {
                                            withAnimation {
                                                currentIndex = max(0, currentIndex - 1) // Move left, but not below 0
                                            }
                                        }) {
                                            Image(systemName: "chevron.left")
                                                .font(.headline)
                                                .foregroundColor(.black)
                                                .padding()
                                        }
                                        
                                        Spacer()
                                        
                                        Button(action: {
                                            withAnimation {
                                                currentIndex = min(images.count - 1, currentIndex + 1) // Move right, but not exceed max index
                                            }
                                        }) {
                                            Image(systemName: "chevron.right")
                                                .font(.headline)
                                                .foregroundColor(.black)
                                                .padding()
                                        }
                                    }
                                    .padding(.horizontal, 60) // Space buttons away from screen edges
                                }
                                
                                Text("Stay connected with your beautiful memories in one simple app.")
                                    .foregroundStyle(.secondary)
                            }
                            .padding(.horizontal)
                            
                            Button("Get Started"){
                                withAnimation(.easeInOut(duration: 0.5)) {
                                    showBottomNavBar = true
                                }
                            }
                            .buttonStyle(.borderedProminent)
                            .tint(Color.darkPurple)
                            Spacer()
                        }
                    }
                }
            }.ignoresSafeArea()
        }
        VStack{
            if showBottomNavBar {
                BottomNavBar(tabCount: 5, tabItems: Defs.tabItems)
            }
        }.animation(.easeInOut, value: showBottomNavBar)
    }
    
    
    private func startAutoScroll() {
            Timer.scheduledTimer(withTimeInterval: autoScrollInterval, repeats: true) { timer in
                withAnimation {
                    currentIndex = (currentIndex + 1) % images.count // Loop back to start
                }
            }
        }
    

    }

#Preview {
    ContentView()
}
