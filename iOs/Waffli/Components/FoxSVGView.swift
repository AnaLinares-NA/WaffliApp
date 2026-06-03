//
//  FoxSVGView.swift
//  Waffli
//
//  Created by Ana Linares Guzmán on 23/05/26.
//

import SwiftUI

/// Zorrito SVG animado que cambia según el FoxMood
struct FoxSVGView: View {
    let mood: FoxMood
    let outfitId: String?
    var size: CGFloat = 180

    // Animaciones
    @State private var blinkOpacity: Double = 1
    @State private var tailAngle: Double = 0
    @State private var bodyBounce: Double = 0
    @State private var earWiggle: Double = 0
    @State private var zzzOpacity: Double = 0
    @State private var starScale: Double = 0
    @State private var heartFloat: Double = 0

    // Color del pelaje según outfit
    var furColor: Color {
        guard let id = outfitId else { return Color("Maple") }
        switch id {
        case "color_cocoa":  return Color("Cocoa")
        case "color_snow":   return Color("Crema")
        case "color_canela": return Color("Canela")
        default:             return Color("Maple")
        }
    }

    var furDark: Color { furColor.opacity(0.7) }
    var furLight: Color { Color("Waffle").opacity(0.6) }

    var body: some View {
        ZStack {
            Canvas { ctx, size in
                drawFox(ctx: ctx, size: size)
            }
            .frame(width: size, height: size)

            // Overlays según mood
            if mood == .sleeping {
                sleepingOverlay
            }
            if mood == .superHappy {
                superHappyOverlay
            }
            if mood == .happy || mood == .fed {
                heartOverlay
            }

            // Outfit: sombrero
            if let id = outfitId {
                hatOverlay(id: id)
            }
        }
        .onAppear { startAnimations() }
        .onChange(of: mood) { _, _ in startAnimations() }
    }

    // MARK: - Canvas Fox Drawing

    private func drawFox(ctx: GraphicsContext, size: CGSize) {
        let w = size.width
        let h = size.height
        let cx = w / 2
        let scale = w / 200

        // Sombra suave
        var shadow = ctx
        shadow.opacity = 0.12
        shadow.fill(
            Ellipse().path(in: CGRect(x: cx - 45*scale, y: h*0.82, width: 90*scale, height: 18*scale)),
            with: .color(.black)
        )

        // Cola (detrás del cuerpo)
        let tailPath = tailSwishPath(cx: cx, h: h, scale: scale)
        ctx.fill(tailPath, with: .color(furColor))
        // Punta blanca de la cola
        let tailTipPath = tailTipPath(cx: cx, h: h, scale: scale)
        ctx.fill(tailTipPath, with: .color(Color("Crema")))

        // Cuerpo
        let bodyY = h * 0.42 + bodyBounce * scale
        let bodyPath = Path(ellipseIn: CGRect(x: cx - 38*scale, y: bodyY, width: 76*scale, height: 68*scale))
        ctx.fill(bodyPath, with: .color(furColor))

        // Panza
        let bellyPath = Path(ellipseIn: CGRect(x: cx - 22*scale, y: bodyY + 20*scale, width: 44*scale, height: 38*scale))
        ctx.fill(bellyPath, with: .color(furLight))

        // Cabeza
        let headY = h * 0.18 + bodyBounce * scale * 0.5
        let headPath = Path(ellipseIn: CGRect(x: cx - 36*scale, y: headY, width: 72*scale, height: 66*scale))
        ctx.fill(headPath, with: .color(furColor))

        // Orejas
        drawEars(ctx: ctx, cx: cx, headY: headY, scale: scale)

        // Máscara facial (cara más clara)
        let maskPath = Path(ellipseIn: CGRect(x: cx - 24*scale, y: headY + 20*scale, width: 48*scale, height: 40*scale))
        ctx.fill(maskPath, with: .color(furLight))

        // Ojos
        drawEyes(ctx: ctx, cx: cx, headY: headY, scale: scale)

        // Nariz
        let noseY = headY + 43*scale
        let nosePath = Path(ellipseIn: CGRect(x: cx - 6*scale, y: noseY, width: 12*scale, height: 8*scale))
        ctx.fill(nosePath, with: .color(Color("Cocoa")))

        // Boca según mood
        drawMouth(ctx: ctx, cx: cx, noseY: noseY, scale: scale)

        // Patas
        drawPaws(ctx: ctx, cx: cx, bodyY: bodyY, scale: scale)
    }

