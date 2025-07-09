import SwiftUI

struct TopFrameView: Shape {
    func path(in rect: CGRect) -> Path {
        let bezierPath = UIBezierPath()
        bezierPath.move(to: CGPoint(x: 53.22, y: 4.36))
        for (to, controlPoint1, controlPoint2) in [(CGPoint(x: 60.83, y: 13.06), CGPoint(x: 57.76, y: 7.77), CGPoint(x: 60.14, y: 11.68)), (CGPoint(x: 68.43, y: 22.84), CGPoint(x: 63, y: 17.4), CGPoint(x: 65.05, y: 20.96)), (CGPoint(x: 75.16, y: 23.98), CGPoint(x: 70.49, y: 23.98), CGPoint(x: 75.16, y: 23.98))] {
            bezierPath.addCurve(to: to, controlPoint1: controlPoint1, controlPoint2: controlPoint2)
        }
        bezierPath.addLine(to: CGPoint(x: 0.84, y: 23.98))
        for (to, controlPoint1, controlPoint2) in [(CGPoint(x: 7.57, y: 22.84), CGPoint(x: 0.84, y: 23.98), CGPoint(x: 5.51, y: 23.98)), (CGPoint(x: 15.17, y: 13.06), CGPoint(x: 10.95, y: 20.96), CGPoint(x: 13, y: 17.4)), (CGPoint(x: 22.78, y: 4.36), CGPoint(x: 15.86, y: 11.68), CGPoint(x: 18.24, y: 7.77)), (CGPoint(x: 36.38, y: -0), CGPoint(x: 27.58, y: 0.77), CGPoint(x: 33.55, y: 0.1)), (CGPoint(x: 38, y: 0), CGPoint(x: 37.39, y: -0.04), CGPoint(x: 38, y: 0)), (CGPoint(x: 53.22, y: 4.36), CGPoint(x: 38, y: 0), CGPoint(x: 46.7, y: -0.53))] {
            bezierPath.addCurve(to: to, controlPoint1: controlPoint1, controlPoint2: controlPoint2)
        }
        bezierPath.close()
        return Path(bezierPath.cgPath)
    }
}
struct TabItemDescription {
    var imageName: String
    var title: String
    func iconView(_ foregroundColor: Color) -> some View { Image(systemName: imageName).font(.system(size: 24)).foregroundColor(foregroundColor) }
    func labelView(_ foregroundColor: Color) -> some View { Text(title).font(.system(size: 7, weight: .bold)).foregroundColor(foregroundColor) }
}
enum Defs {
    static let tabItems: [TabItemDescription] = [
        .init(imageName: "tray.and.arrow.down.fill", title: "LABEL"),
        .init(imageName: "person.2.fill", title: "PEOPLE"),
        .init(imageName: "mappin.and.ellipse", title: "LOCATION"),
        .init(imageName: "party.popper.fill", title: "EVENT"),
        .init(imageName: "calendar", title: "DATE")
    ]
//    static let accentColor = Color(UIColor(red: 0.553, green: 0.455, blue: 0.929, alpha: 1.000));
    static let accentColor = Color.white
    //static let accentColor = Color(red: 234/255, green: 224/255, blue: 213/255)
    static let backgroundColor = Color.white
    //static let backgroundColor = Color(red: 234/255, green: 224/255, blue: 213/255)
    
    ///SEE GREEN
//    static let seeGreenColor = Color(red: 13/255, green: 96/255, blue: 104/255)
//    static let lightSeeGreenColor = Color(red: 132/255, green: 197/255, blue: 205/255)
    
    ///PURPLE
    static let seeGreenColor = Color(red: 139/255, green: 134/255, blue: 227/255)
    static let lightSeeGreenColor = Color(red: 178/255, green: 175/255, blue: 229/255)
    static let lightPink = Color(red: 221/255, green: 166/255, blue: 182/255)
    
    static let topFrameSize = CGSize(width: 75, height: 24)
    static let tabbarHeight = CGFloat(49)
    static let bottomSafeArea = CGFloat(40)
    static let iconCircleEdge = CGFloat(40)
    static let labelOffset = CGSize(width: 0, height: 32)
    static let bottomSafeAreaOffset = CGSize(width: 0, height: Defs.bottomSafeArea * 0.5)
}
