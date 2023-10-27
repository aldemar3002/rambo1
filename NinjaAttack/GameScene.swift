/// Copyright (c) 2018 Razeware LLC
/// 
/// Permission is hereby granted, free of charge, to any person obtaining a copy
/// of this software and associated documentation files (the "Software"), to deal
/// in the Software without restriction, including without limitation the rights
/// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
/// copies of the Software, and to permit persons to whom the Software is
/// furnished to do so, subject to the following conditions:
/// 
/// The above copyright notice and this permission notice shall be included in
/// all copies or substantial portions of the Software.
/// 
/// Notwithstanding the foregoing, you may not use, copy, modify, merge, publish,
/// distribute, sublicense, create a derivative work, and/or sell copies of the
/// Software in any work that is designed, intended, or marketed for pedagogical or
/// instructional purposes related to programming, coding, application development,
/// or information technology.  Permission for such use, copying, modification,
/// merger, publication, distribution, sublicensing, creation of derivative works,
/// or sale is expressly withheld.
/// 
/// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
/// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
/// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
/// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
/// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
/// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
/// THE SOFTWARE.

import SpriteKit

func +(left: CGPoint, right: CGPoint) -> CGPoint {
  return CGPoint(x: left.x + right.x, y: left.y + right.y)
}

func -(left: CGPoint, right: CGPoint) -> CGPoint {
  return CGPoint(x: left.x - right.x, y: left.y - right.y)
}

func *(point: CGPoint, scalar: CGFloat) -> CGPoint {
  return CGPoint(x: point.x * scalar, y: point.y * scalar)
}

func /(point: CGPoint, scalar: CGFloat) -> CGPoint {
  return CGPoint(x: point.x / scalar, y: point.y / scalar)
}

#if !(arch(x86_64) || arch(arm64))
  func sqrt(a: CGFloat) -> CGFloat {
    return CGFloat(sqrtf(Float(a)))
  }
#endif

extension CGPoint {
  func length() -> CGFloat {
    return sqrt(x*x + y*y)
  }
  
  func normalized() -> CGPoint {
    return self / length()
  }
}

struct PhysicsCategory {
  static let none      : UInt32 = 0
  static let all       : UInt32 = UInt32.max
  static let nave   : UInt32 = 0b1       // 1
  static let projectile: UInt32 = 0b10      // 2
  static let pato      : UInt32 = 0b11     // 3
}

class GameScene: SKScene {
  
  var naveDestroyed = 0
  var patoDestroyed = 0

  // 1
  let player = SKSpriteNode(imageNamed: "player")
  let player1 = SKSpriteNode(imageNamed: "player1")
  
  //let sign = randomSign()
  var background = SKSpriteNode(imageNamed: "backgroundninjas")
  //let y = random(min:background.size.height/2-size.height/2, max: size.height/2-background.size.height/2)
  //background.position = CGPoint(x: (size.width + background.size.width /2) * CGFloat(sign), y: y)
  //background.zPosition = 0
    
  override func didMove(to view: SKView) {
    //player.filteringMode = SKTextureFilteringMode.nearest
    //player1.filteringMode = SKTextureFilteringMode.nearest
    //var animDisparo = SKAction.animate(with: [player, player1], timePerFrame: 0.2)
    //var disparo = SKAction.repeatForever(animDisparo)
    
    // 2
    background.zPosition = -1000
    
    background.position = CGPoint(x: frame.size.width/2, y: frame.size.height/2)
    addChild(background)
    //backgroundColor = SKColor.white
    // 3
    player.position = CGPoint(x: size.width * 0.1, y: size.height * 0.2)
    // 4
    addChild(player)
    
    run(SKAction.repeatForever(
          SKAction.sequence([
            SKAction.run(addNave),
            SKAction.wait(forDuration: 1.0)
            ])
        ))
    
    run(SKAction.repeatForever(
          SKAction.sequence([
            SKAction.run(addPato),
            SKAction.wait(forDuration: 2.0)
            ])
        ))
    
    physicsWorld.gravity = .zero
    physicsWorld.contactDelegate = self
    
    let backgroundMusic = SKAudioNode(fileNamed: "background-music-aac.caf")
    backgroundMusic.autoplayLooped = true
    addChild(backgroundMusic)
    
    //var texturaCielo = SKTexture(imageNamed: "backgroundninjas.png")
    //texturaCielo.filteringMode = SKTextureFilteringMode.nearest
    
    //var movimientoCielo = SKAction.moveBy (x: -texturaCielo.size().width, y : 0,duration : TimeInterval(0.05 * texturaCielo.size().width))
    //let Duration: TimeInterval = 0.01
    //let yValueCielo: CGFloat = 0.0
    //var resetCielo = SKAction.moveBy(x: texturaCielo.size().width, y: yValueCielo, duration: Duration)
    //var resetCielo = SKAction.moveBy(x: texturaSuelo.size().width, y: yValueCielo, duration: Duration)
  }
  
