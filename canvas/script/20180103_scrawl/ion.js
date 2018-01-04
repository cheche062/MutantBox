var canvas = document.getElementById('canvas');
var context = canvas.getContext('2d');
var input =  document.getElementsByTagName('input')[0];
var button = document.getElementsByTagName('button')[0];

var img = new Image();

var speed = 6;

img.onload = function() {
    
    button.onclick = function() {
        var dotList =  init(input.value);
        startAnimate(dotList);
    }


}

img.src = "../../images/image.png";
// img.src = "../../images/mj.png";

class Dot {
    constructor(x, y) {
        // 终点坐标
        this.target = {
            x,
            y
        }

        // 起点坐标
        this.start = {
            x: canvas.width / 2,
            y: canvas.height / 2
        }

        // 当前坐标
        this.current = Object.assign({}, this.start);
        this.isDone = false;
        this.init();
    }

    init() {
        this.frameNum = 0;
        this.frameCount = Math.ceil(3000 / 16.66);
        this.delay = Math.floor(Math.random() * 100);
        
    }

    update() {
        if (this.isDone) return;
        if(this.delay-- > 0) return;
        this.frameNum++;

        this.current.x = this.easeInOutCubic(this.frameNum, this.start.x, this.target.x - this.start.x, this.frameCount);
        this.current.y = this.easeInOutCubic(this.frameNum, this.start.y, this.target.y - this.start.y, this.frameCount);

        if (this.current.x === this.target.x && this.current.y === this.target.y) {
            this.isDone = true;
        }
    }

    // t 当前时间
    // b 初始值
    // c 总位移
    // d 总时间
    easeInOutCubic (t, b, c, d) {
        if ((t /= d / 2) < 1) return c / 2 * t * t * t + b;
        return c / 2 * ((t -= 2) * t * t + 2) + b;
    }
}

function init(text) {
    // 总的坐标数组
    var dotList = [];
    var _w = canvas.width;
    var _h = canvas.height;
    var posX = (_w - img.width) / 2 - 180;
    var posY = (_w - img.height) / 2 + 100;
    context.clearRect(0, 0, _w, _h);

    // context.drawImage(img, posX, posY);

    context.font = "200px Helvetica";
    context.fillText(text, posX, posY);

    var imagedata = context.getImageData(0, 0, _w, _h);

    for (let x = 0, w = _w; x < w; x += 6) {
        for (let y = 0, h = _h; y < h; y += 6) {
            let cur = (y * w + x) * 4;
            if (imagedata.data[cur + 3] > 0) {
                dotList.push(new Dot(x, y));
            }
        }
    }

    context.clearRect(0, 0, _w, _h);
    // console.log(dotList)
    return dotList;
}


function startAnimate(dotList) {
    cancelAnimationFrame(draw);

    var w = canvas.width;
    var h = canvas.height;
    var total = dotList.length;

    var draw = () => {
        context.clearRect(0, 0, w, h);

        var count = 0;
        dotList.forEach((item, index) => {
            item.update();
            if (item.isDone) count++;
            context.beginPath();
            context.arc(item.current.x, item.current.y, 2, 0, Math.PI / 180 * 360)
            context.fill();

        })

        if (count === total) {
            cancelAnimationFrame(draw);
            return;
        }

        requestAnimationFrame(draw);
    }

    draw();
}
