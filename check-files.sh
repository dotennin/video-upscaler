#!/usr/bin/env node

const fs = require('fs');
const path = require('path');
const { exec, execSync } = require('child_process')
const upscaleFrames = require('./upscale-frames.sh');

function findMissingFiles(folderPath) {
  const files = fs.readdirSync(folderPath);
  const sortedFiles = files
    .filter(file => /^frame-\d+(\..*)?$/.test(file))
    .sort((a, b) => {
      const numberA = parseInt(a.match(/^frame-(\d+)(\..*)?$/)[1]);
      const numberB = parseInt(b.match(/^frame-(\d+)(\..*)?$/)[1]);
      return numberA - numberB;
    });

  const missingFiles = [];

  let lastNumber = null;
  for (const file of sortedFiles) {
    const filePath = `${folderPath}/${file}`;
    const stats = fs.statSync(filePath);

    // Check if the file size is 0
    if (stats.size === 0) {
      missingFiles.push(file);
      continue;
    }

    const match = file.match(/^frame-(\d+)(\..*)?$/);
    if (match) {
      const fileNumber = parseInt(match[1]);
      if (lastNumber !== null && fileNumber - lastNumber > 1) {
        for (let i = lastNumber + 1; i < fileNumber; i++) {
          missingFiles.push(`frame-${i.toString().padStart(3, '0')}${match[2] || ''}`);
        }
      }
      lastNumber = fileNumber;
    }
  }

  return missingFiles;
}

const folderPath = process.argv[2];

if (!folderPath) {
  console.error('Usage: check_files.sh <scalled-folder-path>');
  process.exit(1);
}

const missingFiles = findMissingFiles(folderPath);

if (missingFiles.length === 0) {
  console.log('All files are present and in sequence.');
} else {

  const missingFilesFolder = 'missing_files'

  execSync(`mkdir -p ${missingFilesFolder}/scalled`)
  console.log('Found missing files count:', missingFiles.length);
  console.log(`Creating symlinks in ${missingFilesFolder}:`);

  missingFiles.forEach(missingFile => {
    execSync(`rsync -avP ${folderPath.replace('scalled-', '')}/${missingFile.replace(/\.\w+/, '.png')} ${missingFilesFolder}`)
  });

  upscaleFrames(missingFilesFolder, `${missingFilesFolder}/scalled`)

  // moving missing files back
  execSync(`mv ${missingFilesFolder}/scalled/* ${folderPath}`)

  // removing missing files folder
  execSync(`rm -rf ${missingFilesFolder}`)

}
