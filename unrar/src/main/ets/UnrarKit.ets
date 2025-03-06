import unrar from 'libunrar.so'

export class UnrarKit {
  /**
   * 判断文件是否加密
   *
   * @param path rar压缩文件路径
   *
   * @returns 是否加密
   */
  static isEncrypted(path: string): boolean {
    return unrar.isEncrypted(path);
  }

  /**
   * 解压文件（同步）
   *
   * @param path rar压缩文件路径
   * @param dest 解压路径
   * @param password 密码
   *
   * @returns 解压结果
   */
  static extractSync(path: string, dest: string, password?: string): void {
    unrar.extractSync(path, dest, password);
  }

  /**
   * 解压文件（异步）
   *
   * @param path rar压缩文件路径
   * @param dest 解压路径
   * @param password 密码
   *
   * @returns 解压结果
   */
  static extract(path: string, dest: string, password?: string): Promise<void> {
    return unrar.extract(path, dest, password);
  }
}