---
title: "BSC 币安智能链开发系列一"
date: 2021-01-17
draft: false
author: link2
# post thumb
image: "images/binance-1.png"

# meta description
description: "币安智能链（Binance Smart Chain)"

# taxonomies
categories:
  - "Block Chain"
  - "Binance Smart Chain"
tags:
  - "Binance Smart Chain"

# post type
type: "post"
---


### 介绍
您可能听说过原生代币为币安币（BNB）的币安链（Binance Chain），它针对快速交易进行了优化。为了实现速度，它必须做出一定的权衡–一方面从可编程角度来说，它牺牲了其它区块链的灵活性。

 <!--more--> 
但币安智能链（Binance Smart Chain）对此进行了改变。币安智能链是个具有成熟环境的新区块链，用于开发高性能去中心化应用程序。它旨在与币安链进行跨链兼容性，以确保用户兼得两者优势。

本质上两个区块链都是并行的。值得注意的是BSC并非所谓的第二层或链外扩展性解决方案。它是一个即使币安链下线后也可以运行的独立区块链。从设计的角度来看，这两个链非常相似。

由于BSC与EVM兼容，因此它支持以太坊工具和DApp。理论上讲这使开发人员可以轻松地从以太坊移植其项目。对于用户而言，这表示他们可以轻松配置诸如MetaMask之类的应用程序与BSC一起使用，只需调整几个设置即可。


### 启动节点

#### 1.1 安装go
[golang官网](https://golang.org/dl/)
```
go version
```

#### 1.2 启动bsc
```
wget --no-check-certificate https://github.com/binance-chain/bsc/releases/download/v1.0.4/geth_linux


## mainet
wget --no-check-certificate  $(curl -s https://api.github.com/repos/binance-chain/bsc/releases/latest |grep browser_ |grep mainnet |cut -d\" -f4)
unzip mainnet.zip

## testnet
wget --no-check-certificate  $(curl -s https://api.github.com/repos/binance-chain/bsc/releases/latest |grep browser_ |grep testnet |cut -d\" -f4)
unzip testnet.zip

geth --datadir node init genesis.json

## start a full node
geth --config ./config.toml --datadir ./node --pprofaddr 0.0.0.0 --metrics --pprof
```



### RPC
```
geth --rpc 
```
默认端口 **8545**

测试
```
curl --location --request POST '127.0.0.1:8545' \
--header 'Content-Type: application/json' \
--data-raw '{
	"jsonrpc":"2.0",
	"method":"net_version",
	"params":[],
	"id":67
}'
```
返回成功
```
{
    "jsonrpc": "2.0",
    "id": 67,
    "result": "56"
}
```



* 其它endpoints
```
https://bsc-dataseed.binance.org/
https://bsc-dataseed1.defibit.io/
https://bsc-dataseed1.ninicoin.io/
```
[postman](https://documenter.getpostman.com/view/4117254/ethereum-json-rpc/RVu7CT5J?version=latest)




### 参考
* [bsc node](https://docs.binance.org/smart-chain/developer/fullnode.html)
* [bsc rpc](https://docs.binance.org/smart-chain/developer/rpc.html)