const main = async () => {
    // deploying the contract
    const bloggingApp = await ethers.getContractFactory("BloggingApp");
    const fees_  = await ethers.BigNumber.from(10)
    const bloggingAppContract = await bloggingApp.deploy("BToken","BTK",fees_);
    
    await bloggingAppContract.deployed();

    console.log('Contract Address : ', bloggingAppContract.address);
}

const runMain = async () => {
    try {
        await main();
        process.exit(0);
    } catch (error){
        console.error(error);
        process.exit(1);
    }
}

runMain();