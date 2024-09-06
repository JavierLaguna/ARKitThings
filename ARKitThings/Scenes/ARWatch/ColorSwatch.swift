import UIKit

final class ColorSwatch: UIView {
    
    typealias ColorSelected = (UIColor) -> Void
    
    private var color: UIColor
    private var colorSelected: ColorSelected
    
    init(color: UIColor, frame: CGRect = CGRect(x: 0, y: 0, width: 50, height: 50), colorSelected: @escaping ColorSelected) {
        self.colorSelected = colorSelected
        self.color = color
        
        super.init(frame: frame)
        
        registerGestureRecognizers()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func draw(_ rect: CGRect) {
        let path = UIBezierPath(ovalIn: CGRect(x: 0, y: 0, width: 50, height: 50))
        let layer = CAShapeLayer()
        layer.path = path.cgPath
        layer.fillColor = self.color.cgColor
        self.layer.addSublayer(layer)
    }
    
    private func registerGestureRecognizers() {
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(tapped))
        self.addGestureRecognizer(tapGestureRecognizer)
    }
    
    @objc private func tapped(recognizer: UITapGestureRecognizer) {
        self.colorSelected(self.color)
    }
}
