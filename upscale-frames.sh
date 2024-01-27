#!/usr/bin/env node

const { execSync } = require('child_process');
const fs = require('fs');

function upscaleFrames(dirName, outputDir, suffix='jpg') {
  console.log('===================');
  console.log(`Upscaling for ${dirName}...`);
  console.log('===================');
  fs.mkdirSync(outputDir, { recursive: true });
  const realesrganCmd = `./realesrgan-ncnn-vulkan${getOSType()} -i ${dirName}/ -o ${outputDir}/ -f ${suffix} -n RealESRGAN_General_x4_v3 -v -j 8:12:12`;
  execSync(realesrganCmd, { stdio: 'inherit' });
}

function getOSType() {
  const osTypeCmd = 'uname -s';
  const osType = execSync(osTypeCmd, { encoding: 'utf-8' }).trim();
  if (osType === 'Linux') return '-linux';
  if (osType === 'Darwin') return '-mac';
  if (osType.startsWith('CYGWIN') || osType.startsWith('MINGW')) return '.exe';
  console.error(`Unknown OS type: ${osType}`);
  process.exit(1);
}

// Uncomment and call functions as needed
// upscaleFrames();

module.exports = upscaleFrames;
