// SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import "../interfaces/ITicket.sol";
// import "@openzeppelin/contracts/utils/Strings.sol";

contract Ticket is ERC721, ERC721Enumerable, ITicket {
    // using Strings for uint;
    // using SafeMath for uint; //openZeppallin libraries
    //using interface to reduce gas

    address public owner;
    address org;

    uint public eventID;
    uint public maxSupply;
    uint public mintCounter;
    uint public maxMintAmout;
    uint public startTime; //times are in unix timestamo
    uint public endTime;
    uint public price;
    uint public fixedFee;

    bool public State = true;

    string base;

    mapping (address=>bool) public contributor; 
    mapping (uint => bool) public used; //to identify used tokens

    // modifiers
    modifier onlyContributor(){
        require(contributor[msg.sender]);
        _;
    }
    modifier onlyOwner(){
        require(msg.sender == owner);
        _;
    }
    modifier valid(){
        uint timeNow = block.timestamp;
        require(timeNow > startTime);
        require(timeNow < endTime);
        require(maxSupply >= mintCounter);
        _;
    }
    modifier notPaused(){
        require(State);
        _;
    }

    constructor(
        address owner_,
        address org_,
        string[] memory nameAndSymbol, 
        string memory base_,
        uint supply,
        uint maxMints,
        uint priceInWei,
        uint startTime_,
        uint endTime_,
        uint fee_,
        uint eventID_) 
    ERC721(nameAndSymbol[0], nameAndSymbol[1]) {

        owner = owner_;
        org = org_;
        contributor[owner] = true;
        maxSupply = supply;
        base = base_;
        maxMintAmout = maxMints;
        mintCounter = 1;
        price = priceInWei;
        startTime = startTime_;
        endTime = endTime_;
        fixedFee = fee_;
        eventID = eventID_;
        
    }

    // externalTicket instance = Ticket(contract_);
    function mintTicket(address to) external override payable valid notPaused{
        require(mintCounter <= maxSupply);
        require(msg.value == price);
        _safeMint(to, mintCounter);
        mintCounter += 1;
    }

    //to recive all tokens of a person
    function walletOfOwner(address person) public view returns (uint256[] memory){
        uint256 ownerTokenCount = balanceOf(person);
        uint256[] memory tokenIds = new uint256[](ownerTokenCount);

        for (uint256 i; i < ownerTokenCount; i++) {
            tokenIds[i] = tokenOfOwnerByIndex(person, i);
        }
        return tokenIds;
    }

    //to view the token URI. Mainly used by opensea
    function tokenURI(uint tokenId) public view virtual override returns(string memory){
        require(_exists(tokenId));
        bytes32 id = bytes32(tokenId);
        return string(abi.encodePacked(base, id, ".json"));
    }

    //only contributors
    function checkIn(uint id) external override onlyContributor{
        require(!used[id]);
        used[id] = true;
    }

    // only Owner

    //to withdraw funds from the smartcontract

    function Withdraw() external override onlyOwner{
        require(address(this).balance > 0);

        uint balance = address(this).balance;
        uint charge = balance/fixedFee;
        uint withdrawableAmount = balance - charge;
        
        sendValue(payable(org), charge); //fee
        sendValue(payable(owner), withdrawableAmount); //totalAmount - fee
    }

    // basic intentional edits by admin/owner
    function changePrice(uint newPriceInWei) external override onlyOwner valid{
        price = newPriceInWei;
    }

    function changeBase(string memory base_) external override onlyOwner valid{
        base = base_;
    }

    function changeStartTime(uint time) external override onlyOwner valid{
        startTime = time;
    }

    function changeEndTime(uint time) external override onlyOwner valid{
        endTime = time;
    }

    function changeMintAmount(uint maxMints) external override onlyOwner valid{
        maxMintAmout = maxMints;
    }

    function addContributors(address person) external override onlyOwner valid{
        require(msg.sender == owner);
        contributor[person] = true;

    }
    function dropContributors(address person) external override onlyOwner valid{
        require(msg.sender == owner);
        contributor[person] = false;

    }
    function changeState() external override valid onlyOwner {
        bool prevState = State;
        State = !prevState;

    }

    // internal

    function sendValue(address payable recipient, uint256 amount) internal {

        (bool success, ) = recipient.call{value: amount}("");
        require(success, "Address: unable to send value, recipient may have reverted");
    }

    // Internal override required for solidity, Please don't change these.

    function _beforeTokenTransfer(address from, address to, uint256 tokenId)
        internal
        override(ERC721, ERC721Enumerable)
    {
        super._beforeTokenTransfer(from, to, tokenId);
    }

    function supportsInterface(bytes4 interfaceId)
        public
        view
        override(ERC721, ERC721Enumerable)
        returns (bool)
    {
        return super.supportsInterface(interfaceId);
    }
}