    private func tailSwishPath(cx: CGFloat, h: CGFloat, scale: CGFloat) -> Path {
        var p = Path()
        let angle = tailAngle * .pi / 180
        let tx = cx + 55*scale * cos(angle + .pi * 0.2)
        let ty = h * 0.65 + 30*scale * sin(angle)
        p.move(to: CGPoint(x: cx + 30*scale, y: h * 0.68))
        p.addQuadCurve(
            to: CGPoint(x: tx, y: ty),
            control: CGPoint(x: cx + 70*scale, y: h * 0.55)
        )
        p.addEllipse(in: CGRect(x: tx - 22*scale, y: ty - 18*scale, width: 44*scale, height: 36*scale))
        return p
    }

    private func tailTipPath(cx: CGFloat, h: CGFloat, scale: CGFloat) -> Path {
        let angle = tailAngle * .pi / 180
        let tx = cx + 55*scale * cos(angle + .pi * 0.2)
        let ty = h * 0.65 + 30*scale * sin(angle)
        return Path(ellipseIn: CGRect(x: tx - 14*scale, y: ty - 11*scale, width: 28*scale, height: 22*scale))
    }

    private func drawEars(ctx: GraphicsContext, cx: CGFloat, headY: CGFloat, scale: CGFloat) {
        let wiggle = earWiggle * .pi / 180
        // Oreja izquierda
        let leftEar = Path { p in
            p.move(to: CGPoint(x: cx - 26*scale, y: headY + 10*scale))
            p.addLine(to: CGPoint(x: cx - 40*scale + wiggle*5*scale, y: headY - 22*scale))
            p.addLine(to: CGPoint(x: cx - 14*scale, y: headY + 2*scale))
            p.closeSubpath()
        }
        ctx.fill(leftEar, with: .color(furColor))
        // Interior oreja izquierda
        let leftInner = Path { p in
            p.move(to: CGPoint(x: cx - 26*scale, y: headY + 8*scale))
            p.addLine(to: CGPoint(x: cx - 36*scale + wiggle*4*scale, y: headY - 14*scale))
            p.addLine(to: CGPoint(x: cx - 17*scale, y: headY + 2*scale))
            p.closeSubpath()
        }
        ctx.fill(leftInner, with: .color(Color("Canela").opacity(0.7)))

        // Oreja derecha
        let rightEar = Path { p in
            p.move(to: CGPoint(x: cx + 26*scale, y: headY + 10*scale))
            p.addLine(to: CGPoint(x: cx + 40*scale - wiggle*5*scale, y: headY - 22*scale))
            p.addLine(to: CGPoint(x: cx + 14*scale, y: headY + 2*scale))
            p.closeSubpath()
        }
        ctx.fill(rightEar, with: .color(furColor))
        let rightInner = Path { p in
            p.move(to: CGPoint(x: cx + 26*scale, y: headY + 8*scale))
            p.addLine(to: CGPoint(x: cx + 36*scale - wiggle*4*scale, y: headY - 14*scale))
            p.addLine(to: CGPoint(x: cx + 17*scale, y: headY + 2*scale))
            p.closeSubpath()
        }
        ctx.fill(rightInner, with: .color(Color("Canela").opacity(0.7)))
    }

