//
//  ViewController.swift
//  SaveTheDot
//
//  Created by Jake Lin on 6/18/16.
//  Copyright © 2016 Jake Lin. All rights reserved.
//

import UIKit
import AVOSCloudIM
import AVFoundation

class ViewController: UIViewController {
    
    // MARK: - enum
    fileprivate enum ScreenEdge: Int {
        case top = 0
        case right = 1
        case bottom = 2
        case left = 3
    }
    
    fileprivate enum GameState {
        case ready
        case playing
        case gameOver
    }
    
    
    // MARK: - Constants
    fileprivate let radius: CGFloat = 10
    fileprivate let playerAnimationDuration = 5.0
    fileprivate let enemySpeed: CGFloat = 60 // points per second
    fileprivate let colors = [#colorLiteral(red: 0.08235294118, green: 0.6980392157, blue: 0.5411764706, alpha: 1), #colorLiteral(red: 0.07058823529, green: 0.5725490196, blue: 0.4470588235, alpha: 1), #colorLiteral(red: 0.9333333333, green: 0.7333333333, blue: 0, alpha: 1), #colorLiteral(red: 0.9411764706, green: 0.5450980392, blue: 0, alpha: 1), #colorLiteral(red: 0.1411764706, green: 0.7803921569, blue: 0.3529411765, alpha: 1), #colorLiteral(red: 0.1176470588, green: 0.6431372549, blue: 0.2941176471, alpha: 1), #colorLiteral(red: 0.8784313725, green: 0.4156862745, blue: 0.03921568627, alpha: 1), #colorLiteral(red: 0.7882352941, green: 0.2470588235, blue: 0, alpha: 1), #colorLiteral(red: 0.721568644, green: 0.8862745166, blue: 0.5921568871, alpha: 1), #colorLiteral(red: 0.2588235438, green: 0.7568627596, blue: 0.9686274529, alpha: 1), #colorLiteral(red: 0.8823529412, green: 0.2, blue: 0.1607843137, alpha: 1), #colorLiteral(red: 0.7019607843, green: 0.1411764706, blue: 0.1098039216, alpha: 1), #colorLiteral(red: 0.5568627715, green: 0.3529411852, blue: 0.9686274529, alpha: 1), #colorLiteral(red: 0.9764705896, green: 0.850980401, blue: 0.5490196347, alpha: 1), #colorLiteral(red: 0.6862745098, green: 0.7137254902, blue: 0.7333333333, alpha: 1), #colorLiteral(red: 0.721568644, green: 0.8862745166, blue: 0.5921568871, alpha: 1), #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1), #colorLiteral(red: 0.9568627477, green: 0.6588235497, blue: 0.5450980663, alpha: 1), #colorLiteral(red: 0.521568656, green: 0.1098039225, blue: 0.05098039284, alpha: 1)]

    // MARK: - fileprivate
    fileprivate var playerView = UIView(frame: .zero)
    fileprivate var playerAnimator: UIViewPropertyAnimator?
    
    fileprivate var enemyViews = [UIView]()
    fileprivate var enemyAnimators = [UIViewPropertyAnimator]()
    fileprivate var enemyTimer: Timer?
    
    fileprivate var displayLink: CADisplayLink?
    fileprivate var beginTimestamp: TimeInterval = 0
    fileprivate var elapsedTime: TimeInterval = 0
    
    fileprivate var gameState = GameState.ready
    
    // MARK: - IBOutlets
    @IBOutlet weak var clockLabel: UILabel!
    @IBOutlet weak var startLabel: UILabel!
    @IBOutlet weak var Highest: UILabel!
    
    fileprivate var player:AVAudioPlayer?
    
    fileprivate var biu:AVAudioPlayer?
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupPlayerView()
        prepareGame()
        
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        // First touch to start the game
        
        let path = Bundle.main.path(forResource:"bg_touch", ofType:"mp3")
        let url = URL.init(fileURLWithPath: path!)
                
        do{
            biu = try AVAudioPlayer.init(contentsOf:url)
        }catch{
            biu=nil;
            print("error")
        }
        biu?.play()


        
        
        if gameState == .ready {
            startGame()
        }
        
        if let touchLocation = event?.allTouches?.first?.location(in: view) {
            // Move the player to the new position
            movePlayer(to: touchLocation)
            
            // Move all enemies to the new position to trace the player
            moveEnemies(to: touchLocation)
        }
    }
    
