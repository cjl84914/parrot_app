# 语鹦助手
   <img src="./assets/parrot.png" width="150" height="150">

## 📌 项目概述

语鹦助手是一个跨平台的免费开源应用程序，是一个AI工具，用于聊天、学习英语、辅助教学等。该项目基于Flutter开发，用于远程与智谱AI、通义千问、零一万物、Moonshot、Ollama、Mistral、Google Gemini和OpenAI模型接口。

   <img src="./assets/ui.jpg" width="200" >

<a href="https://www.bilibili.com/video/BV1tZ3keWEyo/?share_source=copy_web&vd_source=c65662c27569e34f3751563ca5c04368" target="_blank">【B站演示：AI外教免费陪聊？】 </a>

## 🚀 快速开始

### 前提条件

- [操作系统要求]（Android、Windows、macOS、Linux、iOS）
- [必要的软件或库]（Flutter 3.16+）

### 安装步骤

1. 克隆仓库
   ```bash
   git clone https://gitee.com/alexcai/parrot_app.git
   cd parrot_app
   ```

2. 安装依赖Flutter

   <a href="https://docs.flutter.cn/get-started/install">
   https://docs.flutter.cn/get-started/install
   </a>


3. 运行应用
   ```bash
   # 查看你的设备列表
   flutter devices
   # 请修改deviceId
   flutter run -d deviceId
   ```

## 🎯 目标和愿景

- [x] 中文版支持
- [x] 支持百度AI
- [x] 语音朗读
- [x] 中英翻译
- [x] 英文对话提示
- [x] 多个对话
- [x] 对接智谱AI、零一万物AI、月之暗面AI、通义千问AI
- [x] 支持助手角色设定
- [ ] 优化UI和UX
- [ ] 测试各平台可用（已测试Android、iOS、Windows、Macos、Web）

## 📘 文档
- ### 如何连接智谱AI
  1. 登录智谱AI开放平台（https://open.bigmodel.cn/ ），
  2. 申请Api Key https://open.bigmodel.cn/usercenter/apikeys
  3. 在语鹦助手选择智谱AI模型， 输入ApiKey

- ### 如何连接通义千问AI
  1. 登录阿里云（https://help.aliyun.com/zh/dashscope/ ），申请开通DashScope，
  2. 申请Api Key https://dashscope.console.aliyun.com/apiKey
  3. 在语鹦助手选择通义千问AI模型， 输入ApiKey

- ### 如何连接零一万物AI
  1. 登录零一万物AI开放平台（https://platform.lingyiwanwu.com/ ），
  2. 申请Api Key https://platform.lingyiwanwu.com/apikeys
  3. 在语鹦助手选择零一万物AI模型， 输入ApiKey

- ### 如何连接月之暗面AI
  1. 登录智谱AI开放平台（https://platform.moonshot.cn/ ），
  2. 申请Api Key https://platform.moonshot.cn/console/api-keys
  3. 在语鹦助手选择月之暗面AI模型， 输入ApiKey

- ### 如何连接本地 Ollama
  1. 打开Ollama官网 <a href="https://www.ollama.com/"> https://www.ollama.com/ </a>
  2. 安装电脑系统对应版本，打开Ollama
  3. 下载对话模型

    ```  
    ollama run qwen:7b-chat-q8_0
    ```
  4. 设置环境变量 OLLAMA_HOST = [你的电脑IP]:11434 和 OLLAMA_ORIGINS = *
  5. 在语鹦助手修改URL地址： http://[你的电脑IP]:11434

- ### 如何连接Gemini（中国地区不能使用）
    1. 登录google ai
       https://aistudio.google.com/app/apikey
    2. 在语鹦助手选择Gemini模型
    3. 填写刚申请的apiKey
  
- ### 如何连接OpenAI（中国地区不能使用）
  待补充...
- ### 如何连接MistralAI
  待补充...

## 👥 社区和支持

- 合作请联系 QQ:121237385
- 贡献者可以通过提交 Pull Request 来参与项目。
- 如果你发现了 bug 或有功能建议，请通过 [Gitee Issues](https://gitee.com/alexcai/parrot_app/issues) 报告。

## 🔑 贡献者指南

- 请联系 QQ:121237385 申请加入种子用户群

## 🙏 致谢

- 感谢所有参与此项目的贡献者。
- 感谢 Dane Madsen。 
- <a href="https://github.com/flutter/flutter">Flutter社区</a>
- <a href="https://github.com/davidmigloz/langchain_dart">davidmigloz/langchain_dart</a>