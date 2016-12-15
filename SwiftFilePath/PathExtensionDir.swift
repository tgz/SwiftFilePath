//
//  Dir.swift
//  SwiftFilePath
//
//  Created by nori0620 on 2015/01/08.
//  Copyright (c) 2015年 Norihiro Sakamoto. All rights reserved.
//

// Instance Factories for accessing to readable iOS dirs.
#if os(iOS)
extension Path {
    
    public class var homeDir :Path{
        let pathString = NSHomeDirectory()
        return Path( pathString )
    }
    
    public class var temporaryDir:Path {
        let pathString = NSTemporaryDirectory()
        return Path( pathString )
    }
    
    public class var documentsDir:Path {
        return Path.userDomainOf(.documentDirectory)
    }
    
    public class var cacheDir:Path {
        return Path.userDomainOf(.cachesDirectory)
    }
    
    private class func userDomainOf(_ pathEnum:FileManager.SearchPathDirectory)->Path{
        let pathString = NSSearchPathForDirectoriesInDomains(pathEnum, .userDomainMask, true)[0] 
        return Path( pathString )
    }
    
}
#endif

// Add Dir Behavior to Path by extension
extension Path: Sequence {
    
    public subscript(filename: String) -> Path {
        get { return self.content(filename) }
    }

    public var children:Array<Path>? {
        assert(self.isDir,"To get children, path must be dir< \(path_string) >")
        assert(self.exists,"Dir must be exists to get children.< \(path_string) >")
        
        var contents: [String]? = nil
        do {
            contents = try self.fileManager.contentsOfDirectory(atPath: path_string)
        } catch let error {
            print("Error< \(error.localizedDescription) >")
        }
        
        return contents?.map { [unowned self] content in
            return self.content(content)
        }
        
    }
    
    public var contents:Array<Path>? {
        return self.children
    }
    
    public func content(_ path_string:String) -> Path {
        return Path( (self.path_string as NSString).appendingPathComponent(path_string) )
    }
    
    public func child(_ path:String) -> Path {
        return self.content(path)
    }
    
    public func mkdir() -> Result<Path,Error> {
        var error: Error?
        let result: Bool
        do {
            try fileManager.createDirectory(atPath: path_string,
                        withIntermediateDirectories:true,
                            attributes:nil)
            result = true
        } catch let error1 {
            error = error1
            result = false
        }
        return result
            ? Result(success: self)
            : Result(failure: error!)
        
    }
    
    public func makeIterator() -> AnyIterator<Path> {
        assert(self.isDir,"To get iterator, path must be dir< \(path_string) >")
        let iterator = fileManager.enumerator(atPath: path_string)
        return AnyIterator() {
            let optionalContent = iterator?.nextObject() as! String?
            if let content = optionalContent {
                return self.content(content)
            } else {
                return .none
            }
        }
    }
    
}
