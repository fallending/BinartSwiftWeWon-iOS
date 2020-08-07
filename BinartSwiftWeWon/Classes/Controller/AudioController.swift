/*
 MIT License

 Copyright (c) 2017-2019 MessageKit

 Permission is hereby granted, free of charge, to any person obtaining a copy
 of this software and associated documentation files (the "Software"), to deal
 in the Software without restriction, including without limitation the rights
 to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 copies of the Software, and to permit persons to whom the Software is
 furnished to do so, subject to the following conditions:

 The above copyright notice and this permission notice shall be included in all
 copies or substantial portions of the Software.

 THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
 SOFTWARE.
 */

import UIKit
import AVFoundation
#if canImport(MessageKit)
import MessageKit
#endif

/// The `PlayerState` indicates the current audio controller state
public enum PlayerState {

    /// The audio controller is currently playing a sound
    case playing

    /// The audio controller is currently in pause state
    case pause

    /// The audio controller is not playing any sound and audioPlayer is nil
    case stopped
}

/// The `BAWAudioController` update UI for current audio cell that is playing a sound
/// and also creates and manage an `AVPlayer` states, play, pause and stop.
open class BAWAudioController: NSObject {

    /// The `AVPlayer` that is playing the sound
    open var audioItem: AVPlayerItem?
    open var audioPlayer: AVPlayer? // self.player.currentItem.asset.duration for assets
    
    open var loadTime: Float64 = 0
    open var totalTime: Float64 = 1
    
    /// The `AudioMessageCell` that is currently playing sound
    open weak var playingCell: AudioMessageCell?

    /// The `MessageType` that is currently playing sound
    open var playingMessage: MessageType?

    /// Specify if current audio controller state: playing, in pause or none
    open private(set) var state: PlayerState = .stopped

    // The `MessagesCollectionView` where the playing cell exist
    public weak var messageCollectionView: MessagesCollectionView?

    /// The `Timer` that update playing progress
//    internal var progressTimer: Timer?

    // MARK: - Init Methods

    public init(messageCollectionView: MessagesCollectionView) {
        self.messageCollectionView = messageCollectionView
        super.init()
    }

    // MARK: - Methods

    /// Used to configure the audio cell UI:
    ///     1. play button selected state;
    ///     2. progresssView progress;
    ///     3. durationLabel text;
    ///
    /// - Parameters:
    ///   - cell: The `AudioMessageCell` that needs to be configure.
    ///   - message: The `MessageType` that configures the cell.
    ///
    /// - Note:
    ///   This protocol method is called by MessageKit every time an audio cell needs to be configure
    open func configureAudioCell(_ cell: AudioMessageCell, message: MessageType) {
        // 这里需要为每个cell计算他的时长？？？msg应该不会携带时长的！！！
        if playingMessage?.messageId == message.messageId {
            playingCell = cell
//            cell.progressView.progress = (player.duration == 0) ? 0 : Float(player.currentTime/player.duration)
//            cell.playButton.isSelected = (player.isPlaying == true) ? true : false
//            guard let displayDelegate = collectionView.messagesDisplayDelegate else {
//                fatalError("MessagesDisplayDelegate has not been set.")
//            }
//            cell.durationLabel.text = displayDelegate.audioProgressTextFormat(Float(player.currentTime), for: cell, in: collectionView)
        }
    }

    /// Used to start play audio sound
    ///
    /// - Parameters:
    ///   - message: The `MessageType` that contain the audio item to be played.
    ///   - audioCell: The `AudioMessageCell` that needs to be updated while audio is playing.
    open func playSound(for message: MessageType, in audioCell: AudioMessageCell) {
        switch message.kind {
        case .audio(let item):
            playingCell = audioCell
            playingMessage = message
            
            print("play \(item.url)")
            
            audioItem = AVPlayerItem(url: item.url)
            audioItem?.addObserver(self, forKeyPath: "status", options: .new, context: nil)
            
            audioPlayer = AVPlayer(playerItem: audioItem)
            audioPlayer?.rate = 1
            
            NotificationCenter
                .default
                .addObserver(self, selector: #selector(audioDidEnd), name:
                    .AVPlayerItemDidPlayToEndTime, object: nil)

            state = .playing
            audioCell.playButton.isSelected = true  // show pause button on audio cell
//            startProgressTimer()
            audioCell.delegate?.didStartAudio(in: audioCell)
        default:
            print("BasicAudioPlayer failed play sound becasue given message kind is not Audio")
        }
    }

    /// Used to pause the audio sound
    ///
    /// - Parameters:
    ///   - message: The `MessageType` that contain the audio item to be pause.
    ///   - audioCell: The `AudioMessageCell` that needs to be updated by the pause action.
    open func pauseSound(for message: MessageType, in audioCell: AudioMessageCell) {
        audioPlayer?.pause()
        state = .pause
        audioCell.playButton.isSelected = false // show play button on audio cell
//        progressTimer?.invalidate()
        if let cell = playingCell {
            cell.delegate?.didPauseAudio(in: cell)
        }
    }

