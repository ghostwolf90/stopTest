# stopTest紀錄手冊
這份手冊主要紀錄Swift撰寫 app -> Server PHP -> DB 技術過程及重點。
爬文的過程發現，swift處理資料庫這段，中文資料太少了，希望貢獻一己之力。

## 使用技術部份(未編輯)
* [以Post方式傳送資料給網站（Post to Server）](#post-to-server)
* [OC和swift差別 (OC & Swift)] (#oc-and-swift)

### 以Post方式傳送資料給網站（Post to Server）

1.首先須建立好一個Server，本專案是用php來開發
2.http request使用的類別為NSMutableURLRequest，他是繼承NSURLRequest類別

**程式段落：**  
```swift
  var post:NSString = "CITY_NO=\(USERNAME_S)&CITY_NAME=\(PASSWD_S)"
  NSLog("PostData: %@", post);
        
  var url: NSURL = NSURL(string: "http://localhost:8888/parking.php")!
  var postData:NSData = post.dataUsingEncoding(NSUTF8StringEncoding)!
  var postLength:NSString = String( postData.length )
  var request:NSMutableURLRequest = NSMutableURLRequest(URL:url)
        
  request.HTTPMethod = "POST"
  request.HTTPBody = postData
  request.setValue(postLength as String, forHTTPHeaderField: "Content-Length")
  request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
  request.setValue("application/json", forHTTPHeaderField: "Accept")
        
  var reponseError: NSError?
  var bodyBata = "data=something"
  var response: NSURLResponse? = nil
  var urlData: NSData? = NSURLConnection.sendSynchronousRequest(request, returningResponse:&response, error:&reponseError)
        
  if ( urlData != nil ) {
    let res = response as! NSHTTPURLResponse!
    NSLog("Response code: %ld", res.statusCode);
            
    if (res.statusCode >= 200 && res.statusCode < 300){
      var responseData:NSString  = NSString(data:urlData!, encoding:NSUTF8StringEncoding)!
      NSLog("Response ==> %@", responseData);
                
      var parkData = parkingData()
      parkingList = parkData.getParkList()
    }
    return "01"
  }else{
    println("Cannot connect!")
    return "02"
  }
```

### OC和swift差別 (OC & Swift)
NSArray和NSDictionary是Objective-C描述Array和Dictionary用
所以看到這兩個就可以直接想成swift的 Array<AnyObject>/Dictionary<String,AnyObject>

改一下 Array<AnyObject>/Dictionary<NSObject,AnyObject>
語法密糖 就可以寫成 [AnyObject]/[NSObject:AnyObject](語法密糖也可以叫語法糖衣，代表提供另一種好寫的寫法)
因此就能了解從[AnyObject]，他是描述這個Array可以放AnyObject 也就是任意型別
Array<AnyObject>是完整寫法，[AnyObject]是簡寫，但兩個都會做出一樣的東西


