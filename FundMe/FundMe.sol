// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import { AggregatorV3Interface } from "@chainlink/contracts/src/v0.8/shared/interfaces/AggregatorV3Interface.sol";

// 实现功能
// 1.创建一个收款函数
// 2.记录投资人并且查看
// 3.在锁定期内，筹款达到目标值，生产商可以提款
// 4.在锁定期解除后，没有达到目标值，可以退款

// 单位换算
// 1 Ether = 1 * 10 ** 3 Finney = 1 * 10 ** 9 GWei = 1* 10 ** 9 Wei

contract FundMe {
    // 变量声明默认是不能查看的，要声明为public才可以
    mapping(address => uint256) public fundersToAmount;
    // ETH默认单位Wei，限定最小发送值
    uint256 constant MINIMUM_VALUE =  1 * 10 ** 18; // USD
    uint256 constant TARGET = 100 * 10 ** 18; // constant关键词，声明常量，不可变

    AggregatorV3Interface internal dataFeed;

    address public owner;

    uint256 deploymentTimestamp; // 单位：秒
    uint256 locktime; 

    constructor(uint256 _locktime) {
        // Sepolia测试网 ETH/USD 喂价地址
        dataFeed = AggregatorV3Interface(0x694AA1769357215DE4FAC081bf1f309aDC325306);
        owner = msg.sender;
        deploymentTimestamp = block.timestamp;
        locktime = _locktime;
    }

    // payable关键字表明此函数可以收款，原生token
    function fund() external payable {
        require(block.timestamp < deploymentTimestamp + locktime, "Fund is finish!");
        require(convertEthToUsd(msg.value) >= MINIMUM_VALUE, "Send more ETH"); // condition不成立，交易会被revert
        fundersToAmount[msg.sender] += msg.value;
    }

    // 将ETH的价格转换为USD
    function convertEthToUsd(uint256 ethAmount) internal view returns(uint256) {
        uint256 ethPrice = uint256(getChainlinkDataFeedLatestAnswer());
        // 精确度概念 precision
        // ETH / USD precision = 10 ** 8
        // X / ETH precision = 10 ** 18
        return ethAmount * ethPrice / (10 ** 8);
    }

    function getChainlinkDataFeedLatestAnswer() public view returns (int) {
        // prettier-ignore
        (
            /* uint80 roundId */,
            int256 answer,
            /*uint256 startedAt*/,
            /*uint256 updatedAt*/,
            /*uint80 answeredInRound*/
        ) = dataFeed.latestRoundData();
        return answer;
    }

    function transferOwnership(address newOwner) public onlyOwner{
        owner = newOwner;
    }

    function getFund() external windowClose onlyOwner{
        require(convertEthToUsd(address(this).balance) >= TARGET, "Target is not reached!");
        // payable(msg.sender).transfer(address(this).balance);

        /*
        转账方式：1,2纯转账，尽量使用call方法
        1.transfer 
        2.send
        3.call
        */
        bool success;
        (success, ) = payable(address(msg.sender)).call{ value: address(this).balance }("");
        require(success, "Transfer success!");
        fundersToAmount[msg.sender]  = 0;
    }

    function refund() external windowClose {
        require(convertEthToUsd(address(this).balance) < TARGET, "Target is reached!");
        uint256 fundAmount = fundersToAmount[msg.sender];
        require(fundAmount != 0, "You fund is zero!");
        bool success;
        (success, ) = payable(address(msg.sender)).call{ value: fundAmount }("");
        require(success, "Transfer tx failed!");
        // refund成功，清空funder对应的fund
        fundersToAmount[msg.sender]  = 0;
    }

    // 修改器
    modifier windowClose() {
        require(block.timestamp >= deploymentTimestamp + locktime, "Fund is ongoing!"); // 先执行，后跳转到函数体
        _;
    }

    modifier onlyOwner() {
        require(owner == msg.sender, "This func can only be called owner!");
        _;
    }
}