    /// Stops any ongoing audio playing if exists
    open func stopAnyOngoingPlaying() {
        guard let player = audioPlayer, let collectionView = messageCollectionView else { return } // If the audio player is nil then we don't need to go through the stopping logic
        player.seek(to: CMTime.zero)
        player.pause()
        state = .stopped
        if let cell = playingCell {
            cell.progressView.progress = 0.0
            cell.playButton.isSelected = false
            guard let displayDelegate = collectionView.messagesDisplayDelegate else {
                fatalError("MessagesDisplayDelegate has not been set.")
            }
            cell.durationLabel.text = displayDelegate.audioProgressTextFormat(Float(totalTime), for: cell, in: collectionView)
            cell.delegate?.didStopAudio(in: cell)
        }
        
        NotificationCenter.default.removeObserver(self)
        
//        progressTimer?.invalidate()
//        progressTimer = nil
        audioPlayer = nil
        playingMessage = nil
        playingCell = nil
    }

    /// Resume a currently pause audio sound
    open func resumeSound() {
        guard let player = audioPlayer, let cell = playingCell else {
            stopAnyOngoingPlaying()
            return
        }
//        player.prepareToPlay()
        player.play()
        state = .playing
//        startProgressTimer()
        cell.playButton.isSelected = true // show pause button on audio cell
        cell.delegate?.didStartAudio(in: cell)
    }

    // MARK: - AVPlayerDelegate
    
    @objc open func audioDidEnd () {
//        stopAnyOngoingPlaying()
    }
    
    open func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        stopAnyOngoingPlaying()
    }

    open func audioPlayerDecodeErrorDidOccur(_ player: AVAudioPlayer, error: Error?) {
        stopAnyOngoingPlaying()
    }

    // MARK: -
    
    open override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if keyPath == "status" {
            switch audioItem?.status {
            case .readyToPlay:
                //准备播放
//                    self.play()
                totalTime = CMTimeGetSeconds((audioItem?.asset.duration)!)
            
//                playingCell?.progressView.progress = 0
//                playingCell?.playButton.isSelected = false
//                guard let displayDelegate = messageCollectionView?.messagesDisplayDelegate else {
//                    fatalError("MessagesDisplayDelegate has not been set.")
//                }
//            playingCell?.durationLabel.text = displayDelegate.audioProgressTextFormat(Float(totalTime), for: playingCell!, in: messageCollectionView!)
//
//                resumeSound()
                
                
                // 播放过程监测
                audioPlayer?.addPeriodicTimeObserver(forInterval: CMTimeMake(value: 1, timescale: 1), queue: .main) { [weak self](time) in
                    
                    print("playing")
                    
    //                if self?.audioPlayer!.currentItem?.status == .readyToPlay {
    //                    self?.totalTime = CMTimeGetSeconds((self?.audioPlayer?.currentItem?.duration)!)
    //                }
                    
                    //当前正在播放的时间
                    self?.loadTime = CMTimeGetSeconds(time)
                    //视频总时间
//                    if (self?.audioPlayer?.currentItem!.duration.isNaN)! {
                    self?.totalTime = CMTimeGetSeconds((self?.audioPlayer?.currentItem?.duration)!)
//                    }
                    
                    //播放进度设置
                    guard let collectionView = self?.messageCollectionView, let cell = self?.playingCell else {
                        return
                    }
                    // check if can update playing cell
                    if let playingCellIndexPath = collectionView.indexPath(for: cell) {
                        // 1. get the current message that decorates the playing cell
                        // 2. check if current message is the same with playing message, if so then update the cell content
                        // Note: Those messages differ in the case of cell reuse
                        let currentMessage = collectionView.messagesDataSource?.messageForItem(at: playingCellIndexPath, in: collectionView)
                        if currentMessage != nil && currentMessage?.messageId == self?.playingMessage?.messageId {
                            // messages are the same update cell content
                            cell.progressView.progress = (self?.totalTime == 0) ? 0 : Float(self?.loadTime ?? 0/(self?.totalTime ?? 1))
                            guard let displayDelegate = collectionView.messagesDisplayDelegate else {
                                fatalError("MessagesDisplayDelegate has not been set.")
                            }
                            cell.durationLabel.text = displayDelegate.audioProgressTextFormat(Float(self?.loadTime ?? 0), for: cell, in: collectionView)
                        } else {
                            // if the current message is not the same with playing message stop playing sound
                            self?.stopAnyOngoingPlaying()
                        }
                    }
                }
                
                audioPlayer?.play()
                
                break
            case .failed:
                break
            case .unknown:
                break
            default:
                break;
            }
            
//            audioItem?.removeObserver(self, forKeyPath: "status")
        }
        
    }
}
