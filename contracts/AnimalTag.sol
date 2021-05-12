pragma solidity ^0.5.0;
//pragma experimental ABIEncoderV2; //Testing for function returns of type `struct`. experimental only. 

import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/release-v2.5.0/contracts/token/ERC721/ERC721Full.sol";
import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/release-v2.5.0/contracts/drafts/Counters.sol";

contract AnimalTag is ERC721Full {
    constructor () ERC721Full("AnimalTag", "TAG") public {
        //Empty constructor
        //@TODO: check if it needs to be fleshed out. 
    }
    
    using Counters for Counters.Counter; 
    Counters.Counter token_ids;

    
    //This is the structure of the Animal Tag. 
    //@TODO: add in other features or reference an Oracle network. 
    
    //
    struct Identifiers{
        string animalType;
        string gender; 
        string geneticHash;
        bool dead;
    }
    
    //Mapping to create the identification tag. 
    mapping(uint => Identifiers) public tag;
    
    event Change(uint token_id, string report_uri); //Does this event make any sense? 
    
    //Create a function to add an animal for tagging. 
    
    function addAnimal(
        address _owner, 
        string memory _animalType, 
        string memory _gender, 
        string memory _geneticHash, 
        string memory _token_uri,
        bool _dead
        ) public returns(uint) {
        token_ids.increment();
        
        uint _token_id = token_ids.current();
        
        _mint(_owner, _token_id);
        _setTokenURI(_token_id, _token_uri);
        
        tag[_token_id] = Identifiers(_animalType, _gender, _geneticHash, _dead); 
        
        return _token_id; 
    }
  
    //Create a function for when an animal dies 
    
    function deathAnimal(uint _token_id, bool _dead, string memory _report_uri) public returns(bool) {
        tag[_token_id].dead = _dead;
        
        emit Change(_token_id, _report_uri);
        return tag[_token_id].dead;
    }
    
    //Create a function to transfer animals from one address to another
    function transferAnimal(uint _token_id, address _sender, address _recipient, string memory _report_uri) public payable {
        _transferFrom(_sender, _recipient, _token_id);
        emit Change(_token_id, _report_uri); 
        
    }
    
 
}