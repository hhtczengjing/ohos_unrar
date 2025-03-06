import { UnrarKit } from '@devzeng/unrar';
import { http } from '@kit.NetworkKit';
import fs from '@ohos.file.fs';
import { BusinessError } from '@kit.BasicServicesKit';

@Extend(Text)
function headerStyle() {
  .textAlign(TextAlign.Start)
  .width('100%')
  .padding({ left: 16, right: 16 })
  .fontSize(16)
  .fontColor('#7E8388')
}

@Extend(Text)
function outputStyle() {
  .textAlign(TextAlign.Start)
  .width('100%')
  .margin({ top: 10 })
  .padding({ left: 16, right: 16 })
  .fontSize(16)
  .fontColor('#020F22')
}

const TAG = '[Index]';

@Entry
@Component
struct Index {
  @State output: string = '';
  @State loading: boolean = false;
  private fileName: string = 'files.rar';
  private downloadUrl: string = 'https://xxxx-yyy-zzz.aaa.com/files.rar';
  private filePath: string = '';
  private destPath: string = '';

  aboutToAppear(): void {
    const fileDir = this.fileName.substring(0, this.fileName.lastIndexOf('.'));
    const filesDir = getContext(this).filesDir;
    this.filePath = filesDir + '/' + this.fileName;
    this.destPath = filesDir + '/' + fileDir;
  }

  build() {
    Column() {
      Button('下载并解压')
        .fontSize(16)
        .fontWeight(FontWeight.Regular)
        .backgroundColor(this.loading ? '#BBCCE3' : '#344F9C')
        .enabled(!this.loading)
        .width('80%')
        .margin({ top: 40 })
        .onClick(() => {
          this.download(this.downloadUrl, this.filePath);
        })

      Button('是否加密')
        .fontSize(16)
        .fontWeight(FontWeight.Regular)
        .backgroundColor('#344F9C')
        .width('80%')
        .margin({ top: 10 })
        .onClick(() => {
          this.check();
        })

      Button('重置')
        .fontSize(16)
        .fontWeight(FontWeight.Regular)
        .backgroundColor('#344F9C')
        .width('80%')
        .margin({ top: 10 })
        .onClick(() => {
          this.clean();
        })

      if (this.output) {
        Column() {
          Text('Output')
            .headerStyle()

          Text(`${this.output}`)
            .outputStyle()
        }
        .margin({ top: 20 })
        .justifyContent(FlexAlign.Start)
        .alignItems(HorizontalAlign.Start)
      }
    }
    .justifyContent(FlexAlign.Start)
    .alignItems(HorizontalAlign.Center)
    .expandSafeArea([SafeAreaType.SYSTEM, SafeAreaType.KEYBOARD])
    .height('100%')
    .width('100%')
  }

  private download(url: string, filePath: string) {
    if (this.loading) {
      return;
    }
    this.loading = true;
    let httpRequest = http.createHttp();
    let opt: http.HttpRequestOptions = {
      method: http.RequestMethod.GET,
      expectDataType: http.HttpDataType.ARRAY_BUFFER
    };
    this.appendLine(`开始下载文件...`);
    httpRequest.request(url, opt).then((resp) => {
      // 保存文件
      this.saveFile(resp.result as ArrayBuffer, filePath);
      this.appendLine(`文件下载成功，保存路径为：${filePath}`);
      // 解压文件
      const destPath = getContext(this).filesDir;
      this.appendLine(`开始解压, 文件路径为: ${ destPath }`);
      UnrarKit.extract(filePath, getContext(this).filesDir).then(() => {
        this.appendLine(`解压成功`);
        fs.listFile(this.destPath).then((files) => {
          this.appendLine(`解压后的文件列表:`);
          for (let file of files) {
            this.appendLine(`${file}`);
          }
        });
        this.loading = false;
      }).catch((err: BusinessError) => {
        this.appendLine(`解压失败: ${ JSON.stringify(err) }`);
        this.loading = false;
      });
    }).catch((err: BusinessError) => {
      this.appendLine(`下载失败: ${ JSON.stringify(err) }`);
      this.loading = false;
    });
  }

  private saveFile(buf: ArrayBuffer, filePath: string): void {
    let file = fs.openSync(filePath, fs.OpenMode.READ_WRITE | fs.OpenMode.CREATE);
    fs.writeSync(file.fd, buf);
    fs.closeSync(file);
  }

  private clean(): void {
    this.output = '';
    if (fs.accessSync(this.filePath)) {
      fs.unlinkSync(this.filePath);
    }
    if (fs.accessSync(this.destPath)) {
      fs.rmdirSync(this.destPath);
    }
  }

  private appendLine(text: string): void {
    console.info(TAG, text);
    this.output += '\n' + text;
  }

  private check(): void {
    this.appendLine('开始校验文件是否加密...');
    if (!fs.accessSync(this.filePath)) {
      this.appendLine(`文件不存在: ${ this.filePath }`);
      return;
    }
    const flag = UnrarKit.isEncrypted(this.filePath);
    this.appendLine(`文件是否加密: ${ flag ? '加密' : '不加密' }`);
  }
}