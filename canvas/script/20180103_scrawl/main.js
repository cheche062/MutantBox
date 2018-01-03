var canvas = document.getElementById('canvas');
var context = canvas.getContext('2d');
var btn_clear = document.getElementsByTagName('button')[0];
var btn_save = document.getElementsByTagName('button')[1];

// console.log(canvas.toDataURL)
context.lineWidth = 5;
context.strokeStyle = "#ff4444";
canvas.onmousedown = function(event) {
    context.beginPath();
    context.moveTo(event.offsetX, event.offsetY);

    // console.log('down', event)
    canvas.onmousemove = function(event) {
        context.lineTo(event.offsetX, event.offsetY);
        context.stroke();
    }

    function reset() {
        canvas.onmousemove = null;
        canvas.onmouseup = null;
    }
    canvas.onmouseup = reset;
    canvas.onmouseout = reset;
}

btn_clear.onclick = function() {
    context.clearRect(0, 0, canvas.width, canvas.height);
}

btn_save.onclick = function () {
    var img = new Image();
    img.src = canvas.toDataURL(`${Date.now()}.png`);
    document.getElementsByTagName('body')[0].appendChild(img);
    console.log('save')
}
