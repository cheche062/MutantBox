var fs = require('fs');
var gulp = require('gulp');
var tiny = require('gulp-tinypng-nokey');


function doCompress(inputUrl, outputUrl){
    var fileArr = fs.readdirSync(inputUrl);

    // console.log(isAllFile(inputUrl, fileArr));

    // if (isAllFile(inputUrl, fileArr)) {
    //     gulp.src(`${inputUrl}/*`)
    //         .pipe(tiny())
    //         .pipe(gulp.dest(outputUrl));

    //     return;
        
    // } 
    fileArr.forEach((item) => {
        var _urlInput = inputUrl + '/' + item;
        var _urlOutput = outputUrl;
        var result = fs.statSync(_urlInput).isFile();
        // 文件
        if (result) {
            gulp.src(_urlInput)
                .pipe(tiny())
                .pipe(gulp.dest(_urlOutput));

            // 文件夹
        } else {
            doCompress(_urlInput, _urlOutput + '/' + item);
        }
    })
    
}

// 是否都是文件
function isAllFile(url, fileArr){
    return fileArr.every(function(item){
        return fs.statSync(`${url}/${item}`).isFile()
    })
}

gulp.task('image', function () {
    doCompress('./images/', './dist/');
});


gulp.task('default', ['image']);