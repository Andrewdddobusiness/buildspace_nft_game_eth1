const main = async () => {
    const gameContractFactory = await hre.ethers.getContractFactory('MyEpicGame');
    const gameContract = await gameContractFactory.deploy(
      ["Bulbasaur", "Charmander", "Squirtle"], // Names
      ["https://img.pokemondb.net/sprites/lets-go-pikachu-eevee/normal/bulbasaur.png", // Images
      "https://img.pokemondb.net/sprites/lets-go-pikachu-eevee/normal/charmander.png", 
      "https://img.pokemondb.net/sprites/lets-go-pikachu-eevee/normal/squirtle.png"],
      [45, 39, 44], // HP values
      [5, 6, 4], // Attack damage values
      "Mewtwo", // Boss Name
      "https://img.pokemondb.net/sprites/sword-shield/normal/mewtwo.png", // Boss Image
      106, // Boss HP
      10 // Boss Attack damage

    );
    await gameContract.deployed();
    console.log("Contract deployed to:", gameContract.address);

    let txn;

    // An NFT w/ the character at index 2 of our array
    txn = await gameContract.mintCharacterNFT(2);
    await txn.wait();

    // Get the value of the NFT's URI
    let returnedTokenUri = await gameContract.tokenURI(1);
    console.log("Token URI:", returnedTokenUri);

    txn = await gameContract.attackBoss();
    await txn.wait();

    txn = await gameContract.attackBoss();
    await txn.wait();

  };
  
  const runMain = async () => {
    try {
      await main();
      process.exit(0);
    } catch (error) {
      console.log(error);
      process.exit(1);
    }
  };
  
  runMain();