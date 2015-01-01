//
//  main.swift
//  git-commit
//
//  Created by Mattia Gheda on 2014-12-29.
//  Copyright (c) 2014 Mattia Gheda. All rights reserved.
//

import Foundation

let configFile = "/Users/tha/.git-commit"

func readConfig(filePath: String) -> Dictionary<String, AnyObject>? {
    var data = NSFileManager.defaultManager().contentsAtPath(configFile)
    if let d = data {
        var error:NSError?
        var text = String(contentsOfFile: configFile, encoding: NSUTF8StringEncoding, error: &error)
        
        let parsedObject: AnyObject? = NSJSONSerialization.JSONObjectWithData(d,
            options: NSJSONReadingOptions.AllowFragments,
            error:&error)
        
        return parsedObject as? Dictionary
    }
    
    return nil
}


func gitExec(args: Array<String>) {
    let task = NSTask()
    task.launchPath = "/Users/tha/Gentoo/usr/bin/git"
    task.arguments = args
    
    let pipe = NSPipe()
    task.standardOutput = pipe
    task.launch()
    
    let data = pipe.fileHandleForReading.readDataToEndOfFile()
    let output: String = NSString(data: data, encoding: NSUTF8StringEncoding)!
    print(output)
}

func readTicket() -> Int? {
    if let o = readConfig(configFile) {
        if let ticketId = o["ticketId"] as? Int {
            return ticketId
        }
    }
    return nil
}

func commit(msg: String) {
    if let ticketId = readTicket() {
        let m = "\(msg) [#\(ticketId)]"
        let cmd = "-m\(m)"
        println("commiting with message: \(m)")
        gitExec(["commit", cmd])
    } else {
        println("invalid ticket in config file")
    }
}

// see https://medium.com/swift-programming/4-json-in-swift-144bf5f88ce4
func JSONStringify(value: AnyObject, prettyPrinted: Bool = false) -> String {
    var options = prettyPrinted ? NSJSONWritingOptions.PrettyPrinted : nil
    if NSJSONSerialization.isValidJSONObject(value) {
        if let data = NSJSONSerialization.dataWithJSONObject(value, options: options, error: nil) {
            if let string = NSString(data: data, encoding: NSUTF8StringEncoding) {
                return string
            }
        }
    }
    return ""
}

func writeConfig(filePath: String, config: Dictionary<String, AnyObject>) {
    let out = JSONStringify(config, prettyPrinted: true)
    NSFileManager.defaultManager().createFileAtPath(
        filePath,
        contents: out.dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: true),
        attributes: Dictionary())

}

func setTicket(id: Int) {
    var config = readConfig(configFile)
    if var c = config {
        c["ticketId"] = id
        writeConfig(configFile, c)
    } else {
        var c = ["ticketId": id]
        writeConfig(configFile, c)
    }
}


readTicket()
// main
let cli = CommandLine()

let setTicket = IntOption(shortFlag: "t", longFlag: "ticket", required: false, helpMessage: "set current ticket number")
let printTicket = BoolOption(shortFlag: "p", longFlag: "print", helpMessage: "print current ticket number" )
let commitTicket = StringOption(shortFlag: "c", longFlag: "commit", required: false, helpMessage: "commit with current ticket")
let help = BoolOption(shortFlag: "h", longFlag: "help", helpMessage: "Prints a help message.")

cli.addOptions(setTicket, printTicket, commitTicket, help)


let (success, error) = cli.parse()
if !success {
    println(error!)
    cli.printUsage()
    exit(EX_USAGE)
}

if let newTicket = setTicket.value {
    setTicket(newTicket)
    exit(EX_USAGE)
}

if printTicket.value {
    if let t = readTicket() {
       println("current ticket: \(t)")
    } else {
       println("can't read current ticket, check your config")
    }
    exit(EX_USAGE)
}

if let c = commitTicket.value {
    commit(c)
    exit(EX_USAGE)
}

cli.printUsage()
exit(EX_USAGE)

