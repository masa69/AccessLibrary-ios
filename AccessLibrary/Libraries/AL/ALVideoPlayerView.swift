
import UIKit
import AVFoundation

class ALVideoPlayerView: UIView {

    private var items: [AVPlayerItem] = [AVPlayerItem]()
    
    var player: AVPlayer? {
        get {
            return self.playerLayer.player
        }
        set {
            playerLayer.player = newValue
        }
    }
    
    private var playerLayer: AVPlayerLayer {
        get {
            return self.layer as! AVPlayerLayer
        }
    }
    
    var willPlayItem: (() -> Void)?
    
    var didPause: (() -> Void)?
    
    var didPlay: (() -> Void)?
    
    var progress: ((_ progressPercent: CGFloat) -> Void)?
    
    var isReady: Bool = false
    
    private var promise: Timer?
    
    private var myContext: Int = 0
    
    private var isBlockCallback: Bool = false
    
    private var lastItemIndex: Int = 0
    
    var currentItemIndex: Int = 0
    
    // UIView のサブクラスを作り layerClass をオーバーライドして AVPlayerLayer に差し替える
    override class var layerClass: AnyClass {
        get {
            return AVPlayerLayer.self
        }
    }
    
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.backgroundColor = UIColor.black
    }
    
    
    private func addObserver() {
        self.player?.addObserver(self, forKeyPath: "rate", options: .new, context: &self.myContext)
        if self.promise == nil {
            self.promise = Timer.scheduledTimer(timeInterval: 0.01, target: self, selector: #selector(self.playing(_:)), userInfo: nil, repeats: true)
        }
    }
    
    private func removeObserver() {
        self.player?.removeObserver(self, forKeyPath: "rate")
        NotificationCenter.default.removeObserver(self)
        self.promise?.invalidate()
        self.promise = nil
    }
    
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if context == &self.myContext {
            if keyPath == "rate" {
                if let rate: Float = player?.rate {
                    switch rate {
                    case 0.0:// pause
                        self.didPause?()
                    case 1.0:// play
                        self.didPlay?()
                    default:
                        break
                    }
                }
            }
        } else {
            super.observeValue(forKeyPath: keyPath, of: object, change: change, context: context)
        }
    }
    
    
    func play(lists: [AVAsset]) {
        let videoPlayers = self.getPlayers(lists: lists)
        self.player = videoPlayers
        self.player?.actionAtItemEnd = .none
        // 再生 / ポーズの判定を監視する
        self.addObserver()
        self.player?.play()
    }
    
    
    func resume() {
        self.player?.play()
    }
    
    
    func pause() {
        self.player?.pause()
    }
    
    
    var isReplacing: Bool = false
    
    
    func next() {
        if self.lastItemIndex == 0 {
            let seekTime: CMTime = kCMTimeZero
            self.player?.seek(to: seekTime)
            self.isBlockCallback = false
            return
        }
        self.isReplacing = true
        let seekTime: CMTime = kCMTimeZero
        self.currentItemIndex = (self.currentItemIndex == self.lastItemIndex) ? 0 : self.currentItemIndex + 1
        self.player?.replaceCurrentItem(with: self.items[self.currentItemIndex])
        self.player?.seek(to: seekTime)
    }
    
    
    func previous() {
        if self.lastItemIndex == 0 {
            return
        }
        self.isReplacing = true
        let seekTime: CMTime = kCMTimeZero
        self.currentItemIndex = (self.currentItemIndex == 0) ? self.lastItemIndex : self.currentItemIndex - 1
        self.player?.replaceCurrentItem(with: self.items[self.currentItemIndex])
        self.player?.seek(to: seekTime)
    }
    
    
    private func getPlayers(lists: [AVAsset]) -> AVPlayer {
        self.items = [AVPlayerItem]()
        for (i, list) in lists.enumerated() {
            let item: AVPlayerItem = AVPlayerItem(asset: list)
            self.lastItemIndex = i
            NotificationCenter.default.addObserver(self, selector: #selector(self.willPlay(_:)), name: Notification.Name.AVPlayerItemNewAccessLogEntry, object: item)
            NotificationCenter.default.addObserver(self, selector: #selector(self.didPlay(_:)), name: Notification.Name.AVPlayerItemDidPlayToEndTime, object: item)
            self.items.append(item)
        }
//        self.playerLayer.videoGravity = .resizeAspectFill
        self.playerLayer.videoGravity = .resizeAspect
        return AVPlayer(playerItem: self.items[self.currentItemIndex])
    }
    
    
    func finish() {
        self.removeObserver()
        self.player = nil
    }
    
    
    // MARK: - Notification
    
    @objc func willPlay(_ sender: Notification) {
        print("will play")
        self.isReady = true
        self.isBlockCallback = false
    }
    
    
    @objc func didPlay(_ sender: Notification) {
        self.next()
    }
    
    
    // MARK: - Timer
    
    @objc func playing(_ sender: Timer) {
        if !self.isReady {
            return
        }
        guard let item: AVPlayerItem = self.player?.currentItem else {
            return
        }
        guard let currentTime: Double = self.player?.currentTime().seconds else {
            return
        }
        let durationSec: Int = Int(item.duration.seconds * 1000)
        let progressPercentTemp: Double = (currentTime * 1000) / Double(durationSec)
        let separation: CGFloat = 1 / CGFloat(self.items.count)
        let progressSeparation: CGFloat = separation * CGFloat(self.currentItemIndex)
        var progressPercent: CGFloat = CGFloat(progressPercentTemp * 1.05)
        
        progressPercent = (progressPercent > 1) ? 1 : progressPercent
        
        if self.isReplacing {
            progressPercent = 0
        }
        
        progressPercent = (progressPercent * separation) + progressSeparation
        
        self.progress?(progressPercent)
        
        if self.isBlockCallback {
            return
        }
        
        if currentTime > 0 {
            self.isBlockCallback = true
            self.isReplacing = false
            self.willPlayItem?()
        }
    }

}
