var canvas = document.getElementById("canvas");
var stage = canvas.getContext("2d");
var img_url_arr = ["images/main.png", "images/as3.png", "images/retro_mario.png"];
var dom_img = new Image();

function loaded(event) {
    // stage.save();
    // stage.restore();

    stage.drawImage(dom_img, 0, 0);


}
dom_img.onload = loaded;

dom_img.src = img_url_arr[2];


