pragma solidity ^0.4.24;

import "../node_modules/zeppelin-solidity/contracts/token/ERC721/ERC721Token.sol";
import "../node_modules/zeppelin-solidity/contracts/ownership/Ownable.sol";
import "./ProxyRegistry.sol";
import "./Strings.sol";



/**
 * @title TradeableERC721Token
 * TradeableERC721Token - ERC721 contract that whitelists a trading address, and has minting functionality.
 */
contract TradeableERC721Token is ERC721Token, Ownable {
  using Strings for string;

  address proxyRegistryAddress;

  constructor(string _name, string _symbol, address _proxyRegistryAddress) ERC721Token(_name, _symbol) public {
    proxyRegistryAddress = _proxyRegistryAddress;
  }

  /**
    * @dev Mints a token to an address with a tokenURI.
    * @param _to address of the future owner of the token
    */
  function mintTo(address _to) public onlyOwner {
    uint256 newTokenId = _getNextTokenId();
    _mint(_to, newTokenId);
  }

  /**
    * @dev calculates the next token ID based on totalSupply
    * @return uint256 for the next token ID
    */
  function _getNextTokenId() private view returns (uint256) {
    return totalSupply().add(1);
  }

  function baseTokenURI() public view returns (string) {
    return "";
  }

  function tokenURI(uint256 _tokenId) public view returns (string) {
    return Strings.strConcat(
        baseTokenURI(),
        Strings.uint2str(_tokenId)
    );
  }

  /**
   * Override isApprovedForAll to whitelist user's OpenSea proxy accounts to enable gas-less listings.
   */
  function isApprovedForAll(
    address owner,
    address operator
  )
    public
    view
    returns (bool)
  {
    // Whitelist OpenSea proxy contract for easy trading.
    ProxyRegistry proxyRegistry = ProxyRegistry(proxyRegistryAddress);
    if (proxyRegistry.proxies(owner) == operator) {
        return true;
    }

    return super.isApprovedForAll(owner, operator);
  }
}