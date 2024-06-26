import Foundation
import UIKit

final class GameButton: UIButton {
    
    private var callback: () -> ()
    private var timer: Timer!
    
    init(frame: CGRect, callback: @escaping () -> ()) {
        self.callback = callback
        
        super.init(frame: frame)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        timer = Timer.scheduledTimer(withTimeInterval: 0.01, repeats: true, block: { [weak self] (timer :Timer) in
            self?.callback()
        })
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        timer.invalidate()
    }
}
