# stopTest紀錄手冊
這份手冊主要紀錄Swift撰寫 app -> Server PHP -> DB 技術過程及重點。
爬文的過程發現，swift處理資料庫這段，中文資料太少了，希望貢獻一己之力。

## 使用技術部份(未編輯)
* [以Post方式傳送資料給網站（Post to Server）](#post-to-server)
* [OC和swift差別 (OC & Swift)] (#oc和swift差別-oc--swift)
* [閉包 (closure)] (#閉包-closure)

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

### 閉包 (closure)
閉包是自包含的函式程式碼區塊，可以在程式碼中被傳遞和使用。 Swift 中的閉包與 C 和 Objective-C 中的程式碼區塊（blocks）以及其他一些程式語言中的 lambdas 函式比較相似。

1.基本架構closure { (參數) -> 回傳值 in 程式實作 }

2.作為非同步方式，請外部傳一個closure，讓你的程式在完成的時候可以告知他

3.非同步觀念，如果你還要等他完成 那跟同步有什麼不同？
(有些library在一些function會有一個completion的傳入參數 如果是Facebook 比較愛用completionHandler)

以下兩個例子為，請外部傳一個closure，讓你的程式在完成的時候可以告知他

```swift
//請外部傳一個closure，讓你的程式在完成的時候可以告知他
//這個例子是沒有東西的
func getData(completion:()->Void){
    /*
       執行非同步
    */
    dispatch_async(...){
    	/* Block A */
    	//完成的時候，執行completion這個closure
    	completion()
    }
}
//假設你會產生一些東西(e.g.)server傳下來的東西
func getData(completion:(parkings:[AnyObject])->Void){
    /*
       執行非同步
    */
    dispatch_async(...){
    	/* Block A */
        let data = /* data from server */
    	//完成的時候，執行completion這個closure
    	completion(parkings: data)
    }
}

//例子1 在使用的時候就會變成
getData( { ()->Void in
  //do something after callback
})

//例子2 在使用的時候就會變成
getData( { (parkings:[AnyObject])->Void in
  //do something after callback
  for parking in parkings {
    //do something
  }
     
})
```


