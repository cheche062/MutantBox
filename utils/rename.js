const fs = require('fs');
const src_folder = '/src/';

forEachDir(`${__dirname}/${src_folder}`);

function forEachDir(src) {
	fs.readdir(src, (err, files) => {
		if (!files) return;
		files.forEach(file => {
			var currentFile = `${src}/${file}`;
			// console.log(currentFile);
			fs.stat(currentFile, (err, stats) => {
				if (stats.isDirectory()) {
					if (checkName(file)) {
						var newFile = resetName(file);
						newFile = `${src}/${newFile}`;
						fs.rename(currentFile, newFile, (err) => {
							if (err) {
								console.log(err)
							}
							
							forEachDir(newFile)
						});
						
					} else {
						forEachDir(currentFile)
					}
				} else {
					if (checkName(file)) {
						var newFile = resetName(file);
						newFile = `${src}/${newFile}`;
						fs.rename(currentFile, newFile, (err) => {
							if (err) {
								console.log(err)
							}
						})
					}
				}
			})
		})
	})
}

function checkName(name){
	if (/tx_/.test(name)) return true;
	if (/攻击/.test(name)) return true;
	if (/待机/.test(name)) return true;
	if (/受击/.test(name)) return true;
	if (/死亡/.test(name)) return true;
	if (/出场/.test(name)) return true;
	if (/移动/.test(name)) return true;
	if (/通用/.test(name)) return true;
	if (/出图/.test(name)) return true;
	if (/渲染/.test(name)) return true;
	if (/抽帧/.test(name)) return true;
	if (/特效/.test(name)) return true;
	if (/输出/.test(name)) return true;
	return false;
}

function resetName(name) {
	name = name.replace(/tx_/, "");
	name = name.replace(/受击特效/, "shouji_texiao");
	name = name.replace(/通用溅射受击/, "shouji_jianshe");
	name = name.replace(/通用主受击/, "shouji_zhu");
	name = name.replace(/通用受击爆点/, "shouji_baodian");
	name = name.replace(/通用攻击/, "gongji_tongyong");
	name = name.replace(/通用受击/, "shouji_tongyong");
	name = name.replace(/攻击出图/, "gongji");
	name = name.replace(/攻击/, "gongji");
	name = name.replace(/待机/, "daiji");
	name = name.replace(/受击/, "shouji");
	name = name.replace(/死亡/, "siwang");
	name = name.replace(/出场/, "chuchang");
	name = name.replace(/移动/, "yidong");
	name = name.replace(/抽帧/, "chouzhen");
	name = name.replace(/特效/, "texiao");
	name = name.replace(/渲染/, "");
	name = name.replace(/通用/, "");
	name = name.replace(/出图/, "");
	name = name.replace(/输出/, "");
	return name;
}
