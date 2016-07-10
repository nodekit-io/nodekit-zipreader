/*
 * nodekit.io ZipReader
 *
 * Copyright (c) 2016 OffGrid Networks. All Rights Reserved.
 * Portions Copyright (c) 2013 GitHub, Inc. under MIT License
 * Portions Copyright (c) 2015 lazyapps. All rights reserved.
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *      http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 *
 */

import Foundation


public struct NKZipReader {
    var _cacheCDirs: NSCache
    var _cacheArchiveData: NSCache
}

public extension NKZipReader {
    
    static func create() -> NKZipReader {
        
        let cacheArchiveData2 = NSCache()
        cacheArchiveData2.countLimit = 2
        
        return NKZipReader( _cacheCDirs: NSCache(), _cacheArchiveData: cacheArchiveData2)
    }
    
    mutating func dataForFile(archive: String, filename: String) -> NSData? {
        
        if let nkzArchive = _cacheCDirs.objectForKey(archive) as? NKZArchive {
            
            if let data = _cacheArchiveData.objectForKey(archive) as? NSData {
                
                print ("READING FROM CACHE")
                
                return nkzArchive[filename, withArchiveData: data]
                
            } else
                
            {
                print ("LOADING FROM DISK WITH CACHED DIRECTORY")

                return nkzArchive[filename]
            }
            
        } else {
            
               print ("LOADING FROM DISK")
            
            guard let (nkzArchive, data) = NKZArchive.createFromPath(archive) else { return nil }
            
            _cacheCDirs.setObject(nkzArchive, forKey: archive)
            _cacheArchiveData.setObject(data, forKey: archive)
            
            return nkzArchive[filename, withArchiveData: data]
        }
    }
    
}


extension NSCache {
    subscript(key: AnyObject) -> AnyObject? {
        get {
            return objectForKey(key)
        }
        set {
            if let value: AnyObject = newValue {
                setObject(value, forKey: key)
            } else {
                removeObjectForKey(key)
            }
        }
    }
}