    private func drawEyes(ctx: GraphicsContext, cx: CGFloat, headY: CGFloat, scale: CGFloat) {
        let eyeY = headY + 28*scale
        if mood == .sleeping {
            // Ojitos cerrados (arcos)
            var leftEye = Path()
            leftEye.move(to: CGPoint(x: cx - 18*scale, y: eyeY + 3*scale))
            leftEye.addQuadCurve(to: CGPoint(x: cx - 10*scale, y: eyeY + 3*scale), control: CGPoint(x: cx - 14*scale, y: eyeY - 3*scale))
            var rightEye = Path()
            rightEye.move(to: CGPoint(x: cx + 10*scale, y: eyeY + 3*scale))
            rightEye.addQuadCurve(to: CGPoint(x: cx + 18*scale, y: eyeY + 3*scale), control: CGPoint(x: cx + 14*scale, y: eyeY - 3*scale))
            ctx.stroke(leftEye,  with: .color(Color("Cocoa")), lineWidth: 2*scale)
            ctx.stroke(rightEye, with: .color(Color("Cocoa")), lineWidth: 2*scale)
        } else {
            // Ojos normales con parpadeo
            let eyeSize = 9*scale
            ctx.fill(Path(ellipseIn: CGRect(x: cx - 18*scale, y: eyeY, width: eyeSize, height: eyeSize * blinkOpacity)), with: .color(Color("Cocoa")))
            ctx.fill(Path(ellipseIn: CGRect(x: cx + 10*scale,  y: eyeY, width: eyeSize, height: eyeSize * blinkOpacity)), with: .color(Color("Cocoa")))
            // Brillito en los ojos
            ctx.fill(Path(ellipseIn: CGRect(x: cx - 15*scale, y: eyeY + 1*scale, width: 3*scale, height: 3*scale)), with: .color(.white))
            ctx.fill(Path(ellipseIn: CGRect(x: cx + 13*scale,  y: eyeY + 1*scale, width: 3*scale, height: 3*scale)), with: .color(.white))
        }
    }

    private func drawMouth(ctx: GraphicsContext, cx: CGFloat, noseY: CGFloat, scale: CGFloat) {
        var mouth = Path()
        switch mood {
        case .sleeping, .hungry:
            // Boca neutral
            mouth.move(to: CGPoint(x: cx - 8*scale, y: noseY + 10*scale))
            mouth.addLine(to: CGPoint(x: cx + 8*scale, y: noseY + 10*scale))
        default:
            // Sonrisa
            mouth.move(to: CGPoint(x: cx - 10*scale, y: noseY + 8*scale))
            mouth.addQuadCurve(
                to: CGPoint(x: cx + 10*scale, y: noseY + 8*scale),
                control: CGPoint(x: cx, y: noseY + 18*scale)
            )
        }
        ctx.stroke(mouth, with: .color(Color("Cocoa")), lineWidth: 2*scale)
    }

    private func drawPaws(ctx: GraphicsContext, cx: CGFloat, bodyY: CGFloat, scale: CGFloat) {
        let pawY = bodyY + 58*scale
        // Pata izquierda
        ctx.fill(Path(ellipseIn: CGRect(x: cx - 42*scale, y: pawY, width: 26*scale, height: 18*scale)), with: .color(furColor))
        // Pata derecha
        ctx.fill(Path(ellipseIn: CGRect(x: cx + 16*scale, y: pawY, width: 26*scale, height: 18*scale)), with: .color(furColor))
    }

    // MARK: - Overlays

    private var sleepingOverlay: some View {
        Text("zzz")
            .font(.system(size: size * 0.12, weight: .bold, design: .rounded))
            .foregroundStyle(Color("Cocoa").opacity(0.5))
            .offset(x: size * 0.3, y: -size * 0.15)
            .opacity(zzzOpacity)
    }

    private var superHappyOverlay: some View {
        ForEach(0..<5, id: \.self) { i in
            Image(systemName: "star.fill")
                .font(.system(size: size * 0.08))
                .foregroundStyle(Color("Waffle"))
                .scaleEffect(starScale)
                .offset(
                    x: CGFloat([-40, -20, 0, 20, 40][i]) * size / 160,
                    y: -size * 0.55 - CGFloat(i % 2 == 0 ? 5 : 0)
                )
        }
    }

