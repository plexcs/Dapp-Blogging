// SPDX-License-Identifier: UNLICENSED

pragma solidity ^0.8.19;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract BloggyToken is ERC20 {
    address owner;
    uint256 public viewThreshold;
    mapping(address => mapping(uint256 => bool)) public hasViewed;

    event TokensAwarded(address indexed blogger, uint256 amount);
    event ViewRecorded(address indexed viewer, uint256 indexed postId);

    constructor(uint256 _initialSupply, uint256 _viewThreshold) ERC20("Bloggy Token", "BLOG"){
        owner = msg.sender;
        _mint(msg.sender, _initialSupply * 10 ** decimals());
        viewThreshold = _viewThreshold;
    }

    // sending one token one time, 
    // 4 token in 4 times? 
    // bad for gas

    function awardTokens(uint256 postId) public {
        require(hasViewed[msg.sender][postId],"Blogger has not received any token award");
        require(!hasReachedViewThreshold(msg.sender, postId),"Blogger has already received tokens for this blog post");

        _mint(msg.sender, 1 * 10 ** decimals());
        emit TokensAwarded(msg.sender, 1);

    }

    function hasReachedViewThreshold(address blogger, uint256 postId) public view returns (bool) {
        return hasViewed[blogger][postId] && (balanceOf(blogger) >= (views(blogger, postId) / viewThreshold));
    }

    function setViewThreshold(uint256 _viewThreshold) public {
        require(msg.sender == owner, "Only the contract owner can set the view threshold");
        viewThreshold = _viewThreshold;
    }

    function views(address blogger, uint256 postId) public view returns (uint256) {
        if (hasViewed[blogger][postId]){
            return balanceOf(blogger);
        } 
        return 0;
    }

    function recordView(uint256 postId) public {
        require(!hasViewed[msg.sender][postId], "View already recorded for this address and post");
        hasViewed[msg.sender][postId] = true;
        _mint(owner , 1 * 10 ** decimals());
        emit ViewRecorded(msg.sender, postId);
    }

}