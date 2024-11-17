// SPDX-License-Identifier: GPL-2.0-or-later
pragma solidity ^0.8.0;
pragma abicoder v2;

import "v3-periphery/interfaces/ISwapRouter.sol";

interface IERC20 {
    function balanceOf(address account) external view returns (uint256);
    function transfer(address recipient, uint256 amount) external returns (bool);
    function approve(address spender, uint256 amount) external returns (bool);
}

contract SingleSwap {
    ISwapRouter public immutable swapRouter;
    IERC20 public immutable TOKEN1;
    IERC20 public immutable TOKEN2;
    uint24 public immutable poolFee;

    constructor(
        address _routerAddress,
        address _token1Address,
        address _token2Address,
        uint24 _poolFee
    ) {
        swapRouter = ISwapRouter(_routerAddress);
        TOKEN1 = IERC20(_token1Address);
        TOKEN2 = IERC20(_token2Address);
        poolFee = _poolFee;
    }

    function swapExactInputSingle(uint256 _amountIn, uint256 _amountOutMinimum) external returns (uint256 amountOut) {
        // Approve the router to spend TOKEN1
        TOKEN1.approve(address(swapRouter), _amountIn);

        ISwapRouter.ExactInputSingleParams memory params = ISwapRouter.ExactInputSingleParams({
            tokenIn: address(TOKEN1),
            tokenOut: address(TOKEN2),
            fee: poolFee,
            recipient: address(this),
            deadline: block.timestamp,
            amountIn: _amountIn,
            amountOutMinimum: _amountOutMinimum,
            sqrtPriceLimitX96: 0
        });

        // Execute the swap
        amountOut = swapRouter.exactInputSingle(params);
    }
}