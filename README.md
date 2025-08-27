# FlashMemo - 移动端智能闪记卡应用

[![Build Flutter APK](https://github.com/YOUR_USERNAME/FlashMemo/actions/workflows/build-android.yml/badge.svg)](https://github.com/YOUR_USERNAME/FlashMemo/actions/workflows/build-android.yml)

一款专为移动端设计的基于"主动回忆"和"间隔重复"科学学习理论的智能闪记卡应用。

## 📱 下载安装

### 方式一：从GitHub Actions下载（推荐）

1. 访问 [Actions页面](https://github.com/YOUR_USERNAME/FlashMemo/actions)
2. 点击最新的构建任务
3. 在"Artifacts"部分下载对应的APK文件

### 方式二：从Releases下载

1. 访问 [Releases页面](https://github.com/YOUR_USERNAME/FlashMemo/releases)
2. 下载最新版本的APK文件

## 📋 APK版本说明

| 文件名 | 适用设备 | 推荐度 |
|--------|----------|--------|
| `flashmemo-arm64-v8a-*.apk` | 现代Android设备（64位ARM） | ⭐⭐⭐⭐⭐ |
| `flashmemo-armeabi-v7a-*.apk` | 较老的Android设备（32位ARM） | ⭐⭐⭐ |
| `flashmemo-universal-*.apk` | 所有Android设备（通用版） | ⭐⭐⭐⭐ |

## ⚙️ 系统要求

- **Android版本**: 5.0 (API 21) 或更高
- **存储空间**: 至少100MB可用空间
- **网络**: 支持离线使用，同步功能需要网络连接

## 🚀 主要功能

- ✅ **智能学习算法**: 基于间隔重复原理
- ✅ **离线使用**: 无网络环境下正常学习
- ✅ **富媒体支持**: 图片、音频、视频
- ✅ **语音输入**: 快速创建卡片
- ✅ **OCR识别**: 拍照提取文字
- ✅ **多设备同步**: 云端数据同步
- ✅ **深色模式**: 护眼学习体验

## 🛠️ 开发信息

- **技术栈**: Flutter 3.16.0
- **数据库**: SQLite
- **状态管理**: Provider
- **平台支持**: Android / iOS

## 📝 安装说明

1. **下载APK文件**到您的Android设备
2. **启用未知来源**：设置 → 安全 → 允许安装未知来源的应用
3. **安装应用**：点击APK文件进行安装
4. **授予权限**：首次启动时按提示授予必要权限

## 🔧 开发构建

如果您想自行构建应用：

```bash
# 克隆代码
git clone https://github.com/YOUR_USERNAME/FlashMemo.git
cd FlashMemo

# 安装依赖
flutter pub get

# 构建APK
flutter build apk --release
```

## 📄 许可证

本项目采用 MIT 许可证 - 查看 [LICENSE](LICENSE) 文件了解详情。

## 🤝 贡献

欢迎提交Issue和Pull Request！

## 📞 联系我们

如有问题或建议，请通过以下方式联系：

- 📧 Email: your.email@example.com
- 💬 Issues: [GitHub Issues](https://github.com/YOUR_USERNAME/FlashMemo/issues)

---

**注意**: 请将README中的`YOUR_USERNAME`替换为您的实际GitHub用户名。