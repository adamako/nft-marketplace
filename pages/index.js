import axios from "axios";
import { ethers } from "ethers";
import { useEffect, useState } from "react";
import Web3Modal from "web3modal";
import KBMarket from "../artifacts/contracts/KBMarket.sol/KBMarket.json";
import NFT from "../artifacts/contracts/NFT.sol/NFT.json";
import { nftContractAddress, nftMarketAddress } from "../config";

export default function Home() {
  const [nfts, setNfts] = useState([]);
  const [loadingState, setLoadingState] = useState("Not loaded");

  useEffect(() => {
    loadNfts();
  }, []);

  const loadNfts = async () => {
    const provider = new ethers.providers.JsonRpcProvider();
    const nftTokenContract = new ethers.Contract(
      nftContractAddress,
      NFT.abi,
      provider
    );
    const marketContract = new ethers.Contract(
      nftMarketAddress,
      KBMarket.abi,
      provider
    );

    const data = await marketContract.fetchMarketTokens();
    let items = await Promise.all(
      data.map(async (i) => {
        const tokenUri = await nftTokenContract.tokenURI(i.tokenId);
        console.log(tokenUri);
        //Get NFT Token meta data
        const metaData = await axios.get(tokenUri);
        console.log(metaData);
        const price = ethers.utils.formatUnits(i.price.toString(), "ether");
        return {
          price: price,
          tokenId: i.tokenId.toNumber(),
          seller: i.seller,
          owner: i.owner,
          name: metaData.data.name,
          description: metaData.data.description,
          image: metaData.data.image,
          tokenUri,
        };
      })
    );

    setNfts(items);
    setLoadingState("Loaded");
  };

  //Buy nft
  const buyNFT = async (nft) => {
    const web3Modal = new Web3Modal();
    const connection = await web3Modal.connect();
    const provider = new ethers.providers.Web3Provider(connection);
    const signer = provider.getSigner();
    const contract = new ethers.Contract(
      nftMarketAddress,
      KBMarket.abi,
      signer
    );

    const price = ethers.utils.parseUnits(nft.price.toString(), "ether");
    const transaction = await contract.createMarketSale(
      nftContractAddress,
      nft.tokenId,
      {
        value: price,
      }
    );

    await transaction.wait();

    await loadNfts();
  };

  if (loadingState === "Loaded" && !nfts.length)
    return <h1 className={"px-20 py-7 text-4x1"}>No NFTs in marketplace</h1>;
  return <div></div>;
}
