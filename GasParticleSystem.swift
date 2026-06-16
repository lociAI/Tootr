import SwiftUI

struct GasParticle: Identifiable {
    let id = UUID()
    var position: CGPoint
    var velocity: CGSize
    var scale: CGFloat
    var opacity: Double
    var color: Color
    var life: Double // 1.0 to 0.0
}

class GasParticleSystem: ObservableObject {
    @Published var particles: [GasParticle] = []
    private let maxParticles = 30
    
    func emit(at point: CGPoint) {
        for _ in 0..<5 {
            let p = GasParticle(
                position: point,
                velocity: CGSize(width: Double.random(in: -2...2), height: Double.random(in: -5...(-1))),
                scale: Double.random(in: 0.5...1.5),
                opacity: 0.8,
                color: [Color.green, Color.yellow, Color.green.opacity(0.5)].randomElement()!,
                life: 1.0
            )
            if particles.count > maxParticles {
                particles.removeFirst()
            }
            particles.append(p)
        }
    }
    
    func update() {
        for i in 0..<particles.count {
            particles[i].position.x += particles[i].velocity.width
            particles[i].position.y += particles[i].velocity.height
            particles[i].life -= 0.02
            particles[i].opacity = particles[i].life
            particles[i].scale += 0.01
        }
        particles.removeAll { $0.life <= 0 }
    }
}

struct GasCloudView: View {
    @ObservedObject var system: GasParticleSystem
    
    var body: some View {
        TimelineView(.animation) { timeline in
            Canvas { context, size in
                system.update()
                for particle in system.particles {
                    let rect = CGRect(
                        x: particle.position.x,
                        y: particle.position.y,
                        width: 40 * particle.scale,
                        height: 40 * particle.scale
                    )
                    context.opacity = particle.opacity
                    context.fill(Path(ellipseIn: rect), with: .color(particle.color))
                    // Draw a little "cloud" detail
                    let detailRect = rect.offsetBy(dx: 10, dy: 5)
                    context.fill(Path(ellipseIn: detailRect), with: .color(particle.color))
                }
            }
        }
        .allowsHitTesting(false)
    }
}
