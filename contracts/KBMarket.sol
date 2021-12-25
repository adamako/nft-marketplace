pragma solidity ^0.8.4;

import '@openzeppelin/contracts/token/ERC721/ERC721.sol';
import '@openzeppelin/contracts/security/ReentrancyGuard.sol';
import '@openzeppelin/contracts/utils/Counters.sol';
import 'hardhat/console.sol';


contract KBMarket is ReentrancyGuard {
    using Counters for Counters.Counter;

    //Number of items minting, number of transactions, tokens that have not been sold.

    Counters.Counter private _tokenIds;
    Counters.Counter private _tokensSold;

    //Determine the owner of the contract
    address payable owner;

    uint256 listingPrice = 0.045 ether;

    constructor() {
        //set the owner
        owner = payable(msg.sender);
    }

    struct MarketToken {
        uint itemId;
        address nftContract;
        uint256 tokenId;
        address payable seller;
        address payable owner;
        uint256 price;
        bool sold;
    }

    // tokenId return which MarketToken - fetch which one it is
    mapping(uint256 => MarketToken) private idToMarketToken;

    //listen to events from frontend applications
    event MarketTokenMinted(uint indexed itemId, address indexed nftContract, uint256 indexed tokenId, address seller, address owner, uint256 price, bool sold);

    //get the listing price
    function getListingPrice() public returns (uint256){
        return listingPrice;
    }

    // create a market item to put it up for sale
    function mintMarketItem(address nftContract, uint tokenId, uint price) public payable nonReentrant {
        require(price > 0, "Price must be at least one wei");
        require(msg.value == listingPrice, "Price must be equal to listing price");
        _tokenIds.increment();
        uint itemId = _tokenIds.current();

        //putting it up for sale - bool
        idToMarketToken[itemId] = MarketToken(itemId, nftContract, tokenId, payable(msg.sender), payable(address(0)), price, false);

        //NFT transaction
        IERC721(nftContract).transferFrom(msg.sender, address(this), tokenId);

        //Emit the transaction
        emit MarketTokenMinted(itemId, nftContract, tokenId, msg.sender, address(0), price, false);
    }

    //create market sale
    function createMarketSale(address nftContract, uint itemId) public payable nonReentrant {
        uint price = idToMarketToken[itemId].price;
        uint tokenId = idToMarketToken[itemId].tokenId;
        require(msg.value == price, "Please submit the asking price in order to continue");
        // transfert the amount to the seller
        idToMarketToken[itemId].seller.transfer(msg.value);
        // transfert the token from contract address to the buyer
        IERC721(nftContract).transferFrom(address(this), msg.sender, tokenId);
        idToMarketToken[itemId].owner = address payable(msg.sender);
        idToMarketToken[itemId].sold = true;
        _tokensSold.increment();

        address payable(owner).transfert(listingPrice);
    }

    //fetchMarketItems, minting, buying and selling. Return the number of unsold items
    function fetchMarketTokens() public view returns (MarketToken[] memory){
        uint itemCount = _tokenIds.current();
        uint unsoldItemCount = itemCount - _tokensSold.current();
        uint currentIndex = 0;

        //looping over the number of items created
        MarketToken[] memory items = new MarketToken[](unsoldItemCount);
        for (uint i = 0; i < itemCount; i++) {
            if (idToMarketToken[i + 1].owner == address(0)) {
                uint currentId = i + 1;
                MarketToken storage currentItem = idToMarketToken[currentId];
                items[currentIndex] = currentItem;
                currentIndex += 1;
            }
        }

        return items;
    }

    // fetch nft that the user has purchased
    function fetchMyTokens() public view returns (MarketToken[] memory) {
        uint totalItemCount = _tokenIds.current();
        uint itemCount = 0;
        uint currentIndex = 0;

        for (uint i = 0; i < totalItemCount; i++) {
            if (idToMarketToken[i + 1].owner == msg.sender) {
                itemCount += 1;
            }
        }

        MarketToken[] memory items = new MarketToken[](itemCount);
        for (uint i = 0; i < totalItemCount; i++) {
            if (idToMarketToken[i + 1].owner == msg.sender) {
                uint currentId = idToMarketToken[i + 1].itemId;
                //current array
                MarketToken storage currentItem = idToMarketToken[currentId];
                items[currentIndex] = currentItem;
                currentIndex += 1;
            }
        }
        return items;
    }

    //Fetch minted tokens
    function fetchItemsCreated() public view returns (MarketToken[] memory){
        uint totalItemCount = _tokenIds.current();
        uint itemCount = 0;
        uint currentIndex = 0;

        for (uint i = 0; i < totalItemCount; i++) {
            if (idToMarketToken[i + 1].seller == msg.sender) {
                itemCount += 1;
            }
        }

        MarketToken[] memory items = new MarketToken[](itemCount);
        for (uint i = 0; i < totalItemCount; i++) {
            if (idToMarketToken[i + 1].seller == msg.sender) {
                uint currentId = idToMarketToken[i + 1].itemId;
                //current array
                MarketToken storage currentItem = idToMarketToken[currentId];
                items[currentIndex] = currentItem;
                currentIndex += 1;
            }
        }
        return items;
    }

}
