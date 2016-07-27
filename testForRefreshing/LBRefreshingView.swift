//
//  LBRefreshingView.swift
//  testForRefreshing
//
//  Created by 吴龙波 on 16/7/26.
//  Copyright © 2016年 SleepWell. All rights reserved.
//

import UIKit

enum RefreshingViewState {
    case Normal //下拉刷新
    case Pulling //释放刷新
    case Refreshing //正在刷新
}
///动画默认持续时间
let animationDuration: NSTimeInterval = 0.25

///下拉刷新视图
class LBRefreshingView: UIView {
    
    ///刷新时调用的闭包
    var refreshingCallBack: (() -> Void)?
    
    ///当前状态默认为Normal
    private var currentState: RefreshingViewState = .Normal {
        didSet {
            switch currentState {
            case .Normal:
                messageLabel.text = "下拉刷新"
                
                UIView.animateWithDuration(animationDuration, animations: {
                    self.arrowView.transform = CGAffineTransformIdentity
                })
            case .Pulling:
                messageLabel.text = "释放刷新"
                
                UIView.animateWithDuration(animationDuration, animations: {
                    self.arrowView.transform = CGAffineTransformMakeRotation(CGFloat(M_PI))
                })
                
            case .Refreshing:
                
                arrowView.hidden = true
                loaddingView.hidden = false
                messageLabel.text = "正在刷新"
                
                ///添加加载动画
                let animation = CABasicAnimation(keyPath: "transform.rotation")
                animation.duration = 0.75
                animation.toValue = M_PI * 2
                animation.repeatCount = MAXFLOAT
                animation.removedOnCompletion = false
                ///添加到圆形视图
                loaddingView.layer.addAnimation(animation, forKey: nil)
                
                ///让加载视图停止一段时间
                UIView.animateWithDuration(animationDuration, animations: {
                    self.currentSuperView?.contentInset.top = self.currentSuperView!.contentInset.top + self.RefreshingViewHeight
                })
                
                refreshingCallBack?()
                
            }
        }
    }
    ///刷新视图的高度
    private let RefreshingViewHeight: CGFloat = 60
    ///父控件
    var currentSuperView: UIScrollView?
    
    // MARK: - 构造
    override init(frame: CGRect) {
        let newFrame = CGRectMake(0, -RefreshingViewHeight, UIScreen.mainScreen().bounds.width, RefreshingViewHeight)
        super.init(frame: newFrame)
        
        self.backgroundColor = UIColor.orangeColor()
        
        setUpUI()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    // MARK: - 加载视图
    private func setUpUI() {
        
        ///隐藏加载的视图
        loaddingView.hidden = true
        
        self.addSubview(arrowView)
        self.addSubview(loaddingView)
        self.addSubview(messageLabel)
        
        // 添加约束
        loaddingView.translatesAutoresizingMaskIntoConstraints = false
        arrowView.translatesAutoresizingMaskIntoConstraints = false
        messageLabel.translatesAutoresizingMaskIntoConstraints = false
        
        /// 这个框架写好是给别人用的,尽量少依赖其他东西
        /// 箭头
        // 箭头右边父控件中心 左偏移 25
        self.addConstraint(NSLayoutConstraint(item: arrowView, attribute: NSLayoutAttribute.Trailing, relatedBy: NSLayoutRelation.Equal, toItem: self, attribute: NSLayoutAttribute.CenterX, multiplier: 1, constant: -25))
        
        self.addConstraint(NSLayoutConstraint(item: arrowView, attribute: NSLayoutAttribute.CenterY, relatedBy: NSLayoutRelation.Equal, toItem: self, attribute: NSLayoutAttribute.CenterY, multiplier: 1, constant: 0))
        
        // 风火轮center和箭头重合
        self.addConstraint(NSLayoutConstraint(item: loaddingView, attribute: NSLayoutAttribute.CenterX, relatedBy: NSLayoutRelation.Equal, toItem: arrowView, attribute: NSLayoutAttribute.CenterX, multiplier: 1, constant: 0))
        self.addConstraint(NSLayoutConstraint(item: loaddingView, attribute: NSLayoutAttribute.CenterY, relatedBy: NSLayoutRelation.Equal, toItem: arrowView, attribute: NSLayoutAttribute.CenterY, multiplier: 1, constant: 0))
        
        // 文字
        self.addConstraint(NSLayoutConstraint(item: messageLabel, attribute: NSLayoutAttribute.Leading, relatedBy: NSLayoutRelation.Equal, toItem: arrowView, attribute: NSLayoutAttribute.Trailing, multiplier: 1, constant: 30))
        self.addConstraint(NSLayoutConstraint(item: messageLabel, attribute: NSLayoutAttribute.CenterY, relatedBy: NSLayoutRelation.Equal, toItem: self, attribute: NSLayoutAttribute.CenterY, multiplier: 1, constant: 0))
    }
    
    // MARK: - 公开方法
    ///开始刷新
    func startRefreshing() -> Void {
        currentState = .Refreshing
    }
    ///结束刷新
    func endRefreshing() -> Void {
        if currentState == .Refreshing {
            currentState = .Normal
            
            UIView.animateWithDuration(animationDuration, animations: {
                self.currentSuperView?.contentInset.top = self.currentSuperView!.contentInset.top - self.RefreshingViewHeight
                }, completion: { (_) in
                    
                    //结束刷新后改变视图
                    self.arrowView.hidden = false
                    self.loaddingView.hidden = true
                    self.loaddingView.layer.removeAllAnimations()
                    
                    
                    
            })
        }
    }
    ///便利构造
    convenience init(frame: CGRect,CallBack: () -> Void) {
        self.init(frame:frame)

        self.refreshingCallBack = CallBack
    }
    
    
    // MARK: - KVO
    /// 即将移动到父控件中, 调用addSubview后触发的
    override func willMoveToSuperview(newSuperview: UIView?) {
        ///如果父控件可以拖动
        if newSuperview is UIScrollView {
            currentSuperView = newSuperview as? UIScrollView
            
            ///使用KVO监听
            currentSuperView?.addObserver(self, forKeyPath: "contentOffset", options: NSKeyValueObservingOptions(rawValue: 0), context: nil)
        }
    }
    ///实现KVO方法
    override func observeValueForKeyPath(keyPath: String?, ofObject object: AnyObject?, change: [String : AnyObject]?, context: UnsafeMutablePointer<Void>) {
        
        if currentSuperView!.dragging {
            ///用户未释放的两种情况
            if currentState == .Normal && currentSuperView?.contentOffset.y <= -124 {
                currentState = .Pulling
            }
            if currentState == .Pulling && currentSuperView?.contentOffset.y > -124 {
                currentState = .Normal
            }
            
        } else {
            ///用户释放时，如果是拉的状态则切换为刷新
            if currentState == .Pulling {
                currentState = .Refreshing
            }
        }
        
    }
    ///移除监听
    deinit {
        currentSuperView?.removeObserver(self, forKeyPath: "contentOffset")
    }
    
    
    // MARK: - 懒加载
    private lazy var arrowView: UIImageView = UIImageView(image: UIImage(named: "tableview_pull_refresh"))
    
    private lazy var loaddingView: UIImageView = UIImageView(image: UIImage(named: "tableview_loading"))
    
    private lazy var messageLabel: UILabel = {
        let message = UILabel()
        
        ///设置内容
        message.text = "下拉刷新"
        message.font = UIFont.systemFontOfSize(15)
        message.textColor = UIColor.darkGrayColor()
        
        return message
    }()
}
