var canvas = document.getElementById('canvas');
var context = canvas.getContext('2d');

var img = new Image();
img.onload = function () {
    init()
    // console.log()
}

img.src = "../../images/image.png";

function init(){
    context.drawImage(img, 0, 0);

    var imagedata = context.getImageData(0, 0, img.width, img.height);

    var dotList = [];
    for (let x = 0, w = img.width; x < w; x+=6) {
        for (let y = 0, h = img.height; y < h; y+=6) {
            let cur = (y * w + x) * 4;
            // let cur = ((y - 1) * w + x) * 4;
            if (imagedata.data[cur + 3] !== 0){
                dotList.push({x, y});
            }
        }
    }


    // context.clearRect(0, 0, img.width, img.height);
    dotList.forEach((item) => {
        context.beginPath();
        context.arc(item.x, item.y, 2, 0, Math.PI / 180 * 360)
        context.fill();

    })



    console.log(imagedata)
}

