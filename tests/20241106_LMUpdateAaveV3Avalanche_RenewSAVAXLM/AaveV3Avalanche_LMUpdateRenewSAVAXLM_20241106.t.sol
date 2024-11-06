// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {AaveV3Avalanche, AaveV3AvalancheAssets} from 'aave-address-book/AaveV3Avalanche.sol';
import {IEmissionManager, ITransferStrategyBase, RewardsDataTypes, IEACAggregatorProxy} from '../../src/interfaces/IEmissionManager.sol';
import {LMUpdateBaseTest} from '../utils/LMUpdateBaseTest.sol';

contract AaveV3Avalanche_LMUpdateRenewSAVAXLM_20241106 is LMUpdateBaseTest {
  address public constant override REWARD_ASSET = AaveV3AvalancheAssets.sAVAX_UNDERLYING;
  uint256 public constant override NEW_TOTAL_DISTRIBUTION = (1800 + 1900 + 900 + 400) * 10 ** 18;
  address public constant override EMISSION_ADMIN = 0xac140648435d03f784879cd789130F22Ef588Fcd;
  address public constant override EMISSION_MANAGER = AaveV3Avalanche.EMISSION_MANAGER;
  uint256 public constant NEW_DURATION_DISTRIBUTION_END = 14 days;
  address public constant aBTCb_WHALE = 0xF579C0aaFc828DAD272bd1Ff07A0FCBd08828907;
  uint256 public constant ASSETS_COUNT = 4;
  address[] public assets = new address[](ASSETS_COUNT);
  uint256[] public assetsEmissions = new uint256[](ASSETS_COUNT);

  address public constant override DEFAULT_INCENTIVES_CONTROLLER =
    AaveV3Avalanche.DEFAULT_INCENTIVES_CONTROLLER;

  function setUp() public {
    vm.createSelectFork(vm.rpcUrl('avalanche'), 52708885);
  }

  function test_claimRewards() public {
    assets[0] = AaveV3AvalancheAssets.BTCb_A_TOKEN;
    assets[1] = AaveV3AvalancheAssets.USDC_A_TOKEN;
    assets[2] = AaveV3AvalancheAssets.USDt_A_TOKEN;
    assets[3] = AaveV3AvalancheAssets.sAVAX_A_TOKEN;

    assetsEmissions[0] = 1800 * 10 ** 18;
    assetsEmissions[1] = 1900 * 10 ** 18;
    assetsEmissions[2] = 900 * 10 ** 18;
    assetsEmissions[3] = 400 * 10 ** 18;

    address[] memory whales = new address[](ASSETS_COUNT);
    whales[0] = 0x7bBf8A8905b92fe5Dba6F50cD6b371e499091c79;
    whales[1] = 0x0f90Bbf994947399Ac83439707a083800fc42CBB;
    whales[2] = 0x854839Fdb982E7048aBf4aA4a070e113ff70D72D;
    whales[3] = 0x9767d88f156040A24CacD1696D6E9E9e0A49006F;

    uint256[] memory whalesRewards = new uint256[](ASSETS_COUNT);
    whalesRewards[0] = 18.45 * 10 ** 18; // 19.27 * 10 ** 18;
    whalesRewards[1] = 18.45 * 10 ** 18;
    whalesRewards[2] = 18 * 10 ** 18;
    whalesRewards[3] = 18 * 10 ** 18;

    NewEmissionPerAsset[] memory allNewEmissionPerAssets = _getNewEmissionPerSecond();
    NewDistributionEndPerAsset[] memory allNewDistributionsEndPerAsset = _getNewDistributionEnd();

    vm.startPrank(EMISSION_ADMIN);
    for (uint256 i = 0; i < allNewEmissionPerAssets.length; i++) {
      NewEmissionPerAsset memory newEmissionPerAsset = allNewEmissionPerAssets[i];
      IEmissionManager(AaveV3Avalanche.EMISSION_MANAGER).setEmissionPerSecond(
        newEmissionPerAsset.asset,
        newEmissionPerAsset.rewards,
        newEmissionPerAsset.newEmissionsPerSecond
      );
    }

    for (uint256 i = 0; i < allNewDistributionsEndPerAsset.length; i++) {
      NewDistributionEndPerAsset memory newDistributionEndPerAsset = allNewDistributionsEndPerAsset[
        i
      ];
      IEmissionManager(AaveV3Avalanche.EMISSION_MANAGER).setDistributionEnd(
        newDistributionEndPerAsset.asset,
        newDistributionEndPerAsset.reward,
        newDistributionEndPerAsset.newDistributionEnd
      );
    }

    for (uint256 i = 0; i < assets.length; i++) {
      _testClaimRewardsForWhale(
        whales[i],
        assets[i],
        NEW_DURATION_DISTRIBUTION_END,
        whalesRewards[i]
      );
    }
  }

  function _getNewEmissionPerSecond()
    internal
    view
    override
    returns (NewEmissionPerAsset[] memory)
  {
    NewEmissionPerAsset[] memory allNewEmissionPerAssets = new NewEmissionPerAsset[](ASSETS_COUNT);

    for (uint256 i = 0; i < assets.length; i++) {
      NewEmissionPerAsset memory newEmissionPerAsset;
      address[] memory rewards = new address[](1);
      rewards[0] = REWARD_ASSET;
      uint88[] memory newEmissionsPerSecond = new uint88[](1);
      newEmissionsPerSecond[0] = _toUint88(assetsEmissions[i] / NEW_DURATION_DISTRIBUTION_END);

      newEmissionPerAsset.asset = assets[i];
      newEmissionPerAsset.rewards = rewards;
      newEmissionPerAsset.newEmissionsPerSecond = newEmissionsPerSecond;

      allNewEmissionPerAssets[i] = newEmissionPerAsset;
    }

    return allNewEmissionPerAssets;
  }

  function _getNewDistributionEnd()
    internal
    view
    override
    returns (NewDistributionEndPerAsset[] memory)
  {
    NewDistributionEndPerAsset[]
      memory allNewDistributionsEndPerAsset = new NewDistributionEndPerAsset[](ASSETS_COUNT);

    for (uint256 i = 0; i < assets.length; i++) {
      NewDistributionEndPerAsset memory newDistributionEndPerAsset;

      newDistributionEndPerAsset.asset = assets[i];
      newDistributionEndPerAsset.reward = REWARD_ASSET;
      newDistributionEndPerAsset.newDistributionEnd = _toUint32(
        block.timestamp + NEW_DURATION_DISTRIBUTION_END
      );

      allNewDistributionsEndPerAsset[i] = newDistributionEndPerAsset;
    }

    return allNewDistributionsEndPerAsset;
  }
}