// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/token/ERC721/ERC721.sol";
import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/token/ERC721/IERC721Receiver.sol";
import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/utils/structs/EnumerableSet.sol";
import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/access/Ownable.sol";

contract Pengu is IERC721Receiver, Ownable {
    constructor() Ownable(msg.sender) {}

    // Pudgy Penguins contract address
 address constant PUDGY_PENGUINS_ADDRESS = 0xBd3531dA5CF5857e7CfAA92426877b022e612cf8;
address constant LITTLE_PUDGIES_ADDRESS = 0x524cAB2ec69124574082676e6F654a18df49A048;
function onERC721Received(
        address operator,
        address from,
        uint256 tokenId,
        bytes calldata data
    ) external override returns (bytes4) {
        return bytes4(keccak256("onERC721Received(address,address,uint256,bytes)"));
    }

    // Penguin struct
    struct Penguin {
        string name;
        uint256 age;
        uint256 hatchDate;
        uint256 hungerLevel;
        uint256 happinessLevel;
        bool isSleeping;
        uint256 lastFed;
        uint256 lastPlayed;
    }

    // Mapping of penguin owners to their penguin IDs
    using EnumerableSet for EnumerableSet.UintSet;
    mapping(address => EnumerableSet.UintSet) private penguinOwners;

    // Mapping of penguin IDs to their properties
    mapping(uint256 => Penguin) public penguinProperties;

    // Event emitted when a new penguin is born
    event NewPenguin(address owner, uint256 penguinId, string name);

    // Event emitted when a penguin is transferred
    event PenguinTransfer(address from, address to, uint256 penguinId);

    // Event emitted when a penguin is fed
    event PenguinFed(address owner, uint256 penguinId);

    // Event emitted when a penguin is played with
    event PenguinPlayed(address owner, uint256 penguinId);

function verifyOwnership(uint256 _tokenId) public view returns (bool) {
    return 
        ERC721(PUDGY_PENGUINS_ADDRESS).ownerOf(_tokenId) == msg.sender || 
        ERC721(LITTLE_PUDGIES_ADDRESS).ownerOf(_tokenId) == msg.sender;
}
function transferPenguin(uint256 _tokenId) public {
    require(verifyOwnership(_tokenId), "You do not own this penguin");
    
    address tokenOwner = 
        ERC721(PUDGY_PENGUINS_ADDRESS).ownerOf(_tokenId) == msg.sender ? 
        PUDGY_PENGUINS_ADDRESS : 
        LITTLE_PUDGIES_ADDRESS;
        
    require(tokenOwner != address(0), "Token owner is null");
    
    // Update penguin ownership
    penguinOwners[msg.sender].add(_tokenId);
    
    // Emit event
    emit PenguinTransfer(address(0), msg.sender, _tokenId);
    
    // Transfer NFT
    ERC721(tokenOwner).safeTransferFrom(msg.sender, address(this), _tokenId);
}
    // Hatch a new penguin
    function hatchPenguin(uint256 _tokenId, string memory _name) public {
        require(verifyOwnership(_tokenId), "You do not own this penguin");

        // Create a new penguin
        penguinProperties[_tokenId] = Penguin(
            _name,
            0,
            block.timestamp,
            50,
            50,
            false,
            block.timestamp,
            block.timestamp
        );

        // Emit event
        emit NewPenguin(msg.sender, _tokenId, _name);
    }

   // Feed a penguin
function feedPenguin(uint256 _tokenId) public {
    require(verifyOwnership(_tokenId), "You do not own this penguin");

    Penguin storage penguin = penguinProperties[_tokenId];
    penguin.hungerLevel = (penguin.hungerLevel + 20) < 100 ? (penguin.hungerLevel + 20) : 100;
    penguin.lastFed = block.timestamp;

    emit PenguinFed(msg.sender, _tokenId);
}

// Play with a penguin
function playWithPenguin(uint256 _tokenId) public {
    require(verifyOwnership(_tokenId), "You do not own this penguin");

    Penguin storage penguin = penguinProperties[_tokenId];
    penguin.happinessLevel = (penguin.happinessLevel + 20) < 100 ? (penguin.happinessLevel + 20) : 100;
    penguin.lastPlayed = block.timestamp;

    emit PenguinPlayed(msg.sender, _tokenId);
}

// Update penguin status
function updatePenguinStatus(uint256 _tokenId) public {
    Penguin storage penguin = penguinProperties[_tokenId];
    uint256 timePassed = block.timestamp - penguin.lastFed;

    penguin.hungerLevel = (penguin.hungerLevel - (timePassed / 60)) > 0 ? (penguin.hungerLevel - (timePassed / 60)) : 0;
    penguin.happinessLevel = (penguin.happinessLevel - (timePassed / 120)) > 0 ? (penguin.happinessLevel - (timePassed / 120)) : 0;
}
    // Owner-initiated hatching
    function hatchMyPenguin(uint256 _tokenId, string memory _name) public {
        require(verifyOwnership(_tokenId), "You do not own this penguin");
        penguinProperties[_tokenId] = Penguin(
            _name,
            0,
            block.timestamp,
            50,
            50,
            false,
            block.timestamp,
            block.timestamp
        );
        emit NewPenguin(msg.sender, _tokenId, _name);
    }

   function generateRandomName() internal returns (string memory) {
        string[4] memory adjectives = ["Fluffy", "Cute", "Tiny", "Happy"];
        string[4] memory nouns = ["Pengy", "Chick", "Flipper", "Waddler"];
        uint256 randIndex = uint256(keccak256(abi.encodePacked(block.timestamp))) % adjectives.length;
        return string(abi.encodePacked(adjectives[randIndex], nouns[randIndex]));
    }

    // Random hatching
    function hatchRandomPenguin(uint256 _tokenId) public {
        require(verifyOwnership(_tokenId), "You do not own this penguin");
        string memory name = generateRandomName();
        penguinProperties[_tokenId] = Penguin(
            name,
            0,
            block.timestamp,
            50,
            50,
            false,
            block.timestamp,
            block.timestamp
        );
        emit NewPenguin(msg.sender, _tokenId, name);
    }
}
