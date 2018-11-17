# Unused
`unused.rb` Searches for unused swift functions, and variable at specified path

## Usage
```
cd <path-to-the-project>
<path-to-unused.sh>/unused.rb 
```

## Output
```
 Item< func loadWebViewTos [private] from:File.swift:23:0>
Total items to be checked 4276
Total unique items to be checked 1697
Starting searching globally it can take a while
 Item< func applicationHasUnitTestTargetInjected [] from:AnotherFile.swift:31:0>
 Item< func getSelectedIds [] from: AnotherFile.swift:82:0>
```

## Xcode integration
In order to integrate this to Xcode just add *Custom Build Phase/Run Script*  
`~/Projects/swift-scripts/unused.rb xcode`  
![](https://user-images.githubusercontent.com/119268/32348473-88080ed2-c01c-11e7-9de6-762aeb195156.png)
![](https://user-images.githubusercontent.com/119268/32348476-8af3a700-c01c-11e7-893f-013851568882.png)

## Known issues:
- Fully text search (no fancy stuff)
- A lot of false-positives (protocols, functions, objc interoop, System delegate methods)
- A lot of false-negatives (text search, yep)
