#!/usr/bin/env node

const fs = require('fs');
const path = require('path');

// 获取命令行参数
const args = process.argv.slice(2);

// 显示帮助信息
function displayHelp() {
  console.log('Usage: node remove-files.js [指定文件夹] [删除文件后缀的最小值] [删除文件后缀的最大值]');
}

// 检查是否传入了 --help 参数
if (args.includes('--help')) {
  displayHelp();
  process.exit(0);
}

// 确保传入了正确的参数
if (args.length !== 3) {
  displayHelp();
  process.exit(1);
}

const folderPath = args[0];
const minSuffix = parseInt(args[1]);
const maxSuffix = parseInt(args[2]);

// 检查文件夹是否存在
if (!fs.existsSync(folderPath) || !fs.statSync(folderPath).isDirectory()) {
  console.log('指定的文件夹不存在！');
  process.exit(1);
}

// 删除文件
for (let i = minSuffix; i <= maxSuffix; i++) {
  const filename = `frame-${String(i).padStart(3, '0')}.png`;
  const filePath = path.join(folderPath, filename);

  try {
    fs.unlinkSync(filePath);
    console.log(`已删除文件: ${filename}`);
  } catch (error) {
    console.error(`删除文件时出错: ${filename}`, error.message);
  }
}

console.log('删除完成！');

