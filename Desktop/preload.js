const {contextBridge,ipcRenderer}=require('electron');
contextBridge.exposeInMainWorld('karbigiDesktop',Object.freeze({
  readDatabase:()=>ipcRenderer.invoke('karbigi:read-database'),
  writeDatabase:bytes=>ipcRenderer.invoke('karbigi:write-database',bytes),
  readAccounts:()=>ipcRenderer.invoke('karbigi:read-accounts'),
  writeAccounts:accounts=>ipcRenderer.invoke('karbigi:write-accounts',accounts),
  backupDatabase:date=>ipcRenderer.invoke('karbigi:backup-database',date),
  selectBackup:()=>ipcRenderer.invoke('karbigi:select-backup')
}));
