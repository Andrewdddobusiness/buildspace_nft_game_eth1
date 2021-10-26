// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

// Helper we wrote to encode in Base64
import "./libraries/Base64.sol";

// NFT contract to inherit from
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";

// Helper functions OpenZepplin provides.
import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/utils/Strings.sol";

import "hardhat/console.sol";

contract MyEpicGame is ERC721 {

    // We'll hold our character's attributes in a struct
    struct CharacterAttributes {
        uint characterIndex;
        string name;
        string imageURI;
        uint hp;
        uint maxHp;
        uint attackDamage;
    }

    struct BigBoss {
        string name;
        string imageURI;
        uint hp;
        uint maxHp;
        uint attackDamage;
    }

    BigBoss public bigBoss;

    // the tokenId is the NFts unique identifier
    using Counters for Counters.Counter;
    Counters.Counter private _tokenIds;

    // An array to hold the default data for our characters
    CharacterAttributes[] defaultCharacters;

    // We create a mapping from the nft's tokenId => that NFTs attributes.
    mapping(uint256 => CharacterAttributes) public nftHolderAttributes;

    // A mapping from an address => the NFTs tokenId. 
    mapping(address => uint256) public nftHolders;

    // Events
    event CharacterNFTMinted(address sender, uint256 tokenId, uint256 characterIndex);
    event AttackComplete(uint newBossHp, uint newPlayerHp);

    // Data passed in to the contract when it's first created initialising the characters.
    constructor(
        // Pokemon Variables
        string[] memory characterNames,
        string[] memory characterImageURIs,
        uint[] memory characterHp,
        uint[] memory characterAttackDmg,

        // Boss Variables
        string memory bossName, 
        string memory bossImageURI,
        uint bossHp,
        uint bossAttackDamage
    )
        // This is the name and symbol for our token
        ERC721("Pokemon", "POKE")
    {
        // Initialize the boss. Save it to our global "bigBoss" state variable.
        bigBoss = BigBoss({
            name: bossName,
            imageURI: bossImageURI,
            hp: bossHp,
            maxHp: bossHp,
            attackDamage: bossAttackDamage
        });

        console.log("Done initializing boss %s w/ HP %s, img %s", bigBoss.name, bigBoss.hp, bigBoss.imageURI);

        // Loop through all the characters, and save their values in our contract so
        // we can use them later when we mint our NFTs.
        for(uint i = 0; i < characterNames.length; i+=1) {
            defaultCharacters.push(CharacterAttributes({
                characterIndex: i,
                name: characterNames[i],
                imageURI: characterImageURIs[i],
                hp: characterHp[i],
                maxHp: characterHp[i],
                attackDamage: characterAttackDmg[i]
            }));
            
            CharacterAttributes memory c = defaultCharacters[i];
            console.log("Done initializing %s w/ HP %s, img %s", c.name, c.hp, c.imageURI);
        }

        // I increment tokenIds here to that my first NFT has an ID of 1.
        _tokenIds.increment();

    }

    // Users will be able to hit this function and get their NFT based on the characterId they send it!
    function mintCharacterNFT(uint _characterIndex) external {
        // Get current tokenId (starts at 1 since we incremented in the constructor)
        uint256 newItemId = _tokenIds.current();

        // Assigns the tokenId to the caller's wallet address
        _safeMint(msg.sender, newItemId);

        // Map the tokenId => their character attributes
        nftHolderAttributes[newItemId] = CharacterAttributes({
            characterIndex: _characterIndex,
            name: defaultCharacters[_characterIndex].name,
            imageURI: defaultCharacters[_characterIndex].imageURI,
            hp: defaultCharacters[_characterIndex].hp,
            maxHp: defaultCharacters[_characterIndex].hp,
            attackDamage: defaultCharacters[_characterIndex].attackDamage
        });

        console.log("Minted NFT w/ tokenId %s and characterIndex %s", newItemId, _characterIndex);

        //keep an easy way to see who owns what NFT
        nftHolders[msg.sender] = newItemId;

        // Increment the tokenId for the next person that uses it.
        _tokenIds.increment();

        emit CharacterNFTMinted(msg.sender, newItemId, _characterIndex);
    }

    function tokenURI(uint256 _tokenId) public view override returns (string memory) {
        CharacterAttributes memory charAttributes = nftHolderAttributes[_tokenId];

        string memory strHp = Strings.toString(charAttributes.hp);
        string memory strMaxHp = Strings.toString(charAttributes.maxHp);
        string memory strAttackDamage = Strings.toString(charAttributes.attackDamage);

        string memory json = Base64.encode(
            bytes(
                string(
                    abi.encodePacked(
                        '{"name": "',
                        charAttributes.name,
                        ' -- NFT #: ',
                        Strings.toString(_tokenId),
                        '", "description": "This is an NFT that lets people play in the game Pokemon Metaverse!", "image": "',
                        charAttributes.imageURI,
                        '", "attributes": [ { "trait_type": "Health Points", "value": ', strHp, ', "max_value":', strMaxHp, '}, { "trait_type": "Attack Damage", "value": ',
                        strAttackDamage,'} ]}'
                    )
                )
            )
        );

        string memory output = string(
            abi.encodePacked("data:application/json;base64,", json)
        );

        return output;
    }


    function attackBoss() public {
        // Get the state of the player's NFT.
        uint256 nftTokenIdOfPlayer = nftHolders[msg.sender];
        CharacterAttributes storage player = nftHolderAttributes[nftTokenIdOfPlayer];

        console.log("\nPlayer w/ character %s about to attack. Has %s HP and %s AD", player.name, player.hp, player.attackDamage);
        console.log("Boss %s has %s HP and %s AD", bigBoss.name, bigBoss.hp, bigBoss.attackDamage);

        // Make sure the player has more than 0 HP.
        require (
            player.hp > 0,
            "Error: character must have HP to attack boss."
        );

        // Make sure the boss has more than 0 HP.
        require (
            bigBoss.hp > 0,
            "Error: boss must have HP to attack boss."
        );

        // Allow player to attack boss.
        if (bigBoss.hp < player.attackDamage / 4 ) {
            bigBoss.hp = 0;
        } else {
            bigBoss.hp = bigBoss.hp - player.attackDamage;
        }

        console.log("Player attacked boss. New boss hp: %s", bigBoss.hp);

        // Allow boss to attack player.
        if (player.hp < bigBoss.attackDamage ) {
            player.hp = 0;
        } else {
            player.hp = player.hp - bigBoss.attackDamage;
        }
        
        // Console for ease.
        console.log("Boss attacked player. New player hp: %s\n", player.hp);

        emit AttackComplete(bigBoss.hp, player.hp);
    }

    function checkIfUserHasNFT() public view returns (CharacterAttributes memory) {
        // Get the tokenId of the user's character NFT
        uint256 userNftTokenId = nftHolders[msg.sender];
        // If the user has a tokenId in the map, return thier character.
        if (userNftTokenId > 0) {
            return nftHolderAttributes[userNftTokenId];
        }
        // Else, return an empty character.
        else {
            CharacterAttributes memory emptyStruct;
            return emptyStruct;
        }
    }

    function getAllDefaultCharacters() public view returns (CharacterAttributes[] memory) {
        return defaultCharacters;
    }

    function getBigBoss() public view returns (BigBoss memory) {
        return bigBoss;
    }
}