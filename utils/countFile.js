var fs = require('fs');

var path = process.argv[2];
var count = 0;

function countFn(path){
	var fileArr = fs.readdirSync(path);
	fileArr.forEach((item, index)=>{
		var result = fs.statSync(path +'/'+ item).isFile();
		if(result){
			count++;
		}else{
			countFn(path +'/'+ item);
		}
	})
}

countFn(path);

console.log(path);
console.log('文件总计：' + count);
