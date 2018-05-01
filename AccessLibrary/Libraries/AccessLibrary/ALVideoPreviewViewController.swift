
import UIKit
import Photos

class ALVideoPreviewViewController: UIViewController {
    
    @IBOutlet weak var videoPlayerView: ALVideoPlayerView!
    
    
    var asset: PHAsset?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.initNav()
        self.initPlayer()
    }
    
    override func didMove(toParentViewController parent: UIViewController?) {
        // parent = nil の時が navigationItem の戻るボタンで戻った時
        if parent == nil {
            videoPlayerView.finish()
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    private func initNav() {
        self.title = "Video"
    }
    
    
    private func initPlayer() {
        self.asset?.toAVAsset { (asset: AVAsset?) in
            if let a: AVAsset = asset {
                self.videoPlayerView.play(lists: [a])
            }
        }
    }
    
}
