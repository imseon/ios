//
//  FileProviderItem.swift
//  Files
//
//  Created by Marino Faggiana on 26/03/18.
//  Copyright © 2018 TWS. All rights reserved.
//

import FileProvider

class FileProviderItem: NSObject, NSFileProviderItem {

    // TODO: implement an initializer to create an item from your extension's backing model
    // TODO: implement the accessors to return the values from your extension's backing model

    var itemIdentifier: NSFileProviderItemIdentifier
    var parentItemIdentifier: NSFileProviderItemIdentifier
    
    var capabilities: NSFileProviderItemCapabilities {
        return .allowsAll
    }
    
    var filename: String = ""
    var typeIdentifier: String = ""
    var childItemCount: NSNumber?
    var metadata = tableMetadata()
    
    init(metadata: tableMetadata, parent: String, root: Bool) {
        
        if #available(iOSApplicationExtension 11.0, *) {
            if root {
                self.parentItemIdentifier = NSFileProviderItemIdentifier.rootContainer
            } else {
                self.parentItemIdentifier = NSFileProviderItemIdentifier(parent)
            }
        } else {
            self.parentItemIdentifier = NSFileProviderItemIdentifier(parent)
        }
        
        self.metadata = metadata
        self.filename = metadata.fileNameView
        itemIdentifier =  NSFileProviderItemIdentifier("\(metadata.fileID)")
        
        if let fileType = CCUtility.insertTypeFileIconName(metadata.fileNameView, metadata: metadata) {
            self.typeIdentifier = fileType 
        }
        
        if (metadata.directory) {
            
            self.childItemCount = 0
            
            if var serverUrl = NCManageDatabase.sharedInstance.getServerUrl(metadata.directoryID) {
                serverUrl = serverUrl + "/" + metadata.fileName
                if let directory = NCManageDatabase.sharedInstance.getTableDirectory(predicate: NSPredicate(format: "account = %@ AND serverUrl = %@", metadata.account, serverUrl)) {
                    if let metadatas = NCManageDatabase.sharedInstance.getMetadatas(predicate: NSPredicate(format: "account = %@ AND directoryID = %@", metadata.account, directory.directoryID), sorted: "fileName", ascending: true) {
                        self.childItemCount = metadatas.count as NSNumber
                    }
                }
            }
        }
    }
}