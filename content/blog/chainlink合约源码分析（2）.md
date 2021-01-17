---
title: "chainlink合约源码分析（2）"
date: 2020-12-31
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
type: "post"
---


今天我们分析chainlink合约源码。

---
 <!--more--> 
### Oracle.sol

Oracle 合约在收到转账之后，会触发 onTokenTransfer 方法，该方法会检查转账的有效性，并通过发出 OracleRequest 事件记录更为详细的数据信息
位置[Oracle.sol](https://github.com/smartcontractkit/chainlink/blob/develop/evm-contracts/src/v0.6/Oracle.sol)




### 主要代码


```
/// LinkTokenReceiver.sol
  /**
   * @notice Called when LINK is sent to the contract via `transferAndCall`
   * @dev The data payload's first 2 words will be overwritten by the `_sender` and `_amount`
   * values to ensure correctness. Calls oracleRequest.
   * @param _sender Address of the sender
   * @param _amount Amount of LINK sent (specified in wei)
   * @param _data Payload of the transaction
   */
  function onTokenTransfer(
    address _sender,
    uint256 _amount,
    bytes memory _data
  )
    public
    onlyLINK
    validRequestLength(_data)
    permittedFunctionsForLINK(_data)
  {
    assembly {
      // solhint-disable-next-line avoid-low-level-calls
      mstore(add(_data, 36), _sender) // ensure correct sender is passed
      // solhint-disable-next-line avoid-low-level-calls
      mstore(add(_data, 68), _amount)    // ensure correct amount is passed
    }
    // solhint-disable-next-line avoid-low-level-calls
    
    // 调用 oracleRequest
    (bool success, ) = address(this).delegatecall(_data); // calls oracleRequest
    require(success, "Unable to create request");
  } 
  
```


```
    /// Oracle.sol
  /**
   * @notice 构造函数 初始化的时候传入link代币的地址
   * @dev 
   * @param _link The address of the LINK token
   */
  constructor(address _link)
    public
    Ownable()
  {
    LinkToken = LinkTokenInterface(_link); // external but already deployed and unalterable
  }
  
  
/**
   * @notice Creates the Chainlink request
   * @dev Stores the hash of the params as the on-chain commitment for the request.
   * Emits OracleRequest event for the Chainlink node to detect.
   * @param _sender The sender of the request
   * @param _payment The amount of payment given (specified in wei)
   * @param _specId The Job Specification ID
   * @param _callbackAddress The callback address for the response
   * @param _callbackFunctionId The callback function ID for the response
   * @param _nonce The nonce sent by the requester
   * @param _dataVersion The specified data version
   * @param _data The CBOR payload of the request
   */
  function oracleRequest(
    address _sender,
    uint256 _payment,
    bytes32 _specId,
    address _callbackAddress,
    bytes4 _callbackFunctionId,
    uint256 _nonce,
    uint256 _dataVersion,
    bytes calldata _data
  )
    external
    override
    onlyLINK()
    checkCallbackAddress(_callbackAddress)
  {
    bytes32 requestId = keccak256(abi.encodePacked(_sender, _nonce));
    require(commitments[requestId] == 0, "Must use a unique ID");
    // solhint-disable-next-line not-rely-on-time
    uint256 expiration = now.add(EXPIRY_TIME);

    commitments[requestId] = keccak256(
      abi.encodePacked(
        _payment,
        _callbackAddress,
        _callbackFunctionId,
        expiration
      )
    );

    emit OracleRequest(
      _specId,
      _sender,
      requestId,
      _payment,
      _callbackAddress,
      _callbackFunctionId,
      expiration,
      _dataVersion,
      _data);
  }

  
   /**
   * @notice 给节点设置权限
   * @param _node The address of the Chainlink node
   * @param _allowed Bool value to determine if the node can fulfill requests
   */
  function setFulfillmentPermission(address _node, bool _allowed)
    external
    override
    onlyOwner()
  {
    authorizedNodes[_node] = _allowed;
  }
  
  
  
  /**
   * @notice 允许用户取消请求
   * sent for the request back to the requester's address.
   * @dev Given params must hash to a commitment stored on the contract in order for the request to be valid
   * Emits CancelOracleRequest event.
   * @param _requestId The request ID
   * @param _payment The amount of payment given (specified in wei)
   * @param _callbackFunc The requester's specified callback address
   * @param _expiration The time of the expiration for the request
   */
  function cancelOracleRequest(
    bytes32 _requestId,
    uint256 _payment,
    bytes4 _callbackFunc,
    uint256 _expiration
  )
    external
    override
  {
    bytes32 paramsHash = keccak256(
      abi.encodePacked(
        _payment,
        msg.sender,
        _callbackFunc,
        _expiration)
    );
    require(paramsHash == commitments[_requestId], "Params do not match request ID");
    // solhint-disable-next-line not-rely-on-time
    require(_expiration <= now, "Request is not expired");

    delete commitments[_requestId];
    emit CancelOracleRequest(_requestId);

    assert(LinkToken.transfer(msg.sender, _payment));
  }
```