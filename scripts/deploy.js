const main = async () => {
    const gameContractFactory = await hre.ethers.getContractFactory('MyEpicGame');
    const gameContract = await gameContractFactory.deploy(
      ["Bulbasaur", "Charmander", "Squirtle"], // Names
      ["QmXiuxEb4qxTpScUDeVADHPAV2KqmQ2hoyXuUbuWwtoK1D", // Images
      "QmZmHwoc1en71ZEiSWuLi1zdR5BZpNTmzSoqLbxsunUYBu", 
      "https://img.pokemondb.net/sprites/lets-go-pikachu-eevee/normal/squirtle.png"],
      [45, 39, 44], // HP values
      [5, 6, 4], // Attack damage values
      "Mewtwo", // Boss Name
      "QmQ6GmaGGHxreN1E3Sd6PLf7keuxftnpFrMBfKmXzEAHme", // Boss Image
      106, // Boss HP
      10 // Boss Attack damage

    );
    await gameContract.deployed();
    console.log("Contract deployed to:", gameContract.address);

    // let txn;
    // We only have three characters.
    // an NFT w/ the character at index 2 of our array.
    // txn = await gameContract.mintCharacterNFT(2);
    // await txn.wait();

    // txn = await gameContract.attackBoss();
    // await txn.wait();

    // txn = await gameContract.attackBoss();
    // await txn.wait();

    console.log("Done!");

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