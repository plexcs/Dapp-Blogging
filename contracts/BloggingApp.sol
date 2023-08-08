// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.19;

import "./BloggyToken.sol";

contract BloggingApp {
    
    struct BlogPost {
        address author;
        string title; 
        string content;
        uint256 timestamp;
        uint256 views;
        bool paymentRecieved;
        uint256 paymentAmount;
        uint256 likes;
    }


    
    address payable public owner;
    BloggyToken public bloggyToken;
    mapping(address => bool) public admins;
    mapping(uint => BlogPost) public blogPosts;
    mapping(uint256 => mapping(address => bool)) public postLikes;
    uint256 public numBlogPosts = 0;
    uint256 public minPayment = 0.01 ether;

    event NewBlogPost(uint256 indexed postId, address indexed author, string title, string content, uint256 timestamp, uint256 likes, uint256 views);
    event BlogPostLiked(uint256 indexed postId, address indexed liker);
    event BlogPostDonated(uint256 indexed postId, address indexed donor, uint256 amount);

    constructor(address _bloggyToken){
        owner = payable(msg.sender);
        bloggyToken = BloggyToken(_bloggyToken);
        admins[msg.sender] = true;
    }  

    modifier onlyOwner(){
        require(msg.sender == owner, "Only the owner can perform this action");
        _;
    }

    modifier onlyAdmin(){
        require(admins[msg.sender], "Only admins can perform this action");
        _;
    } 

    function addAdmin(address newAdmin) public onlyOwner {
        admins[newAdmin] = true;
    }

    function removeAdmin(address admin) public onlyOwner {
        delete admins[admin];
    }

    function setMinPayment(uint256 _minPayment) public onlyAdmin {
        minPayment = _minPayment;
    }

    function publishPost(string memory title, string memory content) public {
        require(bytes(title).length > 0 && bytes(content).length > 0, "Title and content must not be empty");
        numBlogPosts++;
        blogPosts[numBlogPosts] = BlogPost(msg.sender, title, content, block.timestamp, 0, false, 0,0);
        emit NewBlogPost(numBlogPosts, msg.sender, title, content, block.timestamp, 0,0); 
        
    } 

    function likePost(uint256 postId) public {
        require(postId < numBlogPosts, "Post does not exist");
        require(!postLikes[postId][msg.sender],"POst already liked by this address");

        postLikes[postId][msg.sender] = true;
        bloggyToken.awardTokens(postId);
        emit BlogPostLiked(postId, msg.sender);
    }

    function donate(uint256 postId) public payable {
        require(postId < numBlogPosts,"Post does not exist");
        require(msg.value >= minPayment, "Donation amount must be at least 0.01");
        require(blogPosts[postId].paymentRecieved == false, "Donation already received from this address");
        
        blogPosts[postId].paymentRecieved = true; 
        blogPosts[postId].paymentAmount += msg.value; 
        emit BlogPostDonated(postId, msg.sender,msg.value);
    }

    function withdraw() public onlyOwner {
        owner.transfer(address(this).balance);
    }

    function widthdrawTokens() public onlyOwner {
        bloggyToken.transfer(owner, bloggyToken.balanceOf(address(this)));
    }
}