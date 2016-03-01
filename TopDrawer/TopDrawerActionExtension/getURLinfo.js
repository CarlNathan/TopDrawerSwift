var getURLinfo = function() {};

getURLinfo.prototype = {
getDescription: function() {
    var metas = document.getElementsByTagName('meta');
    for (i=0; i<metas.length; i++) {
        if (metas[i].getAttribute("name") == "description") {
            return metas[i].getAttribute("content");
        }
    }
    return "";
},
getImage: function() {
    
    // find the largest image on the current page
    function findLargestImage(){
        // find all images on page
        var images = document.getElementsByTagName('img');
        if (images.length > 0) {
            var biggest_img = images[0];
            // for each image, do something
            for (img in images) {
                if(img.clientHeight > biggest_img.clientHeight) {
                           // set current as biggest image
                           biggest_img = img;
                }
            };
            // respond with biggest image's url / src
            return biggest_img.src=="" ? "" : biggest_img.src;
        }
    }
    
    var metas = document.getElementsByTagName('meta');
    for (i=0; i<metas.length; i++) {
        // try to find image from meta data
        switch(metas[i].getAttribute("name")){
            case "og:image":
            case "sailthru.image.full":
            case "twitter:image:src":
                return metas[i].getAttribute("content");
            default:
                // if no meta data image, use largest image on page
                return findLargestImage();
        }
    }
    
    return ""
},
run: function(arguments) {
    // Pass the baseURI of the webpage to the extension.
    arguments.completionFunction({"url": document.baseURI, "host": document.location.hostname, "title": document.title, "description": this.getDescription(), "image": this.getImage()});
},
    // Note that the finalize function is only available in iOS.
finalize: function(arguments) {
    // arguments contains the value the extension provides in [NSExtensionContext completeRequestReturningItems:completion:].
    // In this example, the extension provides a color as a returning item.
    // document.body.style.backgroundColor = arguments["bgColor"];
}
};

// The JavaScript file must contain a global object named "ExtensionPreprocessingJS".
var ExtensionPreprocessingJS = new getURLinfo;

// ExtensionPreprocessingJS.test();