import haxe.CallStack.StackItem;
import haxe.io.BytesData;
import haxe.io.Bytes;
import Random;
import sys.io.File;
import sys.io.FileSeek;
import sys.io.FileInput;
import sys.FileSystem;
import Sys.println;
import Sys.getEnv;
import de.polygonal.Printf;
import image.Image;
using tink.CoreApi;

class TemporaryDirectory {

    public var name:String;
    public var path:String;

    public function new() {
        name = "tmp-" + Random.string(10);
        path = getEnv("TEMP") + '\\$name';

        FileSystem.createDirectory(path);
    }
    public static function deleteDirectoryRecursive(path:String) {
        for (filename in FileSystem.readDirectory(path)) {
            var filepath = '$path\\$filename';
            if (FileSystem.isDirectory(filepath)) {
                deleteDirectoryRecursive(filepath);
            } else {
                FileSystem.deleteFile(filepath);
            }
        }
        FileSystem.deleteDirectory(path);
    }
    public function dispose() {
        deleteDirectoryRecursive(path);
    }
}

class JPEGMoverStatus {

    public var fName:String;
    public var fPath:String;
    public var tName:String;
    public var tPath:String;

    public function new(fName:String, fPath:String, tName:String, tPath:String) {
        this.fName = fName;
        this.fPath = fPath;
        this.tName = tName;
        this.tPath = tPath;
    }
}

class JPEGMover {

    public var srcPath:String;
    public var dstPath:String;
    public var history:Array<JPEGMoverStatus>;

    public function new(srcPath:String, dstPath:String) {
        this.srcPath = srcPath;
        this.dstPath = dstPath;
        this.history = [];
    }

    public static function isFileJPEG(path:String):Bool {
        var data:Bytes = File.getBytes(path);
        return data.get(0) == 0xFF && data.get(1) == 0xD8 && data.get(2) == 0xFF;
    }

    public static function isJPEGAlbumPhoto(path:String):Bool {
        var match:Bool;
        Image.getInfo(path).handle(function (outcome) switch outcome {
            case Success(info):
                match = info.height == 475 && info.width == 633;
            default:
                match = false;
        });
        return match;
    }

    public function start() {
        for (filename in FileSystem.readDirectory(srcPath)) {
            var filepath:String = '$srcPath\\$filename';
            if (FileSystem.isDirectory(filepath)) {
                continue;
            }
            if (isFileJPEG(filepath) && isJPEGAlbumPhoto(filepath)) {
                var newname:String = '$filename.jpg';
                var newpath:String = '$dstPath\\$newname'; 
                File.copy(filepath, newpath);
                history.push(new JPEGMoverStatus(filename, filepath, newname, newpath));
            }
        }
    }
}

class Main {
    
    public static function main() {

        println(
            "Welcome to AlbumGrab, a small application made to read\n"+
            "album photos from the games cache directory. If you have\n"+
            "never deleted your cache directory then every album photo that\n"+
            "you've loaded with the desktop client will be recoverable\n\n"+

            "NOTE: You will be able to recover the album photos of anyone elses albums\n"+
            "that you have loaded with your game client. That being said if you are\n"+
            "unable to recover your own: you can possibly give this utility to someone\n"+
            "who has loaded your photos and recover through them. Happy Recovering ~ Jess\n\n"
        );
        println("Press enter to continue...");
        Sys.stdin().readLine();

        var tempdir = new TemporaryDirectory();
        println('created temp directory ${tempdir.path}');
        var template = "%-38s %-38s";
        var cachepath = getEnv("APPDATA") + "\\com.flowplay.ourWorld\\Local Store\\netcache";
        if (FileSystem.exists(cachepath)) {
            var jpegMover = new JPEGMover(cachepath, tempdir.path);
            jpegMover.start();
            if (jpegMover.history.length > 0) {
                println(Printf.format(template, ["orig_name", "copy_name"]));
                for (match in jpegMover.history) {

                    var fName:String = match.fName;
                    var tName:String = match.tName;
                    println(Printf.format(template, [fName, tName]));
                    
                }
                println("");
                println("Extraction Complete, press enter to go to the directory with the images.");
                Sys.stdin().readLine();
                Sys.command("explorer " + tempdir.path);
                println(
                    "They are currently in a temporary directory, to keep them you will have to\n"
                    +
                    "move them to another directory."
                    +
                    "\n"
                );
                Sys.stdin().readLine();
                println("Press enter once more to dispose of temporary directory and end the program.");
                Sys.stdin().readLine();
            } else {
                println("No album photos were found/extracted. Press enter to exit.");
                Sys.stdin().readLine();
                Sys.exit(0);
            }
        } else {
            println(
                "The netcache directory for ourWorld was not found on this system...\n"
                +
                "this may be the case due to having not played ourWorld from the desktop\n"
                +
                "client on this system. If that is so then there are no albums on this system for this utility to recover.\n"
            );
            println('Press enter to exit...');
            Sys.stdin().readLine();
        }
        tempdir.dispose();

    }
}