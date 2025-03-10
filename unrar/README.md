# ohos_unrar

unrar library for HarmonyOS.

## 安装

```shell
ohpm i @devzeng/unrar
```

OpenHarmony ohpm 环境配置等更多内容，请参考[如何安装 OpenHarmony ohpm 包](https://ohpm.openharmony.cn/#/cn/help/downloadandinstall)

## 使用

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