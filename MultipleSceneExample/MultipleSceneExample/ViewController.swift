//
//  ViewController.swift
//  MultipleSceneExample
//
//  Created by Rohan on 30/11/20.
//

import UIKit
import AVFoundation
import OpenGLES
import GameMain

class ViewController: UIViewController {

  @IBOutlet weak var containerView1: UIView!
  
  let korgeVC1 = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(identifier: "korgeVC") as! KorgeViewController
  
  let url = Bundle.main.url(forResource: "football-small", withExtension: "mp4")!
  lazy var asset = AVAsset(url: url)
  lazy var assetReader: AVAssetReader = try! AVAssetReader(asset: asset)
  let outputSettings: [String: Any] = [
    kCVPixelBufferPixelFormatTypeKey as String: kCVPixelFormatType_32BGRA,
    kCVPixelBufferOpenGLESCompatibilityKey as String: true
  ]
  lazy var trackOutput: AVAssetReaderTrackOutput = {
    let track = asset.tracks(withMediaType: .video).first!
    let trackOutput = AVAssetReaderTrackOutput(track: track, outputSettings: outputSettings)
    return trackOutput
  }()
  var textureCache: CVOpenGLESTextureCache?
  
  let videoRecorder = VideoRecorder(size: CGSize(width: 512, height: 512))
  
  let context = GLContext.shared
  
  var frameBuffer = GLuint()
  var colorRenderBuffer = GLuint()
  
  var nativeImages = [GLuint: RSNativeImage]()
  var reshape = true
  var isInitialized = false
  var gameWindow2: MyIosGameWindow2?
  var rootGameMain: RootGameMain?
  
  var timer: Timer?
  var time: Double = 0.0
  
  override func viewDidLoad() {
    super.viewDidLoad()
      
    assetReader.add(trackOutput)
    assetReader.startReading()
    
    self.isInitialized = false
    self.reshape = true
    self.gameWindow2 = MyIosGameWindow2()
    self.rootGameMain = RootGameMain()
    
    containerView1.addSubview(korgeVC1.view)
    korgeVC1.view.translatesAutoresizingMaskIntoConstraints = false
    korgeVC1.view.topAnchor.constraint(equalTo: containerView1.topAnchor).isActive = true
    korgeVC1.view.bottomAnchor.constraint(equalTo: containerView1.bottomAnchor).isActive = true
    korgeVC1.view.leadingAnchor.constraint(equalTo: containerView1.leadingAnchor).isActive = true
    korgeVC1.view.trailingAnchor.constraint(equalTo: containerView1.trailingAnchor).isActive = true
    addChild(korgeVC1)
    korgeVC1.didMove(toParent: self)
    
    let err = CVOpenGLESTextureCacheCreate(kCFAllocatorDefault, nil, context, nil, &textureCache)
    if err != noErr {
      fatalError("Error - \(err)")
    }
    
  }

  func bindOffscreenBuffers() {
    glBindFramebuffer(GLenum(GL_FRAMEBUFFER), frameBuffer)
  }
  
  func unBindOffscreenBuffers() {
    glBindFramebuffer(GLenum(GL_FRAMEBUFFER), 0)
  }
  
  func genOffscreenBuffers() {
    EAGLContext.setCurrent(context)
    glGenFramebuffers(1, &frameBuffer)
    glBindFramebuffer(GLenum(GL_FRAMEBUFFER), frameBuffer)

    glGenRenderbuffers(1, &colorRenderBuffer);
    glBindRenderbuffer(GLenum(GL_RENDERBUFFER), colorRenderBuffer);
    glRenderbufferStorage(GLenum(GL_RENDERBUFFER), GLenum(GL_RGBA8), GLsizei(containerView1.bounds.size.width*UIScreen.main.scale), GLsizei(containerView1.bounds.size.height*UIScreen.main.scale));
    glFramebufferRenderbuffer(GLenum(GL_FRAMEBUFFER), GLenum(GL_COLOR_ATTACHMENT0), GLenum(GL_RENDERBUFFER), colorRenderBuffer);

    let status = glCheckFramebufferStatus(GLenum(GL_FRAMEBUFFER))

    if status != GLenum(GL_FRAMEBUFFER_COMPLETE) {
      fatalError("failed to make complete frame buffer object \(status)")
    }
  }
  
  
  @IBAction func exportTapped(_ sender: UIButton) {
    genOffscreenBuffers()
    print("Exporting ....")
    videoRecorder?.startRecording()
    timer?.invalidate()
    MainKt.mayank = getVideoFrame
    timer = Timer.scheduledTimer(timeInterval: 0.033333333,
                                 target: self,
                                 selector: #selector(timerInvocation),
                                 userInfo: nil,
                                 repeats: true)
  }
  
