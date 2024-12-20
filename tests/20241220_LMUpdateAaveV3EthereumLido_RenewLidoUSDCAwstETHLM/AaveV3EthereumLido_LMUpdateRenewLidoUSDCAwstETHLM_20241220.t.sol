// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {AaveV3EthereumLido, AaveV3EthereumLidoAssets} from 'aave-address-book/AaveV3EthereumLido.sol';
import {IEmissionManager, ITransferStrategyBase, RewardsDataTypes, IEACAggregatorProxy, IRewardsController} from '../../src/interfaces/IEmissionManager.sol';
import {LMUpdateBaseTest} from '../utils/LMUpdateBaseTest.sol';

contract AaveV3EthereumLido_LMUpdateRenewLidoUSDCAwstETHLM_20241220 is LMUpdateBaseTest {
  address public constant override REWARD_ASSET = AaveV3EthereumLidoAssets.wstETH_A_TOKEN;
  uint256 public constant override NEW_TOTAL_DISTRIBUTION = 3 * 10 ** 18;
  address public constant override EMISSION_ADMIN = 0xac140648435d03f784879cd789130F22Ef588Fcd;
  address public constant override EMISSION_MANAGER = AaveV3EthereumLido.EMISSION_MANAGER;
  uint256 public constant NEW_DURATION_DISTRIBUTION_END = 21 days;
  address public constant aUSDC_WHALE = 0x7F77d4193Ee9307BEC638b6c819aBfFF7BC37b03;

  address public constant override DEFAULT_INCENTIVES_CONTROLLER =
    AaveV3EthereumLido.DEFAULT_INCENTIVES_CONTROLLER;

  function setUp() public {
    vm.createSelectFork(vm.rpcUrl('mainnet'), 21445106);
  }

  function test_claimRewards() public {
    NewEmissionPerAsset memory newEmissionPerAsset = _getNewEmissionPerSecond();
    NewDistributionEndPerAsset memory newDistributionEndPerAsset = _getNewDistributionEnd();

    vm.startPrank(EMISSION_ADMIN);
    IEmissionManager(AaveV3EthereumLido.EMISSION_MANAGER).setEmissionPerSecond(
      newEmissionPerAsset.asset,
      newEmissionPerAsset.rewards,
      newEmissionPerAsset.newEmissionsPerSecond
    );
    IEmissionManager(AaveV3EthereumLido.EMISSION_MANAGER).setDistributionEnd(
      newDistributionEndPerAsset.asset,
      newDistributionEndPerAsset.reward,
      newDistributionEndPerAsset.newDistributionEnd
    );

    _testClaimRewardsForWhale(
      aUSDC_WHALE,
      AaveV3EthereumLidoAssets.USDC_A_TOKEN,
      NEW_DURATION_DISTRIBUTION_END,
      0.0336 * 10 ** 18
    );
  }

  function _getNewEmissionPerSecond() internal pure override returns (NewEmissionPerAsset memory) {
    NewEmissionPerAsset memory newEmissionPerAsset;

    address[] memory rewards = new address[](1);
    rewards[0] = REWARD_ASSET;
    uint88[] memory newEmissionsPerSecond = new uint88[](1);
    newEmissionsPerSecond[0] = _toUint88(NEW_TOTAL_DISTRIBUTION / NEW_DURATION_DISTRIBUTION_END);

    newEmissionPerAsset.asset = AaveV3EthereumLidoAssets.USDC_A_TOKEN;
    newEmissionPerAsset.rewards = rewards;
    newEmissionPerAsset.newEmissionsPerSecond = newEmissionsPerSecond;

    return newEmissionPerAsset;
  }

  function _getNewDistributionEnd()
    internal
    view
    override
    returns (NewDistributionEndPerAsset memory)
  {
    NewDistributionEndPerAsset memory newDistributionEndPerAsset;

    newDistributionEndPerAsset.asset = AaveV3EthereumLidoAssets.USDC_A_TOKEN;
    newDistributionEndPerAsset.reward = REWARD_ASSET;
    newDistributionEndPerAsset.newDistributionEnd = _toUint32(
      IRewardsController(AaveV3EthereumLido.DEFAULT_INCENTIVES_CONTROLLER).getDistributionEnd(
        newDistributionEndPerAsset.asset,
        newDistributionEndPerAsset.reward
      ) + NEW_DURATION_DISTRIBUTION_END
    );

    return newDistributionEndPerAsset;
  }
}