//
//  CameraViewController.swift
//  Swift-Demo
//
//  Created by Fang on 2020/12/19.
//

import UIKit
import AVKit
import CoreGraphics
import SnapKit

class CameraViewController: UIViewController {
    
    
    private let size = CGSize(width: 1080, height: 1920)
    let step = 1920 / 30 / 10
    
    var offset = 0
    //session
    let captureSession = AVCaptureSession()
    
    //输入
    var videoDevice: AVCaptureDevice?
    var videoInput: AVCaptureDeviceInput?
    
    let audioDevice = AVCaptureDevice.default(for: .audio)
    var audioInput: AVCaptureDeviceInput?
    
    var preSubImage : UIImage?
    //输出
    let queue = DispatchQueue.init(label: "videoOutputQueue")
    
    lazy var videoOutput = { () -> AVCaptureVideoDataOutput in
        let output = AVCaptureVideoDataOutput()
        
        output.setSampleBufferDelegate(self, queue: queue)
        output.videoSettings = [kCVPixelBufferPixelFormatTypeKey as String: kCVPixelFormatType_32BGRA]
        
        output.alwaysDiscardsLateVideoFrames = true
        return output
    }()
    
    lazy var audioOutput = { () -> AVCaptureAudioDataOutput in
        let output = AVCaptureAudioDataOutput()
        
        output.setSampleBufferDelegate(self, queue: queue)
        return output
    }()
    
    //预览
    var videoPreviewLayer: AVCaptureVideoPreviewLayer?
    let context = CIContext()
    //录制
    var writer : AVAssetWriter?
    var currentTime: CMTime?
    
    lazy var writerAudioInput = { () -> AVAssetWriterInput in
        var channelLayout = AudioChannelLayout.init()
        channelLayout.mChannelLayoutTag = kAudioChannelLayoutTag_MPEG_5_1_D
        let input = AVAssetWriterInput.init(mediaType: .audio, outputSettings: [AVFormatIDKey: kAudioFormatMPEG4AAC_HE, AVSampleRateKey: 44100, AVNumberOfChannelsKey: 6, AVChannelLayoutKey: NSData(bytes: &channelLayout, length: MemoryLayout.size(ofValue: channelLayout))])
        input.expectsMediaDataInRealTime = true
        return input
    }()
    
    lazy var writerVideoInput = { () -> AVAssetWriterInput in
        
        let input = AVAssetWriterInput.init(mediaType: .video, outputSettings: [AVVideoCodecKey: AVVideoCodecType.h264, AVVideoWidthKey: size.height, AVVideoHeightKey: size.width])
        input.transform = CGAffineTransform(rotationAngle: CGFloat(Double.pi / 2))
        
        return input
    }()
    
    var adaptor: AVAssetWriterInputPixelBufferAdaptor?
    