  @objc func timerInvocation() {
    if time < 5 {
      MainKt.switchToCircle(boolean: false)
      bindOffscreenBuffers()
      renderFrame()
      videoRecorder?.writeFrame(time: time)
      unBindOffscreenBuffers()
      MainKt.switchToCircle(boolean: true)
      time += 0.034
    }else {
      timer?.invalidate()
      videoRecorder?.endRecording {
        print("Check video file")
      }
    }
  }
  
  func renderFrame() {
    if !self.isInitialized {
      self.isInitialized = true
      self.gameWindow2?.gameWindow.dispatchInitEvent()
      self.rootGameMain?.runMain()
      self.reshape = true;
    }
    
//    let width = self.view.bounds.size.width * self.view.contentScaleFactor
//    let height = self.view.bounds.size.height * self.view.contentScaleFactor
//    if self.reshape {
//      self.reshape = false
//      self.gameWindow2?.gameWindow.dispatchReshapeEvent(x: 0, y: 0, width: Int32(width), height: Int32(height))
//    }
    
    self.gameWindow2?.gameWindow.frame()
  }
  
  func getVideoFrame() -> RSNativeImage? {
    guard let sampleBuffer = trackOutput.copyNextSampleBuffer() else {
      print("Could not get sample buffer")
      return nil
    }
    
    guard let imageBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else {
      print("Could not get image buffer")
      return nil
    }
    
    let pixelBuffer = imageBuffer as CVPixelBuffer
    
    guard let texture = getRGBATexture(for: pixelBuffer) else {
      print("returned from here")
      return nil
    }
    
    let target = CVOpenGLESTextureGetTarget(texture)
    let id = CVOpenGLESTextureGetName(texture)
    let width = CVPixelBufferGetWidth(pixelBuffer)
    let height = CVPixelBufferGetHeight(pixelBuffer)
    
    if let nativeImage = nativeImages[id] {
      return nativeImage
    }else {
      let nativeImage = RSNativeImage(width: Int32(width),
                                      height: Int32(height),
                                      name2: id,
                                      target2: KotlinInt(int: Int32(target)))
      nativeImages[id] = nativeImage
      return nativeImage
    }
  }
  
  func getRGBATexture(for pixelBuffer: CVPixelBuffer) -> CVOpenGLESTexture? {
    var texture: CVOpenGLESTexture?
    
    guard let textureCache = textureCache else { return nil }
    
    CVOpenGLESTextureCacheFlush(textureCache, 0)
    
    let err = CVOpenGLESTextureCacheCreateTextureFromImage(kCFAllocatorDefault,
                                                           textureCache,
                                                           pixelBuffer,
                                                           nil,
                                                           GLenum(GL_TEXTURE_2D),
                                                           GLint(GL_RGBA),
                                                           Int32(CVPixelBufferGetWidth(pixelBuffer)),
                                                           Int32(CVPixelBufferGetHeight(pixelBuffer)),
                                                           GLenum(GL_BGRA),
                                                           GLenum(GL_UNSIGNED_BYTE),
                                                           0,
                                                           &texture)
    
    if texture == nil || err != noErr {
      print("Error at creating RGBA texture - \(err.description)")
    }
    
    return texture
  }
}

