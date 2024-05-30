# 语鹦助手
   <img src="./assets/parrot.png" width="150" height="150">

## 📌 项目概述

语鹦助手是一个跨平台的免费开源应用程序，是一个聊天和英语学习的工具。该项目基于Flutter开发，用于本地与llama.cpp模型接口，以及远程与Ollama、Mistral、Google Gemini和OpenAI模型接口。

   <img src="./assets/ui.jpg" width="200" >

## 🚀 快速开始

### 前提条件

- [操作系统要求]（Android、Windows、macOS、Linux、iOS(开发中)）
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
- [ ] 语音朗读
- [ ] 英文对话提示
- [ ] 测试各平台可用(寻找Windows测试员)

## 📘 文档

- ### 如何连接本地 Ollama
  1. 打开Ollama官网 <a href="https://www.ollama.com/"> https://www.ollama.com/ </a>
  2. 安装自己电脑对应版本，打开Ollama
  3. 下载对话模型

    ```  
    ollama run qwen:7b-chat-q8_0
    ```
  4. 设置环境变量 OLLAMA_HOST = [你的电脑IP]:11434 和 OLLAMA_ORIGINS = *
  5. 在APP修改URL地址： http://[你的电脑IP]:11434
    
- ### 如何连接BaiduAI
  1. 注册百度开发者账号
  <a href="https://cloud.baidu.com/">https://cloud.baidu.com/ </a>
  2. 创建应用，获得API Key和Secret Key
  <a href="https://cloud.baidu.com/doc/WENXINWORKSHOP/s/Slkkydake">https://cloud.baidu.com/doc/WENXINWORKSHOP/s/Slkkydake </a>
  3. 执行命令获得access_token
    ```
  curl 'https://aip.baidubce.com/oauth/2.0/token?grant_type=client_credentials&client_id=[API Key]&client_secret=[Secret Key]'
  ```
  4.  在APP修改API key: [access_token]
 
- ### 如何连接OpenAI（中国地区不能使用）
  待补充...
- ### 如何连接Gemini（中国地区不能使用）
  待补充...
- ### 如何连接MistralAI
  待补充...
- ### 如何使用 LlamaCPP 
  待补充...


- <a href="./docs/API-Compatability.xls">各种平台模型的参数</a>

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