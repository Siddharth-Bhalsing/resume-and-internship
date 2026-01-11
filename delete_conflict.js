const fs = require('fs');
const target = 'app/auth/callback/page.tsx';
const dest = 'app/auth/callback/page.tsx.disabled';
if (fs.existsSync(target)) {
    fs.renameSync(target, dest);
    console.log('Successfully renamed ' + target + ' to ' + dest);
} else {
    console.log('File not found: ' + target);
}