  func random() -> CGFloat {
    return CGFloat.random(in: 0.0...1.0)
  }

  func random(min: CGFloat, max: CGFloat) -> CGFloat {
    return random() * (max - min) + min
  }

  func addNave() {
    
    // Create sprite
    let nave = SKSpriteNode(imageNamed: "nave")
    
    // Determine where to spawn the nave along the Y axis
    let actualY = random(min: nave.size.height/2, max: size.height - nave.size.height/2)
    
    // Position the nave slightly off-screen along the right edge,
    // and along a random position along the Y axis as calculated above
    nave.position = CGPoint(x: size.width + nave.size.width/2, y: actualY)
    
    nave.physicsBody = SKPhysicsBody(rectangleOf: nave.size) // 1
    nave.physicsBody?.isDynamic = true // 2
    nave.physicsBody?.categoryBitMask = PhysicsCategory.nave // 3
    nave.physicsBody?.contactTestBitMask = PhysicsCategory.projectile // 4
    nave.physicsBody?.collisionBitMask = PhysicsCategory.none // 5
    
    // Add the nave to the scene
    addChild(nave)

    
    // Determine speed of the nave
    let actualDuration = random(min: CGFloat(2.0), max: CGFloat(4.0))
    
    // Create the actions
    let actionMove = SKAction.move(to: CGPoint(x: -nave.size.width/2, y: actualY),
                                   duration: TimeInterval(actualDuration))
    let actionMoveDone = SKAction.removeFromParent()
    let loseAction = SKAction.run() { [weak self] in
      guard let `self` = self else { return }
      let reveal = SKTransition.flipHorizontal(withDuration: 0.5)
      let gameOverScene = GameOverScene(size: self.size, won: false)
      self.view?.presentScene(gameOverScene, transition: reveal)
    }
    nave.run(SKAction.sequence([actionMove, loseAction, actionMoveDone]))

  }
  
  func addPato() {
    
    // Create sprite
    let pato = SKSpriteNode(imageNamed: "pato")
    
    // Determine where to spawn the pato along the Y axis
    let actualY = random(min: pato.size.height/2, max: size.height - pato.size.height/2)
    
    // Position the pato slightly off-screen along the right edge,
    // and along a random position along the Y axis as calculated above
    pato.position = CGPoint(x: size.width + pato.size.width/2, y: actualY)
    
    pato.physicsBody = SKPhysicsBody(rectangleOf: pato.size) // 1
    pato.physicsBody?.isDynamic = true // 2
    pato.physicsBody?.categoryBitMask = PhysicsCategory.pato // 3
    pato.physicsBody?.contactTestBitMask = PhysicsCategory.projectile // 4
    pato.physicsBody?.collisionBitMask = PhysicsCategory.none // 5
    
    // Add the pato to the scene
    addChild(pato)

    
    // Determine speed of the pato
    let actualDuration = random(min: CGFloat(2.0), max: CGFloat(4.0))
    
    // Create the actions
    let actionMove = SKAction.move(to: CGPoint(x: -pato.size.width/2, y: actualY),
                                   duration: TimeInterval(actualDuration))
    let actionMoveDone = SKAction.removeFromParent()
    //let loseAction = SKAction.run() { [weak self] in
      //guard let `self` = self else { return }
      //let reveal = SKTransition.flipHorizontal(withDuration: 0.5)
      //let gameOverScene = GameOverScene(size: self.size, won: false)
      //self.view?.presentScene(gameOverScene, transition: reveal)
    //}
    pato.run(SKAction.sequence([actionMove, actionMoveDone]))


  }
  
