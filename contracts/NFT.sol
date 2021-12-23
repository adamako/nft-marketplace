pragma solidity ^0.8.4;

import '@openzeppelin/contracts/token/ERC721/ERC721.sol';
import '@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol';
import '@openzeppelin/contracts/utils/Counters.sol';

contract NFT is ERC721URIStorage {
    using Counters for Counters.Counter;
    //counters allow us to keep track of tokenIds
    Counters.Counter private _tokenIds;

    // address of marketplace for NFTs
    address contractAddress;

    constructor(address marketplaceAddress) ERC721('KryptoBirdz', 'KBIRDZ'){
        contractAddress = marketplaceAddress;
    }

    function mintToken(string memory tokenUrl) public returns (uint){
        _tokenIds.increment();
        uint256 newItemId = _tokenIds.current();
        _mint(msg.sender, newItemId);
        // set the token url: id and url
        _setTokenURI(newItemId, tokenUrl);
        // give the marketplace the approval to transact between users
        setApprovalForAll(contractAddress, true);

        return newItemId;
    }
}