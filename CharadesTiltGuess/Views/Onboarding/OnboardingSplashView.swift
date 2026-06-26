import SwiftUI

struct OnboardingSplashView: View {
    let onSkip: () -> Void
    let onContinue: () -> Void

    var body: some View {
        ZStack {
            DoodlePaperBackground()
            
            VStack(spacing: 16) {
                Spacer()
                
                // Hero Graphic
                ZStack {
                    Circle()
                        .fill(AppTheme.Colors.ink.opacity(0.05))
                        .frame(width: 180, height: 180)
                    
                    Image(systemName: "iphone.gen2")
                        .font(.system(size: 80, weight: .light))
                        .foregroundStyle(AppTheme.Colors.ink)
                        .rotationEffect(.degrees(-75))
                        
                    // Motion lines
                    Image(systemName: "arrow.down")
                        .font(.system(size: 30, weight: .bold))
                        .foregroundStyle(AppTheme.Colors.mint)
                        .rotationEffect(.degrees(15))
                        .offset(x: 0, y: 55)
                        
                    Image(systemName: "arrow.up")
                        .font(.system(size: 30, weight: .bold))
                        .foregroundStyle(AppTheme.Colors.coral)
                        .rotationEffect(.degrees(15))
                        .offset(x: 0, y: -55)
                }
                
                Spacer()
                
                // Titles and rules
                VStack(spacing: 24) {
                    Text("How to Play")
                        .font(.system(size: 42, weight: .black, design: .rounded))
                        .foregroundStyle(AppTheme.Colors.ink)
                        .padding(.bottom, 8)
                    
                    VStack(spacing: 12) {
                        Text("Place the phone on your forehead")
                            .font(.system(size: 20, weight: .bold, design: .rounded))
                            .foregroundStyle(AppTheme.Colors.ink.opacity(0.8))
                        
                        Text("Tilt DOWN for Correct")
                            .font(.system(size: 20, weight: .black, design: .rounded))
                            .foregroundStyle(AppTheme.Colors.mint)
                            
                        Text("Tilt UP to Pass")
                            .font(.system(size: 20, weight: .black, design: .rounded))
                            .foregroundStyle(AppTheme.Colors.coral)
                    }
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 16)
                }
                
                Spacer()
                
                // Action Buttons
                VStack(spacing: 16) {
                    DoodleActionButton(
                        title: "Interactive Tutorial",
                        symbol: "play.fill",
                        accent: AppTheme.Colors.mint
                    ) {
                        onContinue()
                    }
                    .frame(height: 60)
                    
                    Button(action: onSkip) {
                        Text("Skip Tutorial")
                            .font(.system(size: 20, weight: .bold, design: .rounded))
                            .foregroundStyle(AppTheme.Colors.ink.opacity(0.5))
                            .padding(.vertical, 12)
                            .padding(.horizontal, 24)
                    }
                }
                .padding(.horizontal, 40)
                .padding(.bottom, 40)
            }
        }
        .onAppear {
            OrientationController.shared.useMenuPortrait()
        }
    }
}
