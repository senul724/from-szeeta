// SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;
import  "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import  "@openzeppelin/contracts/token/ERC721/IERC721Receiver.sol";

contract GroupPurchase{

    // Initial owner of the token(Seller)
    address public owner;
    // Address of the NFT contract
    address public NFT;
    // Address of the organization
    address public org;

    uint immutable day = 86400;
    // Token ID
    uint public nftId;
    // All price will be handled in wei
    // Required price for the token by seller
    uint public priceInEther;
    // Minimum cntribution per individual
    uint public minPricePerPerson;
    // Filled amount so far
    uint public filledPrice;
    /**
    *@dev The fee of the organization will be calculated by deviding the amount by a factor.
    *This will give out a fair share rather than a fixed price.
    *ex:
    *If the fee factor is 100, the amount will be devided by hundred. So 1% will be the fee.
    */
    uint public feeFactor;
    uint public offerCount = 1;
    // ID of the accepted offer
    uint public acceptedOffer;
    // Grace period for the bidder to settle the payement
    uint public gracePeriod;

    // Private state variable used by modifier to avoid re-entrancy attack
    bool called;
    // Sellers withdrawal status
    bool withdrawn;
    bool public closed;

    // Keep in track of the state of the event
    enum state{ INACTIVE, PENDING, PURCHASED, SOLD, PAID}
    // Event stateblock.timestamp < gracePeriod &&
    state public currentState;

    struct offer{
        // Bid price
        uint price;
        // Voting power recieved
        uint power;
        // Paricipation recieved
        uint participants;
        // deadline(24 hour from the creation)
        uint deadline;
        // Bidders address
        address buyer;
        // Confirmation status
        bool confirmed;
        // To avoid re-evaluating of same individual
        mapping (address=>bool) didVote;
    }

    // All contributors
    address[] contributors;

    // To limit creation of offers by individuals
    mapping (address => uint) offerFrequency;
    // To avoid transfering power while in a vote
    mapping (address => uint) transferRestriction;
    // To avoid re-evaluating of same individual
    mapping (address => bool) didAdd;
    // All offers
    mapping (uint => offer) public offers;
    // Contributor to power mapping
    mapping(address => uint) public contribution;
    // Blacklisting indiiduals who won't settle the bid
    mapping(address => bool) public blackList;


    constructor(address nft, uint nftId_, uint price, uint minPersonPrice, uint feeFactor_){
        // just check whether tx.origin is safe
        IERC721 token = IERC721(nft);
        require(token.ownerOf(nftId_) ==  tx.origin, "CALLER IS NOT OWNER");

        owner = token.ownerOf(nftId_);
        priceInEther = price;
        minPricePerPerson = minPersonPrice;
        NFT = nft;
        nftId = nftId_;
        feeFactor = feeFactor_;
        currentState = state.INACTIVE;
    }

    // modifier

    // Provide access to the owner only
    modifier restricted(){
        require (msg.sender == owner);
        _;
    }

    // Provide access to contributors only
    modifier contributorsOnly(){
        require(contribution[msg.sender] != 0);
        _;
    }

    // To avoid re-entrancy attacks
    modifier noReEntrancy(){
        require(!called);
        called = true;
        _;
        called = false;
    }

    // State restrictions
    modifier pendingSale(){
        require(currentState == state.PURCHASED);
        _;
    }

    modifier pendingPurchase(){
            require(currentState == state.PENDING);
            _;
        }

    modifier pendingSettlement(){
            require(currentState == state.SOLD);
            _;
        }

    modifier notClosed(){
            require(!closed);
            _;
        }

    // functions

    /**
     * @dev Initiating by transfering the NFT into the contracts.
     * Seller will have to approve the contract before getting started.
     */
    function initiate() external restricted{
        require(currentState == state.INACTIVE, "ALREADY INITIATED");
        require(IERC721(NFT).getApproved(nftId) == address(this), "CONTRACT NOT APPROVED");

        _transferNFT(msg.sender, address(this));
        currentState = state.PENDING;
    }

    //On sale functions

    /**
    *@dev any individual can take part and be a cntributor.
    */
    function takePart() external payable pendingPurchase notClosed{
        require((filledPrice + msg.value <= priceInEther) && (msg.value >= minPricePerPerson));

        filledPrice += msg.value;
        if(!didAdd[msg.sender]){
            contributors.push(msg.sender);
            didAdd[msg.sender] = true;
        }
        contribution[msg.sender] += msg.value;
        filledPrice += msg.value;
        if(filledPrice == priceInEther){
            currentState = state.PURCHASED;
        }
    }

    /**
    *@dev any contributor can pull out or reduce their contribution before the group purchase
    *is confirmed or if the seller close the event.
    *
    *@param amount Amount the contributor desire to pull out.
    */
    function pullOut(uint amount) external noReEntrancy contributorsOnly pendingPurchase{
        require(contribution[msg.sender]>= amount);

        _transfer(amount, msg.sender);
        contribution[msg.sender] -= amount;
        filledPrice -= amount;
    }

    /**
    *@dev Seller can close the event before the purchase is complete allowing the
    contributors to pull our their contributed amount
    */
    function close() external payable restricted notClosed pendingPurchase{

        _transferNFT(address(this), msg.sender);
        closed = true;
    }

    /**
    *@dev Function for the seller to withdraw after the group purchasing
    *event is complete.
     */
    function withdraw() external restricted notClosed noReEntrancy{
        require(!withdrawn && currentState != state.PENDING);

        uint fee = priceInEther/feeFactor;
        uint withdrawableAmount = priceInEther - fee;
        _transfer(fee, org);
        _transfer(withdrawableAmount,owner);
        withdrawn = true;

    }

    //aftersale functions

    /**
    *@dev Contributed amount of an individual will be used as the power for
    *voting. Because of this transfering of power will be restricted till the
    *expiry of the latest offer voted by an individual
    *
    *@param receiver Reciever of the power
    *@param amount amount of powwer willing to transfer
    */
    function transferPower(address receiver, uint amount) external contributorsOnly pendingSale{
        require(block.timestamp > transferRestriction[msg.sender]); // To restrict transfering the voting power after using the poer for a vote
        require(amount <= contribution[msg.sender]);

        contribution[msg.sender] -= amount;
        contribution[receiver] += amount;
    }

    /**
    *@dev Any individual can make an offer, and every offer will last for 24 hours
    *
    *@param offerPrice Bid value of the offer
    *@param offerBy address of the offer creator
    */
    function createOffer(uint offerPrice, address offerBy) external pendingSale{
        require((offerFrequency[msg.sender] + day)< block.timestamp);

        offer storage Offer = offers[offerCount];

        Offer.price = offerPrice;
        Offer.buyer = offerBy;
        Offer.deadline = block.timestamp + day;
        offerCount ++;
    }

    /**
    *@dev Any one who contributed for the group purchase will be eligible for a vote
    *once an offer reaches above 80% power and 50% participance an offer will be confirmed.
    *
    *@param offerId ID of the creaed offer
    */
    function voteForOffer(uint offerId) external contributorsOnly pendingSale{
        offer storage Offer = offers[offerId];
        require(Offer.deadline > block.timestamp && !Offer.didVote[msg.sender]);

        // To update the power transfer restriction period if needed
        if(Offer.deadline > transferRestriction[msg.sender]){
            transferRestriction[msg.sender] = Offer.deadline;
        }
        Offer.power += contribution[msg.sender];
        Offer.participants ++;

        // Checking if the offer is accepted by vote
        if(Offer.power > (filledPrice/10*8) && Offer.participants > contributors.length/2){
            Offer.confirmed = true;
            acceptedOffer = offerId;
            currentState = state.SOLD;
        }

        // Starting the grace period
        gracePeriod = block.timestamp + day;

    }

    /**
    *@dev The offeror have 24 hours to settle the payement and redeem the token.
    *
    *@param offerId ID of the creaed offer
    */
    function completeOffer(uint offerId) external payable pendingSettlement{
        require(
            offers[offerId].confirmed &&
            msg.sender == offers[offerId].buyer &&
            msg.value == offers[offerId].price);

        _transferNFT(address(this), msg.sender);
        currentState = state.PAID;
    }

    /**
    *@dev Remove the offer if the bidder doesn't settle the payement within the grace period
    */
    function kickOff() external pendingSettlement{
        require(block.timestamp < gracePeriod);

        currentState = state.PURCHASED;
        offer storage Offer = offers[acceptedOffer];
        Offer.confirmed = false;
        blackList[Offer.buyer] = true;
        acceptedOffer = 0;
    }

    // After payement functions

    /**
    *@dev After the payement is complete all the contributors can withdraw their share
    *with respect to the amount they contributed
    */
    function withdrawShare() external payable noReEntrancy pendingSettlement{
        uint withdrawableAmount = contribution[msg.sender] * offers[acceptedOffer].price / priceInEther;
        _transfer(withdrawableAmount, msg.sender);
        contribution[msg.sender] = 0;
        }

    // internal
    function _transfer(uint amount, address to) internal{
        (bool success,) = payable(to).call{value:amount}("");
        require(success);
    }

    function _transferNFT(address from_, address to_) internal{
        IERC721(NFT).safeTransferFrom(from_, to_, nftId);
    }

    // Enable handling ERC721 tokens via contract
    function onERC721Received(address operator, address from, uint256 tokenId, bytes calldata data) external returns (bytes4){
        return IERC721Receiver.onERC721Received.selector;
    }

}
