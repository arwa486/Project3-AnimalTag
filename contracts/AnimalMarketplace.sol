pragma solidity ^0.5.0; 

import "./AnimalTag.sol";
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
 // import "@openzeppelin/contracts/drafts/Counters.sol";

contract AnimalMarketplace {
    address deployer; 
    address payable public beneficiary; 
    
    //Current state of Auction 
    address public highestBidder;
    uint public highestBid; 
    
    //Allow withdrawls of previous bid
    mapping (address => uint) pendingReturns; 
    
    //Set to true at the end, disallows any change
    bool  public ended; 
    
    
    //Events that will be emitted on changes 
    event HighestBidIncreased(address bidder, uint amount);
    event AuctionEnded(address winner, uint amount); 
    
    
    ///Create a simple auction with '_biddingTime'
    ///seconds bidding time on behalf of the 
    ///beneficiary address '_beneficiary'
    
    constructor(
        address payable _beneficiary
        ) public {
            deployer = msg.sender; //Set as AnimalMarketplace
            beneficiary = _beneficiary;
        }
    
    function bid(address payable sender) public payable {
        //If the bid is not higher, send the money back. 
        
        require(msg.value > highestBid, "There already is a higher bid."); 
        
        if (highestBid != 0) { 
            //Sending back the money by simply using 
            //highestBidder.send(highestBid) is is a security risk 
            //because it could execute an untrusted contract. 
            //It is always safer to let the recipients withdraw their money themselves.
            
            pendingReturns[highestBidder] += highestBid; 
        }
        
        highestBidder = sender;
        highestBid = msg.value; 
        emit HighestBidIncreased(sender, msg.value);
    }
    
    //Withdraw a bid that was oerbid. 
    function withdraw() public returns (bool) {
        uint amount = pendingReturns[msg.sender];
        if (amount > 0) {
            //Set to zero so that recipient can call this function again. 
            pendingReturns[msg.sender] = 0; 
            
            if (!msg.sender.send(amount)) {
                //Reset the amount. 
                pendingReturns[msg.sender] = amount; 
                return false; 
            }
            
        }
        return true; 
    }
    
    function pendingReutrn(address sender) public view returns(uint) {
        return pendingReturns[sender];
    }
    
    //End the auction with the highest bid
    function auctionEnd() public {
    //Conditios 
    require(!ended , "auctionEnd has already been called.");
    require(msg.sender == deployer, "You are not the auction deployer!");
    
    //Effects 
    ended = true; 
    emit AuctionEnded(highestBidder, highestBid);
    
    //Interaction 
    beneficiary.transfer(highestBid);
    
    }
    
}