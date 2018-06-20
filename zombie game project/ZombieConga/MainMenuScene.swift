

import Foundation
import SpriteKit

class MainMenuScene: SKScene {
 
  var playBtn = SKSpriteNode()
  var ladyBtn = SKSpriteNode()
  var flowerBtn = SKSpriteNode()
  var smallBtn = SKSpriteNode()
  var bigBtn = SKSpriteNode()
  var settingBtn = SKSpriteNode()
  
 
  override func didMove(to view: SKView) {
    
    let background = SKSpriteNode(imageNamed: "MainMenu")
    
    let playBtnTex = SKTexture(imageNamed: "play")
    let ladyBtnTex = SKTexture(imageNamed: "enemy")
    let flowerBtnTex = SKTexture(imageNamed: "sunflower")
    let smallBtnTex = SKTexture(imageNamed: "smallFish")
    let bigBtnTex = SKTexture(imageNamed: "bigFish")
    let settingBtnTex = SKTexture(imageNamed: "setting")
    
    
    background.position = CGPoint(x: size.width/2, y: size.height/2)
    addChild(background)
    
    
    ladyBtn = SKSpriteNode(texture: ladyBtnTex)
    ladyBtn.position = CGPoint(x: size.width/3, y: frame.midY)
    ladyBtn.setScale(1.0)
    addChild(ladyBtn)
    
    flowerBtn = SKSpriteNode(texture: flowerBtnTex)
    flowerBtn.position = CGPoint(x: size.width/4 - 100 , y: frame.midY)
    flowerBtn.setScale(0.50)
    addChild(flowerBtn)
    
    smallBtn = SKSpriteNode(texture: smallBtnTex)
    smallBtn.position = CGPoint(x: size.width/2, y: frame.midY)
    smallBtn.setScale(0.5)
    addChild(smallBtn)
    
    bigBtn = SKSpriteNode(texture: bigBtnTex)
    bigBtn.position = CGPoint(x: size.width - 400, y: frame.midY)
    bigBtn.setScale(0.30)
    addChild(bigBtn)
    
    settingBtn = SKSpriteNode(texture: settingBtnTex)
    settingBtn.position = CGPoint(x: size.width - 200, y:frame.maxY - 300)
    settingBtn.setScale(2.0)
    addChild(settingBtn)
    
    playBtn = SKSpriteNode(texture: playBtnTex)
    playBtn.position = CGPoint(x: frame.minX + 300 , y: frame.minY + 300)
    playBtn.setScale(1.0)
    addChild(playBtn)
    
  }
  
 /* func sceneTapped() {
    let myScene = GameScene(size: size)
    myScene.scaleMode = scaleMode
    let reveal = SKTransition.doorway(withDuration: 1.5)
    view?.presentScene(myScene, transition: reveal)
  }
*/
  override func touchesBegan(_ touches: Set<UITouch>,
                             with event: UIEvent?) {
    
      if let touch = touches.first{
        let pos = touch.location(in: self)
        let node = self.atPoint(pos)
        
        if node == playBtn {
          if let view = view {
            let scene = GameScene (size: size)
            let transition:SKTransition = SKTransition.fade(withDuration: 0.5)
            
            scene.scaleMode = SKSceneScaleMode.aspectFill
            view.presentScene(scene, transition: transition)
          }
        }
        if node == ladyBtn {
          if let view = view {
            let scene = GameScene (size: size)
            let transition:SKTransition = SKTransition.fade(withDuration: 0.5)
            scene.obj = 2
            scene.scaleMode = SKSceneScaleMode.aspectFill
            
            view.presentScene(scene, transition: transition)
          }
        }
        if node == flowerBtn {
          if let view = view {
            let scene = GameScene (size: size)
            let transition:SKTransition = SKTransition.fade(withDuration: 0.5)
            scene.obj = 1
            scene.scaleMode = SKSceneScaleMode.aspectFill
            view.presentScene(scene, transition: transition)
          }
        }
        if node == smallBtn {
          if let view = view {
            let scene = GameScene (size: size)
            let transition:SKTransition = SKTransition.fade(withDuration: 0.5)
            scene.obj = 3
            scene.scaleMode = SKSceneScaleMode.aspectFill
            view.presentScene(scene, transition: transition)
          }
        }
        if node == bigBtn {
          if let view = view {
            let scene = GameScene (size: size)
            let transition:SKTransition = SKTransition.fade(withDuration: 0.5)
            scene.obj = 4
            scene.scaleMode = SKSceneScaleMode.aspectFill
            view.presentScene(scene, transition: transition)
          }
        }
  }

}
}
