import { DeployFunction } from "hardhat-deploy/types";
import { HardhatRuntimeEnvironment } from "hardhat/types";

const func: DeployFunction = async function (hre: HardhatRuntimeEnvironment) {
  const { deployer } = await hre.getNamedAccounts();
  const { deploy } = hre.deployments;

  const deployedPrivateP2PLoanLimit = await deploy("PrivateP2PLoanLimit", {
    from: deployer,
    log: true,
  });

  console.log(`PrivateP2PLoanLimit contract: `, deployedPrivateP2PLoanLimit.address);
};
export default func;
func.id = "deploy_fhePrivateP2PLoanLimit"; // id required to prevent reexecution
func.tags = ["PrivateP2PLoanLimit"];
