---
title: "chainlink合约源码分析（1）"
date: 2020-12-30
draft: false
author: qknow
# post thumb
image: "images/chainlink.png"

# meta description
description: "chainlink合约源码分析"

# taxonomies
categories:
  - "Block Chain"
  - "Chainlink"
tags:
  - "Chainlink"

# post type
type: "featured"
---



今天我们分析chainlink合约源码。


 <!--more--> 
 
### ChainlinkClient.sol
位置[ChainlinkClient.sol](https://github.com/smartcontractkit/chainlink/blob/develop/evm-contracts/src/v0.6/ChainlinkClient.sol)



### 主要代码
```
/**
 * @notice 构建一个ChainlinkRequest
 * @param _specId node 节点创建的jobId
 * @param _callbackAddress 请求成功数据回调的地址
 * @param _callbackFunctionSignature  回调地址对应的function
 * @return A Chainlink Request struct in memory
 */
function buildChainlinkRequest(
    bytes32 _specId,
    address _callbackAddress,
    bytes4 _callbackFunctionSignature
  ) internal pure returns (Chainlink.Request memory) {
    Chainlink.Request memory req;
    return req.initialize(_specId, _callbackAddress, _callbackFunctionSignature);
  }
  
  
/**
  * @notice 向指定的oracle地址创建一个请求
  * @dev 创建并存储一个请求ID, 增加本地的nonce值, 并使用`transferAndCall` 方法发送LINK，
  * 创建到目标oracle合约地址的请求
  * 发出 ChainlinkRequested 事件.
  * @param _oracle 发送请求至的oracle地址
  * @param _req 完成初始化的Chainlink请求
  * @param _payment 请求发送的LINK数量
  * @return 请求 ID
  */  
function sendChainlinkRequestTo(address _oracle, Chainlink.Request memory _req, uint256 _payment)
    internal
    returns (bytes32 requestId)
  {
    requestId = keccak256(abi.encodePacked(this, requestCount));
    _req.nonce = requestCount;
    pendingRequests[requestId] = _oracle;
    emit ChainlinkRequested(requestId);
    require(link.transferAndCall(_oracle, _payment, encodeRequest(_req)), "unable to transferAndCall to oracle");
    requestCount += 1;

    return requestId;
  }
  
  
/**
* @notice 取消一个还没有回调的ChainlinkRequest
* @dev 需要记录录一个过期值
* 从pendingRequests删除对应request
* 触发ChainlinkCancelled事件
* @param _requestId The request ID
* @param _payment 请求发送的LINK数量
* @param _callbackFunc 请求回调指定的function
* @param _expiration 请求过期的时间
*/  
function cancelChainlinkRequest(
    bytes32 _requestId,
    uint256 _payment,
    bytes4 _callbackFunc,
    uint256 _expiration
  )
    internal
  {
    ChainlinkRequestInterface requested = ChainlinkRequestInterface(pendingRequests[_requestId]);
    delete pendingRequests[_requestId];
    emit ChainlinkCancelled(_requestId);
    requested.cancelOracleRequest(_requestId, _payment, _callbackFunc, _expiration);
  }  
```


其中 link.transferAndCall 方法即是 ERC677 定义的 token 转账方法，与 ERC20 的 transfer 方法相比，它多了一个 data 字段，可以在转账的同时携带数据。这里就将之前打包好的请求数据放在了 data 字段，跟随转账一起发送到了 Oracle 合约。transferAndCall 方法定义如下
```
/**
  * @dev 将token和额外数据一起转移给一个合约地址
  * @param _to 转移到的目的地址
  * @param _value 转移数量
  * @param _data 传递给接收合约的额外数据
  */
  function transferAndCall(address _to, uint _value, bytes _data)
    public
    returns (bool success)
  {

  }
```
