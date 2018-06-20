
import SpriteKit
import AVFoundation

class GameScene: SKScene {

  let zombie = SKSpriteNode(imageNamed: "zombie1")
  var lastUpdateTime: TimeInterval = 0
  var dt: TimeInterval = 0
  var mutebutton = SKSpriteNode()
  var mute: Bool = false
  let zombieMovePointsPerSec: CGFloat = 480.0
  var velocity = CGPoint.zero
  let playableRect: CGRect
  var lastTouchLocation: CGPoint?
  let zombieRotateRadiansPerSec: CGFloat = 4.0 * π
  let zombieAnimation: SKAction
  var invincible = false
  let catMovePointsPerSec: CGFloat = 480.0
  var lives = 5
  var gameOver = false
  let cameraNode = SKCameraNode()
  let cameraMovePointsPerSec: CGFloat = 200.0
  let livesLabel = SKLabelNode(fontNamed: "Glimstick")
  var obj = 0
  
  let catCollisionSound: SKAction = SKAction.playSoundFileNamed(
    "hitCat.wav", waitForCompletion: false)
  let enemyCollisionSound: SKAction = SKAction.playSoundFileNamed(
    "hitCatLady.wav", waitForCompletion: false)

  override init(size: CGSize) {
    let maxAspectRatio:CGFloat = 16.0/9.0
    let playableHeight = size.width / maxAspectRatio
    let playableMargin = (size.height-playableHeight)/2.0
    playableRect = CGRect(x: 0, y: playableMargin,
                          width: size.width,
                          height: playableHeight)
    // 1
    var textures:[SKTexture] = []
    // 2
    for i in 1...4 {
      textures.append(SKTexture(imageNamed: "zombie\(i)"))
    }
    // 3
    textures.append(textures[2])
    textures.append(textures[1])

    // 4
    zombieAnimation = SKAction.animate(with: textures,
      timePerFrame: 0.1)

    super.init(size: size)
  }

