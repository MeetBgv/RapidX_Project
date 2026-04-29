const fs = require('fs');
const path = require('path');

function walk(dir, filelist = []) {
  fs.readdirSync(dir).forEach(file => {
    const dirFile = path.join(dir, file);
    if (fs.statSync(dirFile).isDirectory()) {
      filelist = walk(dirFile, filelist);
    } else if (dirFile.endsWith('.dart')) {
      filelist.push(dirFile);
    }
  });
  return filelist;
}

const files = walk('C:/Workspace/New_rapidX/rapidx_mobile/lib/Customer');
let changedAny = false;

files.forEach(file => {
  let content = fs.readFileSync(file, 'utf8');
  let original = content;

  let needsImport = false;

  function repl(regex, replacement) {
    if (regex.test(content)) needsImport = true;
    content = content.replace(regex, replacement);
  }

  // Regex using negative lookahead to ignore if already followed by .h, .w, .sp, .r
  repl(/(height:\s*)(\d+\.?\d*)(?![\w\.])/g, '\$1\$2.h');
  repl(/(width:\s*)(\d+\.?\d*)(?![\w\.])/g, '\$1\$2.w');
  repl(/(fontSize:\s*)(\d+\.?\d*)(?![\w\.])/g, '\$1\$2.sp');
  repl(/(Radius\.circular\()(\d+\.?\d*)(?![\w\.])/g, '\$1\$2.r');
  repl(/(BorderRadius\.circular\()(\d+\.?\d*)(?![\w\.])/g, '\$1\$2.r');
  repl(/(EdgeInsets\.all\()(\d+\.?\d*)(?![\w\.])/g, '\$1\$2.w');
  
  repl(/(right:\s*)(\d+\.?\d*)(?![\w\.])/g, '\$1\$2.w');
  repl(/(left:\s*)(\d+\.?\d*)(?![\w\.])/g, '\$1\$2.w');
  repl(/(top:\s*)(\d+\.?\d*)(?![\w\.])/g, '\$1\$2.h');
  repl(/(bottom:\s*)(\d+\.?\d*)(?![\w\.])/g, '\$1\$2.h');

  repl(/(horizontal:\s*)(\d+\.?\d*)(?![\w\.])/g, '\$1\$2.w');
  repl(/(vertical:\s*)(\d+\.?\d*)(?![\w\.])/g, '\$1\$2.h');
  
  repl(/(radius:\s*)(\d+\.?\d*)(?![\w\.])/g, '\$1\$2.r');
  repl(/(blurRadius:\s*)(\d+\.?\d*)(?![\w\.])/g, '\$1\$2.r');
  repl(/(spreadRadius:\s*)(\d+\.?\d*)(?![\w\.])/g, '\$1\$2.r');
  
  repl(/(size:\s*)(\d+\.?\d*)(?![\w\.])/g, '\$1\$2.sp');
  
  if (content !== original) {
    if (needsImport && !content.includes('flutter_screenutil.dart')) {
      content = "import 'package:flutter_screenutil/flutter_screenutil.dart';\n" + content;
    }
    fs.writeFileSync(file, content, 'utf8');
    console.log('Updated: ' + file);
    changedAny = true;
  }
});

if (!changedAny) console.log('No files needed updates.');