    // MARK: - Selectors
    func generateEnemy(timer: Timer) {
        // Generate an enemy with random position
        let screenEdge = ScreenEdge.init(rawValue: Int(arc4random_uniform(4)))
        let screenBounds = UIScreen.main.bounds
        var position: CGFloat = 0
        
        switch screenEdge! {
        case .left, .right:
            position = CGFloat(arc4random_uniform(UInt32(screenBounds.height)))
        case .top, .bottom:
            position = CGFloat(arc4random_uniform(UInt32(screenBounds.width)))
        }
        
        // Add the new enemy to the view
        let enemyView = UIView(frame: .zero)
        enemyView.bounds.size = CGSize(width: radius, height: radius)
        enemyView.backgroundColor = getRandomColor()
        
        switch screenEdge! {
        case .left:
            enemyView.center = CGPoint(x: 0, y: position)
        case .right:
            enemyView.center = CGPoint(x: screenBounds.width, y: position)
        case .top:
            enemyView.center = CGPoint(x: position, y: screenBounds.height)
        case .bottom:
            enemyView.center = CGPoint(x: position, y: 0)
        }
        
        view.addSubview(enemyView)
        
        // Start animation
        let duration = getEnemyDuration(enemyView: enemyView)
        let enemyAnimator = UIViewPropertyAnimator(duration: duration,
                                                   curve: .linear,
                                                   animations: { [weak self] in
                                                    if let strongSelf = self {
                                                        enemyView.center = strongSelf.playerView.center
                                                    }
            }
        )
        enemyAnimator.startAnimation()
        enemyAnimators.append(enemyAnimator)
        enemyViews.append(enemyView)
    }
    
    func tick(sender: CADisplayLink) {
        updateCountUpTimer(timestamp: sender.timestamp)
        checkCollision()
    }
}

