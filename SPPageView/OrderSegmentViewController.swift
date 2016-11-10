import UIKit

protocol SPPageViewDelegate {
  
  func numberOfPages(view:OrderSegmentViewController)
  func pageViewOfPages(view:OrderSegmentViewController, pageIndex:Int)
  func whrenSelectedPage(index:Int)
}

let TagIndex = 1000
let ScreenHeight = UIScreen.mainScreen().bounds.size.height
let tabFrameHeight = 64

class OrderSegmentViewController: UIViewController, UIScrollViewDelegate {
  
  var tabFrameHeight: CGFloat!
  var tabBackGroudColor: UIColor!
  var tabBtnFontSize: CGFloat!
  var tabMargin: CGFloat!
  var titleColorForNormal: UIColor!
  var titleColorForSelected: UIColor!
  var selectedLineWidth: CGFloat!
  var pageVCs: [UIViewController]!
  
  private var bodyScrollview:UIScrollView! = {
    let scrollView = UIScrollView()
    scrollView.scrollEnabled = true
    scrollView.pagingEnabled = true
    scrollView.userInteractionEnabled = true
    scrollView.bounces = false
    scrollView.showsHorizontalScrollIndicator = false
    scrollView.showsVerticalScrollIndicator = false
    scrollView.autoresizingMask = .FlexibleHeight
    return scrollView
  }()
  
  private var viewsArr: [AnyObject]!
  private var continueDraggingNum: Int!
  private var startOffSetX: CGFloat!
  private var curTabIndex: Int!
  private var isBuildUI: Bool!
  private var isUserDragging: Bool!
  private var isEndDecelerating: Bool!
  
  private var tabView: UIView!
  private var tabBtns: [UIButton]!
  private var selectedLine: UIView!
  private var lineWidth: CGFloat!
  private var selectedLineOffsetBeforDragging: Bool!
  private var itemBtnWidth: CGFloat!
  
  override func viewDidLoad() {
    super.viewDidLoad()
    self.title = "我的订单"
  }
  
  func goVCAtIndex(index: Int) {
    setBtnStateAtIndex(index)
    bodyScrollview.setContentOffset(CGPoint(x: view.frame.width*CGFloat(index), y: 0), animated: false)
    lineAnimation(1)
    curTabIndex = index
  }
  
  func buildUIWithTab(pageVCs:[UIViewController],tabTitles:[String],curIndex:Int) {
    initVar()
    curTabIndex = curIndex
    startOffSetX = CGFloat(curIndex)*self.view.frame.width
    let stateHight:CGFloat = 64
    self.viewsArr = pageVCs
    itemBtnWidth  = (view.frame.width - tabMargin*2)/CGFloat(pageVCs.count)
    lineWidth = itemBtnWidth/2
    tabView = UIView()
    tabView.backgroundColor = UIColor.whiteColor()
    tabView.frame = CGRect(x: 0, y: stateHight, width: view.frame.width, height: tabFrameHeight)
    view.addSubview(tabView)
    
    selectedLine = UIView()
    selectedLine.backgroundColor = titleColorForSelected
    selectedLine.frame = CGRect(x: 0, y: 0, width: lineWidth, height: 2)
    selectedLine.center = CGPoint(x: tabMargin + itemBtnWidth / 2, y: CGRectGetMaxY(tabView.frame))
    view.addSubview(selectedLine)
    view.addSubview(bodyScrollview)
    bodyScrollview.frame = CGRect(x: 0, y: tabFrameHeight + stateHight, width: view.frame.width, height: view.frame.height - tabFrameHeight - stateHight)
    bodyScrollview.delegate  = self
    
    let number = pageVCs.count
    for i in 0..<number {
      let vc:UIViewController = pageVCs[i]
      self.addChildViewController(vc)
      bodyScrollview.addSubview(vc.view)
      vc.didMoveToParentViewController(self)
      vc.view.frame = CGRect(x: view.frame.width*CGFloat(i), y: 0, width: self.bodyScrollview.frame.width, height: bodyScrollview.frame.height)
      
      let btns:UIButton = {
        let btn = UIButton(frame: CGRect(x: tabMargin + itemBtnWidth * CGFloat(i), y: 0, width: itemBtnWidth, height: tabFrameHeight))
        btn.setTitle(tabTitles[i], forState: .Normal)
        btn.setTitleColor(titleColorForNormal, forState: .Normal)
        btn.setTitleColor(titleColorForSelected, forState: .Selected)
        btn.titleLabel?.font = UIFont.systemFontOfSize(tabBtnFontSize)
        if  i == curTabIndex {
          btn.selected = true
        }
        btn.tag = TagIndex + i
        btn.addTarget(self, action: #selector(btnSelectedAction), forControlEvents: .TouchUpInside)
        return btn
      }()
      tabBtns.append(btns)
      tabView.addSubview(btns)
      if curTabIndex == i {
        setBtnStateAtIndex(i)
      }
    }
    bodyScrollview.contentSize = CGSize(width: view.frame.width * CGFloat(tabBtns.count), height: ScreenHeight - tabFrameHeight - stateHight)
    bodyScrollview.contentOffset = CGPoint(x: startOffSetX, y: 0)
  }
  
  func initVar() {
    isBuildUI = false
    isUserDragging = false
    isEndDecelerating = true
    continueDraggingNum = 0
    tabFrameHeight = 44
    tabMargin = 10
    tabBtnFontSize = 14
    titleColorForNormal = UIColor.lightGrayColor()
    titleColorForSelected = UIColor.redColor()
    tabBtns = [UIButton]()
  }
  
  func lineAnimation(time:NSTimeInterval) {
    let offSet = bodyScrollview.contentOffset.x
    let rate = (view.frame.width - 2 * tabMargin) / (CGFloat(tabBtns.count) * view.frame.width)
    UIView.animateWithDuration(time, delay: 0, usingSpringWithDamping: 0.8, initialSpringVelocity: 0.0, options: .CurveEaseOut, animations: {
        self.selectedLine.center.x = offSet * rate + self.tabMargin + self.lineWidth
      }, completion: nil)
  }
  
  func setBtnStateAtIndex(index:Int) {
    let btn:UIButton = tabBtns[index]
    let lastBtn:UIButton = view.viewWithTag(TagIndex+curTabIndex) as! UIButton
    lastBtn.selected = false
    btn.selected = true
    
  }
  
  func btnSelectedAction(sender:AnyObject) {
    let index = sender.tag - TagIndex
    setBtnStateAtIndex(index)
    bodyScrollview.setContentOffset(CGPoint(x: view.frame.width * CGFloat(index), y: 0), animated: false)
    lineAnimation(1)
    curTabIndex = index
  }
  
  func scrollViewDidEndDecelerating(scrollView: UIScrollView) {
  }
  
  func scrollViewWillBeginDragging(scrollView: UIScrollView) {
    if scrollView == bodyScrollview {
      let offSet = bodyScrollview.contentOffset.x
      curTabIndex = Int(offSet/view.frame.width)
    }
  }
  
  func scrollViewDidScroll(scrollView: UIScrollView) {
    let index = Int(bodyScrollview.contentOffset.x/view.frame.width)
    setBtnStateAtIndex(index)
    lineAnimation(1)
    curTabIndex = index
  }
  
  func scrollViewWillBeginDecelerating(scrollView: UIScrollView) {
//    print("begain decelerating",bodyScrollview.contentOffset.x)
    
  }
  
  func scrollViewDidEndScrollingAnimation(scrollView: UIScrollView) {
//    print("end scrolling")
  }
  
}
