// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;


import "./NFTDAO_ERC20.sol";
//import "./DappToken.sol";
//import "./DaiToken.sol";

contract TokenFarm {
    string public name = "NFTDAO Token Farm";
    address public owner;
    ERC20 public DAOToken;
    ERC20 public DappToken;
    //DaiToken public daiToken;

    address[] public stakers;
    mapping(address => uint256) public stakingBalance;
    mapping(address => bool) public hasStaked;
    mapping(address => bool) public isStaking;

    constructor(ERC20 _DAOToken, ERC20 _DappToken)  {
        DAOToken = _DAOToken;
        DappToken = _DappToken;
        owner = msg.sender;
    }
    // 기본적으로 사용자가 실행을 주체, 중앙화되어있지 않음


    //원하는 금액만큼 스테이킹 실행
    function stakeTokens(uint256 _amount) public {
        require(_amount > 0, "amount cannot be 0"); // 반드시 스테이킹 할 양은 0보다 커야한다.

        DappToken.transferFrom(msg.sender, address(this), _amount); // 사용자, CA, 금액을 전송

        // (bool success, bytes memory data) = address(daiToken).delegatecall(abi.encodeWithSignature("transferFrom(address,address,uint256)", msg.sender, address(this), _amount));
        // delegatecall도 활용해 보고자 하였지만 daiToken의 msg.sender를 굳이 사용자로 지정할 필요성을 느끼지 못하여 활용은 하지 않았습니다.

        stakingBalance[msg.sender] = stakingBalance[msg.sender] + _amount; // 스테이킹한 양만큼 증가시킨다.

        if (!hasStaked[msg.sender]) {
            stakers.push(msg.sender);
        }

        // 스테이킹을 하였다는것을 표시해주는 역할
        isStaking[msg.sender] = true;
        hasStaked[msg.sender] = true;
    }

    //스테이킹한 모든 금액 취소 함수
    function unstakeTokens() public {

        uint256 balance = stakingBalance[msg.sender];


        require(balance > 0, "staking balance cannot be 0");


        DappToken.transfer(msg.sender, balance);

        stakingBalance[msg.sender] = 0;
        isStaking[msg.sender] = false;
    }

    // 스테이킹 보상 주는 함수
    function issueTokens() public {
        require(msg.sender == owner, "caller must be the owner"); // 운영자만이 사용 가능합니다.

        for (uint256 i = 0; i < stakers.length; i++) {
            address recipient = stakers[i];
            uint256 balance = stakingBalance[recipient];
            if (balance > 0) {
                DappToken.transfer(recipient, balance);
            }
        }

    }
}