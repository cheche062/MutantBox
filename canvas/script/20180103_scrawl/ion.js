var canvas = document.getElementById('canvas');
var context = canvas.getContext('2d');

var img = new Image();
// 总的坐标数组
var dotList = [];
var speed = 6;

img.onload = function() {
    init();
    startAnimate();
}

// img.src = "../../images/image.png";
img.src = "../../images/mj.png";

class Dot {
    constructor(x, y) {
        // 终点坐标
        this.target = {
                x,
                y
            }
            // 起点坐标
        this.current = {
            x: Math.random() * canvas.width,
            y: Math.random() * canvas.height
        }

        this.isDone = false;
        this.init();
    }

    init() {
        this.speedX = this.target.x >= this.current.x ? speed : -speed;
        this.speedY = this.target.y >= this.current.y ? speed : -speed;
    }

    update() {
        if (this.isDone) return;
        this.current.x += this.speedX;
        this.current.y += this.speedY;

        if (this.speedX >= 0) {
            if (this.current.x >= this.target.x) {
                this.current.x = this.target.x;
            }
        } else {
            if (this.current.x < this.target.x) {
                this.current.x = this.target.x;
            }
        }

        if (this.speedY >= 0) {
            if (this.current.y >= this.target.y) {
                this.current.y = this.target.y;
            }
        } else {
            if (this.current.y < this.target.y) {
                this.current.y = this.target.y;
            }
        }

        if (this.current.x === this.target.x && this.current.y === this.target.y) {
            this.isDone = true;
        }
    }
}

function init() {
    var _w = canvas.width;
    var _h = canvas.height;
    var posX = (_w - img.width) / 2;
    var posY = (_w - img.height) / 2 + 200;
    context.drawImage(img, posX, posY);

    var imagedata = context.getImageData(0, 0, _w, _h);

    for (let x = 0, w = _w; x < w; x += 6) {
        for (let y = 0, h = _h; y < h; y += 6) {
            let cur = (y * w + x) * 4;
            if (imagedata.data[cur + 3] >= 128 && imagedata.data[cur] < 100) {
                dotList.push(new Dot(x, y));
            }
        }
    }


    context.clearRect(0, 0, _w, _h);
    // console.log(dotList)
}


function startAnimate() {
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