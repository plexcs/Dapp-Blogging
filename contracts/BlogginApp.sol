// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.17;

import "./BloggyToken.sol";

contract BloggingApp {
    
    struct BlogPost {
        address author;
        string title; 
        string content;
        uint256 timestamp;
        uint256 views;
        uint256 paymentReceived;
        mapping(address => bool) likes;
        mapping(address => bool) donationsReceived;
    }
    
    address payable public owner;
    BloggyToken public bloggyToken;
    mapping(address => bool) public admins;
    mapping(uint256 => BlogPost) public blogPosts;
    uint256 public numBlogPosts = 0;
    uint256 public minPayment = 0.01 ether;

    event NewBlogPost(uint256 indexed postId, address indexed author, string title, string content );
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

        blogPosts[numBlogPosts] = BlogPost({
            author: msg.sender,
            title: title,
            content: content,
            timestamp: block.timestamp,
            views: 0,
            paymentReceived: 0
        });

        emit NewBlogPost(numBlogPosts, msg.sender, title, content); 
        numBlogPosts++;
    } 

    function likePost(uint256 postId) public {
        require(postId < numBlogPosts, "Post does not exist");
        require(!blogPosts[postId].likes[msg.sender],"POst already liked by this address");

        blogPosts[postId].likes[msg.sender] = true;
        bloggyToken.awardTokens(postId);
        emit BlogPostLiked(postId, msg.sender);
    }

    function donate(uint256 postId) public payable {
        require(postId < numBlogPosts,"Post does not exist");
        require(msg.value >= minPayment, "Donation amount must be at least 0.01");
        require(!blogPosts[postId].donationsReceived[msg.sender], "Donation already received from this address");
        
        blogPosts[postId].donationsReceived[msg.sender] = true; 
        blogPosts[postId].paymentReceived += msg.value; 
        emit BlogPostDonated(postId, msg.sender,msg.value);
    }

    function withdraw() public onlyOnwer {
        owner.transfer(address(this).balance);
    }

    functino widthdrawTokens() public onlyOwner {
        bloggyToken.transfer(owner, bloggyToken.balanceOf(address(this)));
    }
}