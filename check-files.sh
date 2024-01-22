#!/usr/bin/env node

const fs = require('fs');
const path = require('path');
const { exec, execSync } = require('child_process')

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

  execSync('mkdir -p missing_files')
  console.log('Found missing files count:', missingFiles.length);
  console.log('Copying to missing_files:');

  missingFiles.forEach(missingFile => {
    exec(`rsync -avP ${folderPath.replace('scalled-', '')}/${missingFile.replace(/\.\w+/, '.png')} missing_files`, (err, stdout, stderr) => {
        if (err) {
          console.log(`stderr: ${stderr}`)
          return
        }
        console.log(`stdout: ${stdout}`)
      }
    )
  });
}
