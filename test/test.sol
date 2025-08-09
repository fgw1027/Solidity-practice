// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

contract HelloWorld {
    bool isFirst = false; // bool值类型
    
    uint8 intVal8 = 128; // unsigned integer 只能表示正数
    uint256 intVal256 = 376182; // uint = uint256

    int256 intVar = -1; // signed integer 可以表示正负数，int = int256

    bytes32 bytesVar = "Hello world!"; // 1byte = 8bit

    string strVar = "Hello world!"; // 动态分配的bytes，效率不好

    // 合约变量存储类型为storage
    // bytes 和 bytes32不一致，bytes更像是一个数组

    address addrVar = 0x52870E6FD66929A3019fb0DBFB0EE1B4BEc43845;
    
    // public , private , interval , external
    // view修饰符，只能读取变量，不会修改变量
    // returns(string memory), returns返回值, string代表返回值类型，memory代表返回值类型的存储状态
    function helloWorld(uint256 _id) external view returns(string memory) {
        // for(uint256 i = 0; i < infos.length; i++) {
        //     if ( infos[i].id == _id ) {
        //         return addInfo(infos[i].phrase);
        //     }
        // }
        if (idToInfo[_id].addr == address(0x0)) {
            return addInfo(strVar);
        } else {
            return addInfo(idToInfo[_id].phrase);
        }
    }

    // uint256基础数据类型，默认是memory，不需要手动加
    function setHelloWorld(string memory newStr, uint256 _id) external {
        Info memory info = Info(newStr, _id, msg.sender);
        // infos.push(info);
        idToInfo[_id] = info; 
    }

    // pure修饰符，纯运算操作，不会修改变量值
    function addInfo(string memory helloStr) internal pure returns(string memory) {
        return string.concat(helloStr, ' from fgw contract.');
    }

    /*
    存储模式
    1.storage // 永久性存储
    2.memory // 暂时性存储，变量运行时可以修改
    3.calldata // 暂时性存储，变量运行时无法修改
    4.stack
    5.codes
    6.logs
    */

    // 复杂数据结构
    /*
    struct: 结构体
    array: 数组
    mapping: 映射，key-value键值对
    */

    struct Info {
        string phrase;
        uint256 id;
        address addr;
    }

    Info[] infos;

    mapping(uint256 => Info) idToInfo; // 映射类型，key => value)
}