    //UI
    lazy var recordingButton = { () -> UIButton in
        let button = UIButton.init(type: .custom)
        button.setTitle("录制", for: .normal)
        button.setTitle("停止", for: .selected)
        button.addTarget(self, action: #selector(recordingButtonAction(sender:)), for: .touchUpInside)
        return button
    }()
    
    @objc func recordingButtonAction(sender: UIButton) {
        if sender.isSelected {
            stopRecord()
        } else {
            startRecord()
        }
    }
    
    lazy var playButton = { () -> UIButton in
        let button = UIButton.init(type: .custom)
        button.setTitle("播放", for: .normal)
        button.addTarget(self, action: #selector(playButtonAction(sender:)), for: .touchUpInside)
        return button
    }()
    
    @objc func playButtonAction(sender: UIButton) {
        
        if !FileManager.default.fileExists(atPath: outputFileURL().path) {
            print("文件不存在！")
            return
        }
        
        let data = FileManager.default.contents(atPath: outputFileURL().path)
        
        guard data != nil else {
            print("文件大小为0000000")
            return
        }
        let playerVC = AVPlayerViewController.init()
        playerVC.delegate = self
        let player = AVPlayer.init(url: outputFileURL())
        
        playerVC.player = player
        
        present(playerVC, animated: true) {
            player.play()
        }
        
    }
    
    lazy var imageView = { () -> UIImageView in
        let view = UIImageView()
        view.contentMode = .scaleAspectFit
        return view
    }()
    
    
    lazy var blueLine = { () -> UIImage in
        let rect = CGRect(x: 0, y: 0, width: size.width, height: 10)
        
        UIGraphicsBeginImageContext(rect.size)
        let context = UIGraphicsGetCurrentContext()
        context?.setFillColor(UIColor(hue:0.50, saturation:0.52, brightness:0.94, alpha:1.00).cgColor)
        context?.fill(rect)
         
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return image ?? UIImage()
    }()
    
    //标记
    var isRecording = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //MARK: UI
        
        createUI()
        
        //CaptureSession
        captureSession.beginConfiguration()
        captureSession.sessionPreset = AVCaptureSession.Preset.hd1920x1080
        addVideo()
        addAudio()
        
        captureSession.commitConfiguration()
        captureSession.startRunning()
        
        // Do any additional setup after loading the view.
    }
    

    
    func createUI() {
        
        view.backgroundColor = .gray
        
        view.addSubview(imageView)
        imageView.snp.makeConstraints { (make) in
            make.top.equalTo(self.view.safeAreaLayoutGuide.snp.top)
            make.left.right.equalTo(0)
            make.height.equalTo(imageView.snp.width).multipliedBy(size.height / size.width)
        }
        
        let stackView = UIStackView()
        stackView.distribution = .fillEqually
        stackView.alignment = .center
        stackView.axis = .horizontal
        stackView.addArrangedSubview(recordingButton)
        stackView.addArrangedSubview(playButton)
        view.addSubview(stackView)
        
        stackView.snp.makeConstraints { (make) in
            make.bottom.equalTo(additionalSafeAreaInsets.bottom).offset(-20)
            make.left.right.equalTo(0)
            make.height.equalTo(45)
        }
    }
    
    func addVideo() {
        videoDevice = device(withPreferringPosition: .front)
        assert(videoDevice != nil, "videoDevice can't nil")
        addVideoInput()
        addVideoOutput()
    }
    
//    AVCaptureDeviceDiscoverySession
    func device(withPreferringPosition position: AVCaptureDevice.Position) -> AVCaptureDevice? {
        let device = AVCaptureDevice.default(for: AVMediaType.video)
        return device

//        let devices = AVCaptureDevice.DiscoverySession.init(deviceTypes: [AVCaptureDevice.DeviceType.builtInWideAngleCamera], mediaType: AVMediaType.video, position: position).devices
//        return devices.first
    }
    
    func addVideoInput() {
        
        do {
            try videoInput = AVCaptureDeviceInput.init(device: videoDevice!)
        } catch {
            print("videoInput error: \(error)")
        }
        
        if captureSession.canAddInput(videoInput!) {
            captureSession.addInput(videoInput!)
        }
    }
    
    func addVideoOutput() {
        
        adaptor = AVAssetWriterInputPixelBufferAdaptor.init(assetWriterInput: writerVideoInput, sourcePixelBufferAttributes: [kCVPixelBufferPixelFormatTypeKey as String: kCVPixelFormatType_32ARGB])
        
        if captureSession.canAddOutput(videoOutput) {
            captureSession.addOutput(videoOutput)
        }
        if captureSession.canAddOutput(audioOutput) {
            captureSession.addOutput(audioOutput)
        }
    }
    
    func addAudio() {
        audioInput = try! AVCaptureDeviceInput.init(device: audioDevice!)
        if captureSession.canAddInput(audioInput!) {
            captureSession.addInput(audioInput!)
        }
    }
    
    func createWriter() -> AVAssetWriter? {
        
        self.writer = try? AVAssetWriter.init(outputURL: self.outputFileURL(), fileType: .mp4)
        guard let writer = self.writer else {
            print("writer can't nil")
            return nil
        }
        
        if writer.canAdd(writerAudioInput) {
            writer.add(writerAudioInput)
        }
        
        if writer.canAdd(writerVideoInput) {
            writer.add(writerVideoInput)
        }
        return writer
    }
    
    //MARK: 录制控制
    func startRecord() {
        writer = createWriter()
        
        guard let writer = writer else {
            print("writer can't nil")
            return
        }
        
        queue.sync { [weak self] in
            if writer.startWriting() {
                writer.startSession(atSourceTime: currentTime!)
                self?.isRecording = true
            }
            print("录制开始 - \(String(describing: writer.error))")
            offset = 0
        }
        self.recordingButton.isSelected = true
    }
    
    
    func stopRecord() {
        guard isRecording , let writer = writer else {
            return
        }
        
        queue.sync {
            self.isRecording = false
        }
        writer.finishWriting { [weak self] in
            guard let self = self else {
                return
            }
            UISaveVideoAtPathToSavedPhotosAlbum(self.outputFileURL().path, self, #selector(self.saveVideoFinish(withPath:error:context:)), nil);
            
            print("录制结束")
            DispatchQueue.main.async {
                self.recordingButton.isSelected = false
            }
        }
    }
    
    
    @objc func saveVideoFinish(withPath path: String, error: NSError, context: Any) {
        print("保存结果  -----  \(error)")
        do {
            try FileManager.default.removeItem(at: outputFileURL())
        } catch {
            print(error)
        }
    }
    
    //MARK: 处理数据流
    func appendSampleBuffer(sampleBuffer: CMSampleBuffer) {
        
        guard let formatDesc = CMSampleBufferGetFormatDescription(sampleBuffer) else {
            print("formatDesc 为空")
            return
        }
        
        let mediaType = CMFormatDescriptionGetMediaType(formatDesc)
        currentTime = CMSampleBufferGetPresentationTimeStamp(sampleBuffer)
        
        if mediaType == kCMMediaType_Video {
            
            //处理图像
            let imageBuffer = CMSampleBufferGetImageBuffer(sampleBuffer)
            // 转换为CIImage
            let ciImage = CIImage.init(cvImageBuffer: imageBuffer!)
            
            // 创建滤镜
//            let fiter = CIFilter.init(name: "CIBumpDistortion", parameters: ["inputImage": ciImage])
//            let resultCIImage = fiter?.outputImage
            
            //创建上下文
            UIGraphicsBeginImageContext(CGSize(width: size.height, height: size.width))
            let backImage = UIImage.init(ciImage: ciImage)
            
            
            backImage.draw(in: CGRect(x: 0, y: 0, width: size.height, height: size.width))
            
            if preSubImage != nil {
                //添加上一帧
                preSubImage!.draw(in: CGRect(x: 0, y: 0, width: CGFloat(offset), height: size.width))
            }
            
            //保存上一帧
            let preImage = UIGraphicsGetImageFromCurrentImageContext()
            let preCGImage = context.createCGImage(CIImage.init(cgImage: (preImage?.cgImage)!), from: CGRect(x: 0, y: 0, width: CGFloat(offset + step), height: size.width))
            preSubImage = UIImage.init(cgImage: preCGImage!)
            
            //添加蓝线
            blueLine.draw(in: CGRect(x: CGFloat(offset), y: 0, width: 10, height: size.height))
            let resultImage = UIGraphicsGetImageFromCurrentImageContext()
            UIGraphicsEndImageContext()
            
            offset += step
            
            //录制
            if isRecording && writerVideoInput.isReadyForMoreMediaData {
                var newPixelBuffer: CVPixelBuffer?
                CVPixelBufferPoolCreatePixelBuffer(nil, adaptor!.pixelBufferPool!, &newPixelBuffer)
                
                context.render(CIImage.init(image: resultImage!)!, to: newPixelBuffer!, bounds: ciImage.extent, colorSpace: CGColorSpaceCreateDeviceRGB())
                
                if !adaptor!.append(newPixelBuffer!, withPresentationTime: currentTime!) {
                    print("append field  \(String(describing: writer?.error))")
                }
                
            }
            //预览
            if resultImage != nil {
                let resultCi = CIImage.init(image: resultImage!)
                let image = UIImage.init(ciImage: resultCi!.oriented(.right))
                DispatchQueue.main.async {
                    self.imageView.image = image
                }
            }

        } else if mediaType == kCMMediaType_Audio {
            if self.writerAudioInput.isReadyForMoreMediaData && isRecording {
                
                if !self.writerAudioInput.append(sampleBuffer) {
                    print("======= audio write failed \(String(describing: self.writer?.error))")
                }
            }
        }
    }
    
    func outputFileURL() -> URL {
        return URL.init(fileURLWithPath: "\(NSTemporaryDirectory())output.mp4")
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}

extension CameraViewController: AVCaptureFileOutputRecordingDelegate {
    func fileOutput(_ output: AVCaptureFileOutput, didStartRecordingTo fileURL: URL, from connections: [AVCaptureConnection]) {
        print("录制开始 ==== url:\(fileURL)")
        
        for item in connections {
            print("\(item)")
            let output = item.output
        }
    }
    
    func fileOutput(_ output: AVCaptureFileOutput, didFinishRecordingTo outputFileURL: URL, from connections: [AVCaptureConnection], error: Error?) {
        print("录制结束 ==== \(String(describing: error?.localizedDescription))")
    }
}

extension CameraViewController: AVCaptureVideoDataOutputSampleBufferDelegate, AVCaptureAudioDataOutputSampleBufferDelegate {
    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        
        appendSampleBuffer(sampleBuffer: sampleBuffer)
    }
    
    func captureOutput(_ output: AVCaptureOutput, didDrop sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
//        print("didDrop  == \(NSDate.init())")
    }
}

extension CameraViewController: AVPlayerViewControllerDelegate {
    func playerViewControllerDidStopPictureInPicture(_ playerViewController: AVPlayerViewController) {
        
        playerViewController.dismiss(animated: true) {
            
        }
        
    }
    
    func playerViewController(_ playerViewController: AVPlayerViewController, failedToStartPictureInPictureWithError error: Error) {
        print("播放失败 \(String(describing: error))")
    }
    
    func playerViewControllerWillStartPictureInPicture(_ playerViewController: AVPlayerViewController) {
        print("playerViewControllerWillStartPictureInPicture")
    }
    
    func playerViewControllerDidStartPictureInPicture(_ playerViewController: AVPlayerViewController) {
        print("playerViewControllerDidStartPictureInPicture")
    }
}
