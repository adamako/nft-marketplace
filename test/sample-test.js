const { ethers } = require("hardhat");

describe("KBMarket", function () {
  it("Should mint and trade NFTs ", async function () {
    //Test to receive contracts addresses
    const Market = await ethers.getContractFactory("KBMarket");
    const market = await Market.deploy();
    await market.deployed();
    const marketAddress = market.address;

    const NFT = await ethers.getContractFactory("NFT");
    const nft = await NFT.deploy(marketAddress);
    await nft.deployed();
    const nftContractAddress = nft.address;

    //Test to receive listing price ans auction price
    let listingPrice = await market.getListingPrice();
    listingPrice = listingPrice.toString();

    const auctionPrice = ethers.utils.parseUnits("100", "ether");

    //Test for mining
    await nft.mintToken("https-t1");
    await nft.mintToken("https-t2");

    await market.makeMarketItem(nftContractAddress, 1, auctionPrice, {
      value: listingPrice,
    });

    await market.makeMarketItem(nftContractAddress, 2, auctionPrice, {
      value: listingPrice,
    });

    //Test for different addresses from different users - test accounts
    const [_, buyerAddress] = await ethers.getSigners();

    //Create a market sale with address,id and price
    await market
      .connect(buyerAddress)
      .createMarketSale(nftContractAddress, 1, { value: auctionPrice });

    const items = await market.fetchMarketTokens();

    console.log("items", items);
  });
});
