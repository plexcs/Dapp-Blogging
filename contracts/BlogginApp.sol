// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.17;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Counters.sol";

contract BloggingApp is ERC721, ERC721URIStorage, Ownable {
    using Counters for Counters.Counter;

    Counters.Counter private _tokenIdCounter; 
    uint256 public fees; 

    constructor ( string memory _name, string memory _symbol, uint256 fees_ )ERC721(_name, _symbol){
        fees = fees_;
    }

    function safeMint(address to, string memory uri) public payable {
        require(msg.value >= fees, "Not enough MATIC");
        payable (owner()).transfer(fees);

        // mint nft
        uint256 tokenId = _tokenIdCounter.current();
        _tokenIdCounter.increment();
        _safeMint(to, tokenId);
        _setTokenURI(tokenId, uri);

        // return oversupplied fees
        uint256 contractBalance = address(this).balance; 

        if (contractBalance > 0) {
            payable(msg.sender).transfer(address(this).balance);
        }
    }

    function _burn(uint256 tokenId) internal override(ERC721, ERC721URIStorage) {
        super._burn(tokenId);

    }

    function tokenURI(uint256 tokenId) public view override(ERC721, ERC721URIStorage) returns(string memory) {
        return super.tokenURI(tokenId);
    }
}