    private var heartOverlay: some View {
        Image(systemName: "heart.fill")
            .font(.system(size: size * 0.1))
            .foregroundStyle(Color("Canela"))
            .offset(x: size * 0.32, y: -size * 0.35 + heartFloat)
            .opacity(0.8)
    }

    private func hatOverlay(id: String) -> some View {
        Group {
            switch id {
            case "hat_waffle":
                Text("🧇")
                    .font(.system(size: size * 0.18))
                    .offset(x: 0, y: -size * 0.38)
            case "hat_maple":
                Text("🎩")
                    .font(.system(size: size * 0.2))
                    .offset(x: 0, y: -size * 0.42)
            case "hat_crown":
                Text("👑")
                    .font(.system(size: size * 0.18))
                    .offset(x: 0, y: -size * 0.40)
            case "hat_chef":
                Text("👨‍🍳")
                    .font(.system(size: size * 0.18))
                    .offset(x: 0, y: -size * 0.40)
            default:
                EmptyView()
            }
        }
    }

    // MARK: - Animations

    private func startAnimations() {
        // Reiniciar
        blinkOpacity = 1
        tailAngle = 0
        bodyBounce = 0
        earWiggle = 0
        zzzOpacity = 0
        starScale = 0
        heartFloat = 0

        switch mood {
        case .sleeping:
            // Respiración suave + zzz parpadeante
            withAnimation(.easeInOut(duration: 2).repeatForever(autoreverses: true)) {
                bodyBounce = 3
            }
            withAnimation(.easeInOut(duration: 1.5).repeatForever(autoreverses: true)) {
                zzzOpacity = 1
            }

        case .hungry:
            // Cola triste, apenas se mueve
            withAnimation(.easeInOut(duration: 3).repeatForever(autoreverses: true)) {
                tailAngle = 8
            }

        case .fed:
            // Cola moviéndose suave + corazón flotante
            withAnimation(.easeInOut(duration: 1.2).repeatForever(autoreverses: true)) {
                tailAngle = 18
            }
            withAnimation(.easeInOut(duration: 1.8).repeatForever(autoreverses: true)) {
                heartFloat = -8
            }

        case .happy:
            // Cola feliz + orejas moviéndose + pequeño bote
            withAnimation(.easeInOut(duration: 0.8).repeatForever(autoreverses: true)) {
                tailAngle = 25
                earWiggle = 12
            }
            withAnimation(.spring(response: 0.5).repeatForever(autoreverses: true)) {
                bodyBounce = -4
            }

        case .superHappy:
            // Todo a la vez — más energía
            withAnimation(.easeInOut(duration: 0.5).repeatForever(autoreverses: true)) {
                tailAngle = 35
                earWiggle = 18
            }
            withAnimation(.spring(response: 0.4).repeatForever(autoreverses: true)) {
                bodyBounce = -7
            }
            withAnimation(.spring(response: 0.6, dampingFraction: 0.4)) {
                starScale = 1
            }
        }

        // Parpadeo periódico (todos los moods activos)
        if mood != .sleeping {
            scheduleBlink()
        }
    }

    private func scheduleBlink() {
        DispatchQueue.main.asyncAfter(deadline: .now() + Double.random(in: 2...5)) {
            withAnimation(.easeInOut(duration: 0.08)) { blinkOpacity = 0.05 }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                withAnimation(.easeInOut(duration: 0.08)) { blinkOpacity = 1 }
                scheduleBlink()
            }
        }
    }
}

#Preview {
    VStack(spacing: 20) {
        HStack(spacing: 16) {
            ForEach(FoxMood.allCases, id: \.self) { mood in
                VStack {
                    FoxSVGView(mood: mood, outfitId: nil, size: 100)
                    Text(mood.label).font(.caption2)
                }
            }
        }
    }
    .padding()
    .background(Color("Crema"))
}
