// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {HelloWorld} from "./test.sol";


// 工厂模式
contract HelloWorldFactory {
    HelloWorld hw;

    HelloWorld[] hws;

    function createHelloWorld() public {
        hw = new HelloWorld();
        hws.push(hw);
    }

    function getHelloWorldByIndex(uint256 _index)
        public
        view
        returns (HelloWorld)
    {
        return hws[_index];
    }

    function callHelloWorldByFactory(uint256 _index, uint256 _id) public view returns (string memory) {
        return hws[_index].helloWorld(_id);
    }

    function callSetHelloWorldByFactory(uint256 _index, string memory newStr, uint256 _id) public {
        hws[_index].setHelloWorld(newStr, _id);
    }
}
