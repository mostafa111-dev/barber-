const {app,BrowserWindow,ipcMain,shell,dialog,Menu}=require('electron');
const fs=require('node:fs');
const path=require('node:path');
const {pathToFileURL}=require('node:url');

const baseDir=(()=>{
  const argument=process.argv.find(x=>x.startsWith('--data-dir='));
  return argument?path.resolve(argument.slice(11)):(app.isPackaged?path.dirname(process.execPath):path.resolve(__dirname,'..'));
})();
const databaseDir=path.join(baseDir,'Database');
const appDir=path.resolve(__dirname,'..');
const indexFile=path.join(appDir,'Application','index.html');
const originalDatabase=path.join(appDir,'Database','Database.xlsx');
const originalAccounts=path.join(appDir,'Database','Accounts.json');
const databaseFile=path.join(databaseDir,'Database.xlsx');
const accountsFile=path.join(databaseDir,'Accounts.json');

function ensureData(){
  fs.mkdirSync(databaseDir,{recursive:true});
  if(!fs.existsSync(databaseFile)&&fs.existsSync(originalDatabase))fs.copyFileSync(originalDatabase,databaseFile);
  if(!fs.existsSync(accountsFile)&&fs.existsSync(originalAccounts))fs.copyFileSync(originalAccounts,accountsFile);
}
function atomicWrite(file,bytes){
  const temporary=file+'.'+process.pid+'.tmp';
  try{fs.writeFileSync(temporary,bytes);fs.renameSync(temporary,file)}
  finally{if(fs.existsSync(temporary))fs.unlinkSync(temporary)}
}
function isTrusted(event){
  const url=event.senderFrame?.url||'';
  return url.startsWith('file://')&&url.split('?')[0].toLowerCase()===pathToFileURL(indexFile).href.toLowerCase();
}
function requireTrusted(event){if(!isTrusted(event))throw new Error('Untrusted window')}

if(!app.requestSingleInstanceLock())app.quit();
else{
  app.on('second-instance',()=>BrowserWindow.getAllWindows()[0]?.focus());
  app.whenReady().then(()=>{
    ensureData();
    Menu.setApplicationMenu(null);
    ipcMain.handle('karbigi:read-database',event=>{requireTrusted(event);return fs.readFileSync(databaseFile)});
    ipcMain.handle('karbigi:write-database',(event,bytes)=>{
      requireTrusted(event);
      const buffer=Buffer.from(bytes);
      if(buffer.length<4||buffer.length>50*1024*1024||buffer[0]!==80||buffer[1]!==75)throw new Error('Invalid workbook');
      atomicWrite(databaseFile,buffer);return true;
    });
    ipcMain.handle('karbigi:read-accounts',event=>{requireTrusted(event);return fs.existsSync(accountsFile)?JSON.parse(fs.readFileSync(accountsFile,'utf8')):null});
    ipcMain.handle('karbigi:write-accounts',(event,accounts)=>{
      requireTrusted(event);
      if(!accounts?.auth?.salt||!accounts?.auth?.hash)throw new Error('Invalid accounts');
      const text=JSON.stringify(accounts);
      if(text.length>1024*1024)throw new Error('Accounts too large');
      atomicWrite(accountsFile,Buffer.from(text,'utf8'));return true;
    });
    ipcMain.handle('karbigi:backup-database',(event,date)=>{
      requireTrusted(event);
      if(!/^\d{4}-\d{2}-\d{2}$/.test(date))throw new Error('Invalid date');
      const folder=path.join(baseDir,'Backups');fs.mkdirSync(folder,{recursive:true});
      const backup=path.join(folder,`Database-${date}.xlsx`);
      if(!fs.existsSync(backup))fs.copyFileSync(databaseFile,backup);
      return backup;
    });
    ipcMain.handle('karbigi:select-backup',async event=>{
      requireTrusted(event);
      const choice=await dialog.showOpenDialog({properties:['openFile'],filters:[{name:'Excel',extensions:['xlsx']}]});
      if(choice.canceled||!choice.filePaths[0])return null;
      return fs.readFileSync(choice.filePaths[0]);
    });
    const window=new BrowserWindow({width:1380,height:850,minWidth:900,minHeight:650,show:false,autoHideMenuBar:true,
      icon:path.join(appDir,'Application','karbigi.ico'),backgroundColor:'#eef6f3',
      webPreferences:{preload:path.join(__dirname,'preload.js'),contextIsolation:true,nodeIntegration:false,sandbox:true,webSecurity:true}
    });
    window.once('ready-to-show',()=>window.show());
    window.webContents.setWindowOpenHandler(({url})=>{
      if(url==='about:blank')return{action:'allow'};
      if(url.startsWith('https://wa.me/'))shell.openExternal(url);
      return{action:'deny'};
    });
    window.webContents.on('will-navigate',(event,url)=>{if(url!==window.webContents.getURL())event.preventDefault()});
    window.loadFile(indexFile);
  });
  app.on('window-all-closed',()=>app.quit());
}