fileprivate extension ViewController {
    func setupPlayerView() {
        playerView.bounds.size = CGSize(width: radius * 2, height: radius * 2)
        playerView.layer.cornerRadius = radius
        //    playerView.backgroundColor = #colorLiteral(red: 0.7098039216, green: 0.4549019608, blue: 0.9607843137, alpha: 1)
        
        let imageView = UIImageView(image:UIImage(named:"5"))
        
        let frame = CGRect(x: 0, y: 0, width: radius * 2, height: radius * 2)
        imageView.frame = frame
        playerView.addSubview(imageView)
        
        view.addSubview(playerView)
        
        
    }
    
    func startEnemyTimer() {
        enemyTimer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(generateEnemy(timer:)), userInfo: nil, repeats: true)
    }
    
    func stopEnemyTimer() {
        guard let enemyTimer = enemyTimer,
            enemyTimer.isValid else {
                return
        }
        enemyTimer.invalidate()
    }
    
    func startDisplayLink() {
        displayLink = CADisplayLink(target: self, selector: #selector(tick(sender:)))
        displayLink?.add(to: RunLoop.main, forMode: RunLoopMode.defaultRunLoopMode)
    }
    
    func stopDisplayLink() {
        displayLink?.isPaused = true
        displayLink?.remove(from: RunLoop.main, forMode: RunLoopMode.defaultRunLoopMode)
        displayLink = nil
    }
    
    func getRandomColor() -> UIColor {
        let index = arc4random_uniform(UInt32(colors.count))
        return colors[Int(index)]
    }
    
    func getEnemyDuration(enemyView: UIView) -> TimeInterval {
        let dx = playerView.center.x - enemyView.center.x
        let dy = playerView.center.y - enemyView.center.y
        return TimeInterval(sqrt(dx * dx + dy * dy) / enemySpeed)
    }
    
    func gameOver() {
        player?.stop()
        player = nil
        stopGame()
        displayGameOverAlert()
    }
    
    func stopGame() {
        stopEnemyTimer()
        stopDisplayLink()
        stopAnimators()
        gameState = .gameOver
    }
    
    func prepareGame() {
        removeEnemies()
        centerPlayerView()
        popPlayerView()
        startLabel.isHidden = false
        clockLabel.text = "00:00.000"
        Highest.text = format(timeInterval:(readWithNSUserDefaults()))
        gameState = .ready
    }
    
    func startGame() {
        
        let path = Bundle.main.path(forResource:"bgMusic", ofType:"mp3")
        let url = URL.init(fileURLWithPath: path!)
        
        do{
            player = try AVAudioPlayer.init(contentsOf:url)
        }catch{
            player=nil;
            print("error")
        }
        player?.play()
        
        startEnemyTimer()
        startDisplayLink()
        startLabel.isHidden = true
        beginTimestamp = 0
        gameState = .playing
    }
    
    func removeEnemies() {
        enemyViews.forEach {
            $0.removeFromSuperview()
        }
        enemyViews = []
    }
    
    func stopAnimators() {
        playerAnimator?.stopAnimation(true)
        playerAnimator = nil
        enemyAnimators.forEach {
            $0.stopAnimation(true)
        }
        enemyAnimators = []
    }
    
    func updateCountUpTimer(timestamp: TimeInterval) {
        if beginTimestamp == 0 {
            beginTimestamp = timestamp
        }
        elapsedTime = timestamp - beginTimestamp
        clockLabel.text = format(timeInterval: elapsedTime)
    }
    
    func format(timeInterval: TimeInterval) -> String {
        let interval = Int(timeInterval)
        let seconds = interval % 60
        let minutes = (interval / 60) % 60
        let milliseconds = Int(timeInterval * 1000) % 1000
        return String(format: "%02d:%02d.%03d", minutes, seconds, milliseconds)
    }
    
    func checkCollision() {
        enemyViews.forEach {
            guard let playerFrame = playerView.layer.presentation()?.frame,
                let enemyFrame = $0.layer.presentation()?.frame,
                playerFrame.intersects(enemyFrame) else {
                    return
            }
            gameOver()
        }
    }
    
    func movePlayer(to touchLocation: CGPoint) {
        playerAnimator = UIViewPropertyAnimator(duration: playerAnimationDuration,
                                                dampingRatio: 0.5,
                                                animations: { [weak self] in
                                                    self?.playerView.center = touchLocation
        })
        playerAnimator?.startAnimation()
    }
    
    func moveEnemies(to touchLocation: CGPoint) {
        for (index, enemyView) in enemyViews.enumerated() {
            let duration = getEnemyDuration(enemyView: enemyView)
            if enemyAnimators.count == 0 {
                return
                
            }
            enemyAnimators[index] = UIViewPropertyAnimator(duration: duration,
                                                           curve: .linear,
                                                           animations: {
                                                            enemyView.center = touchLocation
            })
            enemyAnimators[index].startAnimation()
        }
    }
    
    func displayGameOverAlert() {
        
        
        let path = Bundle.main.path(forResource:"bgGameOver", ofType:"mp3")
        let url = URL.init(fileURLWithPath: path!)
        

        do{
            biu = try AVAudioPlayer.init(contentsOf:url)
        }catch{
            biu=nil;
            print("error")
        }
        biu?.play()
        

        
        
       //比较分数
        let beforH = self.readWithNSUserDefaults()


        if (elapsedTime > beforH){
            //计入本地
            self.saveWithNSUserDefaults(time :elapsedTime)
        }
        
        let (title, message) = getGameOverTitleAndMessage()
        let alert = UIAlertController(title: NSLocalizedString("GameOver", comment: "default"), message: message, preferredStyle: .alert)
        let action = UIAlertAction(title: title, style: .default,
                                   handler: { _ in
                                    self.prepareGame()
        }
        )
        let action2 = UIAlertAction(title: NSLocalizedString("ShowLeaderboards", comment: "default"), style: .default,
                                   handler: { _ in
                                    self.prepareGame()
                                    
                                    let story : UIStoryboard = UIStoryboard.init(name: "Main", bundle: nil)
                                    
                                    let leaderBoardVC = story.instantiateViewController(withIdentifier: "leaderboardvc")
                                    
                                    self.present(leaderBoardVC, animated: true, completion: nil)
        }
        )

        alert.addAction(action2)
        alert.addAction(action)
        self.present(alert, animated: true, completion: nil)
    }
    
    func getGameOverTitleAndMessage() -> (String, String) {
        let elapsedSeconds = Int(elapsedTime) % 60
        switch elapsedSeconds {
        case 0..<10: return (NSLocalizedString("Action",  comment:"default" ), NSLocalizedString("Tip1", comment:"default"))
        case 10..<30: return (NSLocalizedString("Action", comment:"default"), NSLocalizedString("Tip2", comment:"default"))
        case 30..<60: return (NSLocalizedString("Action", comment:"default"), NSLocalizedString("Tip3", comment:"default"))
        default:
            return (NSLocalizedString("Action", comment:"default"), NSLocalizedString("Tip1", comment:"default"))
        }
    }
    
    func saveWithNSUserDefaults(time :Double) {
        // 1、利用NSUserDefaults存储数据
        let defaults = UserDefaults.standard;
        // 2、存储数据
        defaults.set(time, forKey: "highest");
        // 3、同步数据
        defaults.synchronize();
        
        let nickName = defaults.string(forKey:"nickname")
        
        let todo : AVObject = AVObject.init(className: "number")
        todo.setObject(nickName, forKey: "name1")
        todo.setObject((time :elapsedTime), forKey: "grade1")
        
        todo.save()

    }
    func readWithNSUserDefaults() -> Double{
        let defaults = UserDefaults.standard;
        let time = defaults.double(forKey:"highest")
        
        return time
    }
    
    
    func centerPlayerView() {
        // Place the player in the center of the screen.
        playerView.center = view.center
    }
    
    // Copy from IBAnimatable
    func popPlayerView() {
        let animation = CAKeyframeAnimation(keyPath:"transform.scale")
        animation.values = [0, 0.2, -0.2, 0.2, 0]
        animation.keyTimes = [0, 0.2, 0.4, 0.6, 0.8, 1]
        animation.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut)
        animation.duration = CFTimeInterval(0.7)
        animation.isAdditive = true
        animation.repeatCount = 1
        animation.beginTime = CACurrentMediaTime()
        playerView.layer.add(animation, forKey:"pop")
    }
    
}
