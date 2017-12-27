var canvas = document.getElementById("tutorial");
var stage = canvas.getContext("2d");
var img_url_arr = ["images/main.png", "images/as3.png", "images/retro_mario.png"];
var dom_img = new Image();

var w = 56;
var w2 = 115;
var h = 72;
var h2 = 115;
var x = 50;
var y = 50;
function loaded(event) {
    
    stage.save();
/*     for (var i = 0; i < 3; i++ ){
        stage.drawImage(dom_img, 21, 17, w, h, x * i, y * i, w, h);
    }
    stage.clearRect(0, 0, 50, 50)
    stage.translate(100, 100)
    stage.clearRect(0, 0, 50, 50)


    // stage.restore();
    var rotate = 0;
     */
    
    
    // stage.translate(w2 / 2, w2 / 2);
    
    setInterval(function () {
        stage.clearRect(-w2 / 2, -w2 / 2, w2, w2);
        stage.rotate(Math.PI / 180 * rotate);
        
        stage.drawImage(dom_img, 106, 89, w2, h2, 0, 0, w2, h2)

    }, 50)


    
    // stage.restore();
}
dom_img.onload = loaded;

dom_img.src = img_url_arr[0];