  override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
    // 1 - Choose one of the touches to work with
    guard let touch = touches.first else {
      return
    }
    let touchLocation = touch.location(in: self)
    
    // 2 - Set up initial location of projectile
    let projectile = SKSpriteNode(imageNamed: "projectile")
    projectile.position = player.position
    
    projectile.physicsBody = SKPhysicsBody(circleOfRadius: projectile.size.width/2)
    projectile.physicsBody?.isDynamic = true
    projectile.physicsBody?.categoryBitMask = PhysicsCategory.projectile
    projectile.physicsBody?.contactTestBitMask = PhysicsCategory.pato
    projectile.physicsBody?.collisionBitMask = PhysicsCategory.none
    projectile.physicsBody?.usesPreciseCollisionDetection = true
    
    // 3 - Determine offset of location to projectile
    let offset = touchLocation - projectile.position
    
    // 4 - Bail out if you are shooting down or backwards
    if offset.x < 0 { return }
    
    // 5 - OK to add now - you've double checked position
    addChild(projectile)

    
    // 6 - Get the direction of where to shoot
    let direction = offset.normalized()
    
    // 7 - Make it shoot far enough to be guaranteed off screen
    let shootAmount = direction * 1000
    
    // 8 - Add the shoot amount to the current position
    let realDest = shootAmount + projectile.position
    
    // 9 - Create the actions
    let actionMove = SKAction.move(to: realDest, duration: 2.0)
    let actionMoveDone = SKAction.removeFromParent()
    projectile.run(SKAction.sequence([actionMove, actionMoveDone]))
    
    let backgroundMusic = SKAudioNode(fileNamed: "background-music-aac.caf")
    backgroundMusic.autoplayLooped = true
    addChild(backgroundMusic)

  }
  
  func projectileDidCollideWithNave(projectile: SKSpriteNode, nave: SKSpriteNode) {
    print("Hit")
    projectile.removeFromParent()
    nave.removeFromParent()
    
    naveDestroyed += 1
    if naveDestroyed > 9 {
      let reveal = SKTransition.flipHorizontal(withDuration: 0.5)
      let gameOverScene = GameOverScene(size: self.size, won: true)
      view?.presentScene(gameOverScene, transition: reveal)
    }

  }
  
  func projectileDidCollideWithPato(projectile: SKSpriteNode, pato: SKSpriteNode) {
    print("Hit-P")
    projectile.removeFromParent()
    pato.removeFromParent()
    
    patoDestroyed += 1
    if patoDestroyed == 1 {
      let reveal = SKTransition.flipHorizontal(withDuration: 0.5)
      let gameOverScene = GameOverScene(size: self.size, won: false)
      view?.presentScene(gameOverScene, transition: reveal)
    }

  }


}

extension GameScene: SKPhysicsContactDelegate {
  
  func didBegin(_ contact: SKPhysicsContact) {
    // 1
    var firstBody: SKPhysicsBody
    var secondBody: SKPhysicsBody
    var tercerBody: SKPhysicsBody
    if contact.bodyA.categoryBitMask < contact.bodyB.categoryBitMask {
      firstBody = contact.bodyA
      secondBody = contact.bodyB
    } else {
      firstBody = contact.bodyB
      secondBody = contact.bodyA
    }
    
    if contact.bodyA.categoryBitMask < contact.bodyB.categoryBitMask {
      tercerBody = contact.bodyA
      secondBody = contact.bodyB
    } else {
      tercerBody = contact.bodyB
      secondBody = contact.bodyA
    }
   
    // 2
    if ((firstBody.categoryBitMask & PhysicsCategory.nave != 0) &&
        (secondBody.categoryBitMask & PhysicsCategory.projectile != 0)) {
      if let nave = firstBody.node as? SKSpriteNode,
        let projectile = secondBody.node as? SKSpriteNode {
        projectileDidCollideWithNave(projectile: projectile, nave: nave)
      }
    }
    
    // 3
    if ((tercerBody.categoryBitMask & PhysicsCategory.pato != 0) &&
        (firstBody.categoryBitMask & PhysicsCategory.projectile != 0)) {
      if let pato = tercerBody.node as? SKSpriteNode,
        let projectile = secondBody.node as? SKSpriteNode {
        projectileDidCollideWithPato(projectile: projectile, pato: pato)
      }
    }
  }


}
