---
title: "运行Near主网节点（非验证节点）"
date: 2020-12-29
draft: false
author: qknow
# post thumb
image: "images/run-mainnet.png"

# meta description
description: "运行Near主网节点"

# taxonomies
categories:
  - "Block Chain"
tags:
  - "Near"

# post type
type: "post"
---

### 注册钱包

首先你创建主网钱包地址，并激活。[wallet.near.org](https://wallet.near.org/)

 <!--more--> 
 
### 部署主网节点（非验证节点）

1. clone [nearcore](https://github.com/near/nearcore)
```
git clone https://github.com/near/nearcore.git
```

2. 设置环境变量
```
export NEAR_RELEASE_VERSION=$(curl -s https://github.com/near/nearcore/releases/latest | tr '/" ' '\n' | grep "[0-9]\.[0-9]*\.[0-9]" | head -n 1)
```
3 切换分支 
```
cd nearcore
git checkout $NEAR_RELEASE_VERSION
```

4. 构建**nearcore**,时间比较长，耐心等待。
 ```
 cargo build -p neard --release
 ```
 
 5.配置**chain-id**和**account-id**
 ```
 target/release/neard init --chain-id="mainnet" --account-id=<YOUR_STAKING_POOL_ID>
 ```
 
 6. 启动节点
 
 6.1 修改**config.json**配置文件。

使用[config.json](https://s3-us-west-1.amazonaws.com/build.nearprotocol.com/nearcore-deploy/mainnet/config.json)覆盖.near/config.json

6.2  防火墙需要打开**24567**端口

6.3 运行下面命令
 ```
 target/release/neard run
 ```
 
节点已经运行，等待同步就可以了。
 
 **RPC**端口:**3030**。
 
 7. 使用**tmux**后台云运行


### 参考
[deploy-on-mainnet](https://docs.near.org/docs/validator/deploy-on-mainnet)