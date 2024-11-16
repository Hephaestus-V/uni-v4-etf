// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {BaseHook} from "v4-periphery/src/base/hooks/BaseHook.sol";

import {Hooks} from "v4-core/src/libraries/Hooks.sol";
import {IPoolManager} from "v4-core/src/interfaces/IPoolManager.sol";
import {PoolKey} from "v4-core/src/types/PoolKey.sol";
import {PoolId, PoolIdLibrary} from "v4-core/src/types/PoolId.sol";
import {BalanceDelta} from "v4-core/src/types/BalanceDelta.sol";
import {BeforeSwapDelta, BeforeSwapDeltaLibrary} from "v4-core/src/types/BeforeSwapDelta.sol";

contract ETFHook is BaseHook {
    address[2] public tokens; // the underlying tokens will be stored in this hook contract
    uint256[2] public weights;
    uint256 public rebalanceThreshold;

    uint256[2] public tokenBalances;

    constructor(
        IPoolManager _poolManager,
        address[2] memory _tokens, // only two tokens are supported for now
        uint256[2] memory _weights,
        uint256 _rebalanceThreshold
    ) BaseHook(_poolManager) {
        tokens = _tokens;
        weights = _weights;
        rebalanceThreshold = _rebalanceThreshold;
        for (uint256 i= 0; i < 2; i++) {
            tokenBalances[i] = 0;
        }
    }

    function getHookPermissions() public pure override returns (Hooks.Permissions memory) {
        return Hooks.Permissions({
            beforeInitialize: false,
            afterInitialize: false,
            beforeAddLiquidity: true,
            afterAddLiquidity: true,
            beforeRemoveLiquidity: true,
            afterRemoveLiquidity: false,
            beforeSwap: true,
            afterSwap: true,
            beforeDonate: false,
            afterDonate: false,
            beforeSwapReturnDelta: false,
            afterSwapReturnDelta: false,
            afterAddLiquidityReturnDelta: false,
            afterRemoveLiquidityReturnDelta: false
        });
    }

    function beforeSwap(address sender, PoolKey calldata key, IPoolManager.SwapParams calldata, bytes calldata)
        external
        override
        returns (bytes4, BeforeSwapDelta, uint24)
    {
        if (checkIfRebalanceNeeded()) {
            rebalance();
        }
        return (BaseHook.beforeSwap.selector, BeforeSwapDeltaLibrary.ZERO_DELTA, 0);
    }

    function beforeAddLiquidity(
        address,
        PoolKey calldata key,
        IPoolManager.ModifyLiquidityParams calldata,
        bytes calldata
    ) external override returns (bytes4) {
        if (checkIfRebalanceNeeded()) {
            rebalance();
        }
        mintETFToken(0);
        return BaseHook.beforeAddLiquidity.selector;
    }

    function beforeRemoveLiquidity(
        address,
        PoolKey calldata key,
        IPoolManager.ModifyLiquidityParams calldata,
        bytes calldata
    ) external override returns (bytes4) {
        if (checkIfRebalanceNeeded()) {
            rebalance();
        }
        burnETFToken();
        return BaseHook.beforeRemoveLiquidity.selector;
    }

    // returns each token prices from oracle
    function getPrices() public returns (uint256[2] memory prices) {
        // TODO: use chainlink, pyth, chronicle
        return prices;
    }

    function checkIfRebalanceNeeded() private returns (bool) {
        // check chainlink if we need to rebalance (check if rebalanceThreshold is reached)
        // return true if rebalance needed
        uint256[2] memory prices = getPrices();
    }

    function rebalance() private {
        // sell A & buy B through specified uniswap pool
    }

    function mintETFToken(uint256 eftAmount) private {
        // transfer tokens to ETF pool contract
        // update token balances
        // mint ETF token to msg.sender
    }

    function burnETFToken() private {
        // transfer tokens to msg.sender
        // update token balances
        // burn ETF token from msg.sender
    }
}