  required init(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  func debugDrawPlayableArea() {
    let shape = SKShapeNode(rect: playableRect)
    shape.strokeColor = SKColor.red
    shape.lineWidth = 4.0
    addChild(shape)
  }

  override func didMove(to view: SKView) {
    let mutetax = SKTexture(imageNamed: "mute1")
    
    backgroundColor = SKColor.black

    for i in 0...1 {
      let background = backgroundNode()
      background.anchorPoint = CGPoint.zero
      background.position =
        CGPoint(x: CGFloat(i)*background.size.width, y: 0)
      background.name = "background"
      background.zPosition = -1
      addChild(background)
    }

    zombie.position = CGPoint(x: 400, y: 400)
    zombie.zPosition = 100
    addChild(zombie)
    // zombie.run(SKAction.repeatForever(zombieAnimation))

    run(SKAction.repeatForever(
      SKAction.sequence([SKAction.run() { [weak self] in
                          self?.spawnEnemy()
                        },
                        SKAction.wait(forDuration: 2.0)])))

    run(SKAction.repeatForever(
      SKAction.sequence([SKAction.run() { [weak self] in
                          self?.spawnCat()
                        },
                        SKAction.wait(forDuration: 1.0)])))
  
    if (obj == 1){                                             // flower
      
      run(SKAction.repeatForever(
        SKAction.sequence([SKAction.run() { [weak self] in
          self?.spawnSun()
          },
                           SKAction.wait(forDuration: 3.0)])))
    }
      if (obj == 2){                                      //lady
        run(SKAction.repeatForever(
          SKAction.sequence([SKAction.run() { [weak self] in
            self?.spawnEnemy1()
            },
                             SKAction.wait(forDuration: 2.0)])))
      }
      if (obj == 3){                                            //small
        run(SKAction.repeatForever(
          SKAction.sequence([SKAction.run() { [weak self] in
            self?.spawnSmallFish()
            },
                             SKAction.wait(forDuration: 5.0)])))
        
      }
    
    if (obj == 4){                                                  //big
      run(SKAction.repeatForever(
        SKAction.sequence([SKAction.run() { [weak self] in
          self?.spawnBigFish()
          },
                           SKAction.wait(forDuration: 10.0)])))
      
    }
    

    // debugDrawPlayableArea()

    playBackgroundMusic(filename: "backgroundMusic.mp3")

    addChild(cameraNode)
    camera = cameraNode
    cameraNode.position = CGPoint(x: size.width/2, y: size.height/2)

    livesLabel.text = "Lives: X"
    livesLabel.fontColor = SKColor.black
    livesLabel.fontSize = 100
    livesLabel.zPosition = 150
    livesLabel.horizontalAlignmentMode = .left
    livesLabel.verticalAlignmentMode = .bottom
    livesLabel.position = CGPoint(
      x: -playableRect.size.width/2 + CGFloat(20),
      y: -playableRect.size.height/2 + CGFloat(20))
    cameraNode.addChild(livesLabel)
    
    
    mutebutton = SKSpriteNode(texture: mutetax)
    mutebutton.position = CGPoint(x: playableRect.size.width/2 - CGFloat(50),y: playableRect.size.height/2 - CGFloat(50))
    mutebutton.setScale(0.25)
    cameraNode.addChild(mutebutton)

  }

  override func update(_ currentTime: TimeInterval) {
    if lastUpdateTime > 0 {
      dt = currentTime - lastUpdateTime
    } else {
      dt = 0
    }
    lastUpdateTime = currentTime

    /*
    if let lastTouchLocation = lastTouchLocation {
      let diff = lastTouchLocation - zombie.position
      if diff.length() <= zombieMovePointsPerSec * CGFloat(dt) {
        zombie.position = lastTouchLocation
        velocity = CGPoint.zero
        stopZombieAnimation()
      } else {
      */
        move(sprite: zombie, velocity: velocity)
        rotate(sprite: zombie, direction: velocity, rotateRadiansPerSec: zombieRotateRadiansPerSec)
      /*}
    }*/

    boundsCheckZombie()
    // checkCollisions()
    moveTrain()
    moveCamera()
    livesLabel.text = "Lives: \(lives)"

    if lives <= 0 && !gameOver {
      gameOver = true
      print("You lose!")
      backgroundMusicPlayer.stop()

      // 1
      let gameOverScene = GameOverScene(size: size, won: false)
      gameOverScene.scaleMode = scaleMode
      // 2
      let reveal = SKTransition.flipHorizontal(withDuration: 0.5)
      // 3
      view?.presentScene(gameOverScene, transition: reveal)

    }

    // cameraNode.position = zombie.position
  }

  override func didEvaluateActions() {
    checkCollisions()
  }

  func move(sprite: SKSpriteNode, velocity: CGPoint) {
    let amountToMove = velocity * CGFloat(dt)
    sprite.position += amountToMove
  }

  func moveZombieToward(location: CGPoint) {
    startZombieAnimation()
    let offset = location - zombie.position
    let direction = offset.normalized()
    velocity = direction * zombieMovePointsPerSec
  }

  func sceneTouched(touchLocation:CGPoint) {
    lastTouchLocation = touchLocation
    moveZombieToward(location: touchLocation)
  }

  override func touchesBegan(_ touches: Set<UITouch>,
      with event: UIEvent?) {
    if let touch = touches.first {
      let pos = touch.location(in: self)
      let node = self.atPoint(pos)
      
      if node == mutebutton   {
        if mute {
          
          print("The button will now turn on music.")
          mute = false
          self.mutebutton.texture = SKTexture(imageNamed: "mute1")
          
          
          backgroundMusicPlayer.play()
        
        } else {
         
          print("the button will now turn off music.")
          mute = true
          self.mutebutton.texture = SKTexture(imageNamed: "mute")
          
          backgroundMusicPlayer.stop()
        }
      }
      
      
      
      
    guard let touch = touches.first else {
      return
    }
    let touchLocation = touch.location(in: self)
    sceneTouched(touchLocation: touchLocation)
  }
  }
  override func touchesMoved(_ touches: Set<UITouch>,
      with event: UIEvent?) {
    guard let touch = touches.first else {
      return
    }
    let touchLocation = touch.location(in: self)
    sceneTouched(touchLocation: touchLocation)
  }

  func boundsCheckZombie() {
    let bottomLeft = CGPoint(x: cameraRect.minX, y: cameraRect.minY)
    let topRight = CGPoint(x: cameraRect.maxX, y: cameraRect.maxY)

    if zombie.position.x <= bottomLeft.x {
      zombie.position.x = bottomLeft.x
      velocity.x = abs(velocity.x)
    }
    if zombie.position.x >= topRight.x {
      zombie.position.x = topRight.x
      velocity.x = -velocity.x
    }
    if zombie.position.y <= bottomLeft.y {
      zombie.position.y = bottomLeft.y
      velocity.y = -velocity.y
    }
    if zombie.position.y >= topRight.y {
      zombie.position.y = topRight.y
      velocity.y = -velocity.y
    }
  }

  func rotate(sprite: SKSpriteNode, direction: CGPoint, rotateRadiansPerSec: CGFloat) {
    let shortest = shortestAngleBetween(angle1: sprite.zRotation, angle2: velocity.angle)
    let amountToRotate = min(rotateRadiansPerSec * CGFloat(dt), abs(shortest))
    sprite.zRotation += shortest.sign() * amountToRotate
  }

  func spawnSun() {                                                           //sunflower
   
    let sun = SKSpriteNode(imageNamed: "sunflower")
    sun.name = "sunflower"
    sun.position = CGPoint(
      x: CGFloat.random(min: cameraRect.minX,
                        max: cameraRect.maxX),
      y: cameraRect.maxY)
    sun.zPosition = 50
    sun.setScale(0)
    addChild(sun)
    
    let appear = SKAction.scale(to: 0.50 , duration: 1.0)
   // let move = SKAction.moveBy(x: 20, y: self.playableRect.height * 1/6 , duration: 3.0)
    let move = SKAction.moveTo(y: size.height/2, duration: 3.0)
/*    let fullScale = SKAction.sequence([
     SKAction.group([
        SKAction.speed(to: 1.0, duration:8.0),
        SKAction.moveBy(x: 0, y: self.playableRect.height * 1/6, duration: 3.0),
        ]),
      SKAction.group([
        SKAction.moveBy(x: 0, y: self.playableRect.height * -1/6, duration: 3.0),
        ]),
      SKAction.group([
        SKAction.moveBy(x: 0, y: self.playableRect.height * 1/6, duration: 1.0),
        ]),
      SKAction.group([
        SKAction.speed(to: 1.0, duration:1.0),
        SKAction.moveBy(x: 0, y: self.playableRect.height * -1/6, duration: 1.0),
      ]),
      ])
 */
    let group = SKAction.group([move])
    let groupWait = SKAction.repeat(group, count: 20)
    let disappear = SKAction.scale(to: 0, duration: 0.5)
    let removeFromParent = SKAction.removeFromParent()
    let actions = [ appear, move, groupWait, disappear, removeFromParent]
    sun.run(SKAction.sequence(actions))
    
  }
  
  func zombieHit(sunflower: SKSpriteNode) {                                          // sunflower
    sunflower.removeFromParent()
   
    let setHidden = SKAction.run() { [weak self] in
      self?.zombie.isHidden = false
      self?.invincible = false
    }
    let removeColor = SKAction.colorize(withColorBlendFactor: 0, duration: 1)
    zombie.run(SKAction.sequence([setHidden, removeColor]))
    
    lives += 1
    
  }
  

  

  func spawnEnemy() {
    let enemy = SKSpriteNode(imageNamed: "enemy")
//    let enemy1 = SKSpriteNode(imageNamed: "enemy")
    enemy.name = "enemy"
//    enemy1.name = "enemy1"
    enemy.position = CGPoint(
      x: cameraRect.maxX + enemy.size.width/2,
      y: CGFloat.random(
        min: cameraRect.minY + enemy.size.height/2,
        max: cameraRect.maxY - enemy.size.height/2))
 //   enemy1.position = CGPoint(
 //     x: cameraRect.minX + enemy.size.width/2,
 //     y: CGFloat.random(
 //       min: cameraRect.minY + enemy.size.height/2,
 //       max: cameraRect.maxY - enemy.size.height/2))
  /*  enemy1.position = CGPoint(
      x: -size.width + enemy.size.width/2,                                    // -size.width/2,
      y: CGFloat.random(min: playableRect.minY + enemy1.size.height/2,max: playableRect.maxY - enemy1.size.height/2))  */
    enemy.zPosition = 50
    
    addChild(enemy)
 //   addChild(enemy1)
 //   enemy1.zRotation = 160
    
    let actionMove =
      SKAction.moveBy(x: -(size.width + enemy.size.width), y: 0, duration: 2.0)
    let actionRemove = SKAction.removeFromParent()
    enemy.run(SKAction.sequence([actionMove, actionRemove]))
  
/*
  let actionMove1 =
    SKAction.moveBy(x: (size.width + enemy1.size.width), y: 0, duration: 2.0)
 //   enemy1.run(actionMove1)
  let actionRemove1 = SKAction.removeFromParent()
  enemy1.run(SKAction.sequence([actionMove1, actionRemove1])) */
 /*   enemy.position = CGPoint(
      x: size.width + enemy.size.width/2,
      y: CGFloat.random(min: playableRect.minY + enemy.size.height/2,max: playableRect.maxY - enemy.size.height/2))
    
    enemy10.position = CGPoint(
      x: -size.width + enemy.size.width/2,                                    // -size.width/2,
      y: CGFloat.random(min: playableRect.minY + enemy10.size.height/2,max: playableRect.maxY - enemy10.size.height/2))
    addChild(enemy)
    
    addChild(enemy10)
    enemy10.zRotation = 160
    
    let actionMove =
      SKAction.moveTo(x: -enemy.size.width/2, duration: 2.0)
    enemy.run(actionMove)
    let actionMove10 =
      SKAction.moveTo(x: size.width + enemy10.size.width/2, duration: 2.0)
    enemy10.run(actionMove10)
    
    let actionRemove = SKAction.removeFromParent()
    enemy.run(SKAction.sequence([actionMove, actionRemove]))
    */
  //  let actionRemove10 = SKAction.removeFromParent()
  //  enemy10.run(SKAction.sequence([actionMove, actionRemove]))
  }
    
  func spawnEnemy1(){
    let enemy1 = SKSpriteNode(imageNamed: "enemy")
     enemy1.name = "enemy1"
    enemy1.position = CGPoint(
      x: cameraRect.minX + enemy1.size.width/2,
      y: CGFloat.random(
        min: cameraRect.minY + enemy1.size.height/2,
        max: cameraRect.maxY - enemy1.size.height/2))
    
    addChild(enemy1)
    enemy1.zRotation = 160
    let actionMove1 =
      SKAction.moveBy(x: (size.width + enemy1.size.width), y: 0, duration: 2.0)
    //   enemy1.run(actionMove1)
    let actionRemove1 = SKAction.removeFromParent()
    enemy1.run(SKAction.sequence([actionMove1, actionRemove1]))

  }

    
    

  
  func startZombieAnimation() {
    if zombie.action(forKey: "animation") == nil {
      zombie.run(
        SKAction.repeatForever(zombieAnimation),
        withKey: "animation")
    }
  }

  func stopZombieAnimation() {
    zombie.removeAction(forKey: "animation")
  }

  func spawnCat() {
   
    let cat = SKSpriteNode(imageNamed: "cat")
    cat.name = "cat"
    cat.position = CGPoint(
      x: CGFloat.random(min: cameraRect.minX,
                        max: cameraRect.maxX),
      y: CGFloat.random(min: cameraRect.minY,
                        max: cameraRect.maxY))
    cat.zPosition = 50
    cat.setScale(0)
    addChild(cat)
    
    // 2
    let appear = SKAction.scale(to: 1.0, duration: 0.5)
    cat.zRotation = -π / 16.0
    let leftWiggle = SKAction.rotate(byAngle: π/8.0, duration: 0.5)
    let rightWiggle = leftWiggle.reversed()
    let fullWiggle = SKAction.sequence([leftWiggle, rightWiggle])
    let scaleUp = SKAction.scale(by: 1.2, duration: 0.25)
    let scaleDown = scaleUp.reversed()
    let fullScale = SKAction.sequence(
      [scaleUp, scaleDown, scaleUp, scaleDown])
    let group = SKAction.group([fullScale, fullWiggle])
    let groupWait = SKAction.repeat(group, count: 10)
    let disappear = SKAction.scale(to: 0, duration: 0.5)
    let removeFromParent = SKAction.removeFromParent()
    let actions = [appear, groupWait, disappear, removeFromParent]
    cat.run(SKAction.sequence(actions))
  }

  func zombieHit(cat: SKSpriteNode) {
    cat.name = "train"
    cat.removeAllActions()
    cat.setScale(1.0)
    cat.zRotation = 0

    let turnGreen = SKAction.colorize(with: SKColor.green, colorBlendFactor: 1.0, duration: 0.2)
    cat.run(turnGreen)
    if mute == false{
      run(catCollisionSound)
    }

   
  }

  func zombieHit(enemy: SKSpriteNode) {
    invincible = true
    let blinkTimes = 10.0
    let duration = 3.0
    let blinkAction = SKAction.customAction(withDuration: duration) { node, elapsedTime in
      let slice = duration / blinkTimes
      let remainder = Double(elapsedTime).truncatingRemainder(
        dividingBy: slice)
      node.isHidden = remainder > slice / 2
    }
    let setHidden = SKAction.run() { [weak self] in
      self?.zombie.isHidden = false
      self?.invincible = false
    }
    zombie.run(SKAction.sequence([blinkAction, setHidden]))

    if mute == false{
      run(enemyCollisionSound)
    }
    loseCats()
    lives -= 1
  }
  
  func zombieHit(enemy1: SKSpriteNode) {
    invincible = true
    let blinkTimes = 10.0
    let duration = 3.0
    let blinkAction = SKAction.customAction(withDuration: duration) { node, elapsedTime in
      let slice = duration / blinkTimes
      let remainder = Double(elapsedTime).truncatingRemainder(
        dividingBy: slice)
      node.isHidden = remainder > slice / 2
    }
    let setHidden = SKAction.run() { [weak self] in
      self?.zombie.isHidden = false
      self?.invincible = false
    }
    zombie.run(SKAction.sequence([blinkAction, setHidden]))
    
    run(enemyCollisionSound)
    
    loseCats()
    lives -= 1
  }

  func checkCollisions() {
    var hitCats: [SKSpriteNode] = []
    enumerateChildNodes(withName: "cat") { node, _ in
      let cat = node as! SKSpriteNode
      if cat.frame.intersects(self.zombie.frame) {
        hitCats.append(cat)
      }
    }
    for cat in hitCats {
      zombieHit(cat: cat)
    }

    if invincible {
      return
    }

    var hitEnemies: [SKSpriteNode] = []
    enumerateChildNodes(withName: "enemy") { node, _ in
      let enemy = node as! SKSpriteNode
      if node.frame.insetBy(dx: 20, dy: 20).intersects(
        self.zombie.frame) {
        hitEnemies.append(enemy)
      }
    }
    for enemy in hitEnemies {
      zombieHit(enemy: enemy)
    }
    var hitEnemies1: [SKSpriteNode] = []
    enumerateChildNodes(withName: "enemy1") { node, _ in
      let enemy1 = node as! SKSpriteNode
      if node.frame.insetBy(dx: 20, dy: 20).intersects(
        self.zombie.frame) {
        hitEnemies1.append(enemy1)
      }
    }
    for enemy1 in hitEnemies1 {
      zombieHit(enemy1: enemy1)
    }
    
    var hitSun: [SKSpriteNode] = []                                               // sunflower
    enumerateChildNodes(withName: "sunflower") { node, _ in
      let sunflower = node as! SKSpriteNode
      if node.frame.insetBy(dx: 10, dy: 10).intersects(
        self.zombie.frame) {
        hitSun.append(sunflower)
      }
    }
    for sunflower in hitSun {
      zombieHit(sunflower: sunflower)
    }
    var hitsmallfish: [SKSpriteNode] = []
    enumerateChildNodes(withName: "smallFish") { node, _ in
      let smallfish = node as! SKSpriteNode
      if node.frame.insetBy(dx: 20, dy: 20).intersects(
        self.zombie.frame) {
        
        hitsmallfish.append(smallfish)
      }
    }
    for smallfish in hitsmallfish {
      zombieHit(smallFish: smallfish)
    }
    var hitbigfish: [SKSpriteNode] = []
    enumerateChildNodes(withName: "bigFish") { node, _ in
      let bigfish = node as! SKSpriteNode
      if node.frame.insetBy(dx: 20, dy: 20).intersects(
        self.zombie.frame) {
        hitbigfish.append(bigfish)
      }
    }
    for bigfish in hitbigfish {
      zombieHit(bigFish: bigfish)
    }
    
    
    
}
  func zombieHit(smallFish: SKSpriteNode) {
    invincible = true
    smallFish.removeFromParent()
    let turnOrange = SKAction.colorize(with: SKColor.orange, colorBlendFactor: 0.75, duration: 0.2)
    
    
    let setHidden = SKAction.run() { [weak self] in
      self?.zombie.isHidden = false
      self?.invincible = false
    }
    
    let removeColor = SKAction.colorize(withColorBlendFactor: 0, duration: 4)
    zombie.run(SKAction.sequence([turnOrange, setHidden, removeColor]))
   
    }
/*

  func colorChange(){
    
    cat.name = "train"
    cat.removeAllActions()
    cat.setScale(1.0)
    cat.zRotation = 0
    
    let turnOrange = SKAction.colorize(with: SKColor.orange, colorBlendFactor: 1.0, duration: 0.2)
    cat.run(turnOrange)
    
    run(catCollisionSound)
    
  
}
*/
  func spawnBigFish() {
    // 1
    let bigfish = SKSpriteNode(imageNamed: "bigFish")
    bigfish.name = "bigFish"
    bigfish.position = CGPoint(
      x: CGFloat.random(min: cameraRect.minX,
                        max: cameraRect.maxX),
      y: CGFloat.random(min: cameraRect.minY,
                        max: cameraRect.maxY))
    bigfish.zPosition = 50
    bigfish.setScale(0)
    
    addChild(bigfish)
    // 2
    let appear = SKAction.sequence([ SKAction.scale(to: 0.50 , duration: 1.0), SKAction.wait(forDuration: 3.0)])
    let move = SKAction.moveBy(x: 0, y: self.playableRect.height * 1/6 , duration: 3.0)
    
    let disappear = SKAction.scale(to: 0, duration: 4.0)
    let removeFromParent = SKAction.removeFromParent()
    let actions = [move, appear, disappear, removeFromParent]
    bigfish.run(SKAction.sequence(actions))
    
  }

  func zombieHit(bigFish: SKSpriteNode) {
    bigFish.removeFromParent()
    let turnColor = SKAction.colorize(with: SKColor.blue, colorBlendFactor: 0.5, duration: 0.2)
    let setHidden = SKAction.run() { [weak self] in
      self?.zombie.isHidden = false
      self?.invincible = false
    }
    let removeColor = SKAction.colorize(withColorBlendFactor: 0, duration: 4)
    zombie.run(SKAction.sequence([turnColor, setHidden, removeColor]))
    addCats()
    
  }
  func addCats(){
    print("Big fish add cats")
    var hitCats: [SKSpriteNode] = []
    enumerateChildNodes(withName: "cat") { node, _ in
      let cat = node as! SKSpriteNode
      if Int(cat.position.x)-Int(self.zombie.position.x) <= 400 && Int(cat.position.y)-Int(self.zombie.position.y) <= 400{
        hitCats.append(cat)
      }
    }
    for cat in hitCats {
      zombieHit(cat: cat)
    }
  }
  
  

  func moveTrain() {

    var trainCount = 0
    var targetPosition = zombie.position

    enumerateChildNodes(withName: "train") { node, stop in
      trainCount += 1
      if !node.hasActions() {
        let actionDuration = 0.3
        let offset = targetPosition - node.position
        let direction = offset.normalized()
        let amountToMovePerSec = direction * self.catMovePointsPerSec
        let amountToMove = amountToMovePerSec * CGFloat(actionDuration)
        let moveAction = SKAction.moveBy(x: amountToMove.x, y: amountToMove.y, duration: actionDuration)
        node.run(moveAction)
      }
      targetPosition = node.position
    }

    if trainCount >= 5 && !gameOver {
      gameOver = true
      print("You win!")
      backgroundMusicPlayer.stop()

      // 1
      let gameOverScene = GameOverScene(size: size, won: true)
      gameOverScene.scaleMode = scaleMode
      // 2
      let reveal = SKTransition.flipHorizontal(withDuration: 0.5)
      // 3
      view?.presentScene(gameOverScene, transition: reveal)

    }
  }
  func spawnSmallFish() {
    // 1
    let smallfish = SKSpriteNode(imageNamed: "smallFish")
    smallfish.name = "smallFish"
    smallfish.position = CGPoint(
      x: CGFloat.random(min: cameraRect.minX,
                        max: cameraRect.maxX),
      y: CGFloat.random(min: cameraRect.minY,
                        max: cameraRect.maxY))
    smallfish.zPosition = 50
    smallfish.setScale(0)
    
    addChild(smallfish)
    // 2
    let appear = SKAction.sequence([ SKAction.scale(to: 0.50 , duration: 1.0), SKAction.wait(forDuration: 4.0)])
    let move = SKAction.moveBy(x: 0, y: self.playableRect.height * 1/6 , duration: 3.0)
    
    let disappear = SKAction.scale(to: 0, duration: 4.0)
    let removeFromParent = SKAction.removeFromParent()
    let actions = [move, appear, disappear, removeFromParent]
    smallfish.run(SKAction.sequence(actions))
    
  }
  

  func loseCats() {
    // 1
    var loseCount = 0
    enumerateChildNodes(withName: "train") { node, stop in
      // 2
      var randomSpot = node.position
      randomSpot.x += CGFloat.random(min: -100, max: 100)
      randomSpot.y += CGFloat.random(min: -100, max: 100)
      // 3
      node.name = ""
      node.run(
        SKAction.sequence([
          SKAction.group([
            SKAction.rotate(byAngle: π*4, duration: 1.0),
            SKAction.move(to: randomSpot, duration: 1.0),
            SKAction.scale(to: 0, duration: 1.0)
            ]),
          SKAction.removeFromParent()
        ]))
      // 4
      loseCount += 1
      if loseCount >= 2 {
        stop[0] = true
      }
    }
  }

  func backgroundNode() -> SKSpriteNode {
    // 1
    let backgroundNode = SKSpriteNode()
    backgroundNode.anchorPoint = CGPoint.zero
    backgroundNode.name = "background"

    // 2
    let background1 = SKSpriteNode(imageNamed: "background1")
    background1.anchorPoint = CGPoint.zero
    background1.position = CGPoint(x: 0, y: 0)
    backgroundNode.addChild(background1)

    // 3
    let background2 = SKSpriteNode(imageNamed: "background2")
    background2.anchorPoint = CGPoint.zero
    background2.position =
      CGPoint(x: background1.size.width, y: 0)
    backgroundNode.addChild(background2)

    // 4
    backgroundNode.size = CGSize(
      width: background1.size.width + background2.size.width,
      height: background1.size.height)
    return backgroundNode
  }

  func moveCamera() {
    let backgroundVelocity =
      CGPoint(x: cameraMovePointsPerSec, y: 0)
    let amountToMove = backgroundVelocity * CGFloat(dt)
    cameraNode.position += amountToMove

    enumerateChildNodes(withName: "background") { node, _ in
      let background = node as! SKSpriteNode
      if background.position.x + background.size.width <
          self.cameraRect.origin.x {
        background.position = CGPoint(
          x: background.position.x + background.size.width*2,
          y: background.position.y)
      }
    }

  }

  var cameraRect : CGRect {
    let x = cameraNode.position.x - size.width/2
        + (size.width - playableRect.width)/2
    let y = cameraNode.position.y - size.height/2
        + (size.height - playableRect.height)/2
    return CGRect(
      x: x,
      y: y,
      width: playableRect.width,
      height: playableRect.height)
  }

}
