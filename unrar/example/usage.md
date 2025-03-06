```typescript
// 解压（异步）
const srcPath = 'xxx.rar';
const destDir = getContext(this).filesDir;
UnrarKit.extract(filePath, destDir).then(() => {
  console.log(`解压完成`);
}).catch((err: BusinessError) => {
  console.error(`解压失败: ${ JSON.stringify(err) }`);
});
```

```typescript
// 解压同步
const srcPath = 'xxx.rar';
const destDir = getContext(this).filesDir;
UnrarKit.extractSync(filePath, destDir);
```

```typescript
const srcPath = 'xxx.rar';
const flag = UnrarKit.isEncrypted(srcPath);
console.log(`文件是否加密: ${ flag ? '加密' : '不加密' }`);
```