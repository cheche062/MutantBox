var img = new Image();
img.src = 'images/rich.png';
img.onload = function () {
    draw(this);
};

function draw(img) {
    var canvas = document.getElementById('canvas');
    var ctx = canvas.getContext('2d');
    ctx.drawImage(img, 0, 0);
    img.style.display = 'none';
    var imageData = ctx.getImageData(0, 0, canvas.width, canvas.height);
    var data = imageData.data;

    var invert = function () {
        for (var i = 0; i < data.length; i += 4) {
            data[i] = 225 - data[i];     // red
            data[i + 1] = 225 - data[i + 1]; // green
            data[i + 2] = 225 - data[i + 2]; // blue
        }
        ctx.putImageData(imageData, 0, 0);
    };

    var grayscale = function () {
        for (var i = 0; i < data.length; i += 4) {
            var avg = (data[i] + data[i + 1] + data[i + 2]) / 3;
            data[i] = avg; // red
            data[i + 1] = avg; // green
            data[i + 2] = avg; // blue
        }
        ctx.putImageData(imageData, 0, 0);
    };

    // invert()
    // grayscale()
}