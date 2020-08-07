

import UIKit
import YBImageBrowser

class BAWImageUtil {
    static func preview(sources: [URL], context: UIViewController) {
        var datas: [YBIBImageData] = []
        
        for source in sources {
            let data: YBIBImageData = YBIBImageData()
            data.imageURL = source
            datas.append(data)
        }
        
        
        let browser: YBImageBrowser = YBImageBrowser()
        browser.dataSourceArray = datas
        browser.currentPage = 0
        browser.show()
        
    }
}
