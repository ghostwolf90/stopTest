# stopTest紀錄手冊
這份手冊主要紀錄Swift撰寫 app -> Server PHP -> DB 技術過程及重點。
爬文的過程發現，swift處理資料庫這段，中文資料太少了，希望貢獻一己之力。

## 使用技術部份(未編輯)
* [不使用segue畫面切換（Dot-use segue）](#dot-use-segue)

### 不使用segue畫面切換（Dot-use segue）

透過語法去載入指定的View Controller。

**譬如應該如下這樣寫：**  
```swift
  var vc = self.storyboard?.instantiateViewControllerWithIdentifier("showWeb") as! showWebViewController
  var nc = self.storyboard?.instantiateViewControllerWithIdentifier("nc") as! UINavigationController
  nc.pushViewController(vc, animated: false)
  vc.htmlUrl = tempQrcode
  self.showDetailViewController(nc, sender: self)
```
