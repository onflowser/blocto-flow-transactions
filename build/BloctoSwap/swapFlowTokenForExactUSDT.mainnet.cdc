import FungibleToken from 0xf233dcee88fe0abe
import FlowToken from 0x1654653399040a61
import TeleportedTetherToken from 0xcfdd90d4a00f7b5b
import FlowSwapPair from 0xc6c77b9f5c7a378f

transaction(maxAmountIn: UFix64, amountOut: UFix64) {
  prepare(signer: AuthAccount) {
    let amountIn = FlowSwapPair.quoteSwapToken1ForExactToken2(amount: amountOut) / (1.0 - FlowSwapPair.getFeePercentage())
    assert(amountIn <= maxAmountIn, message: "Input amount too large")

    let flowTokenVault = signer.borrow<&FlowToken.Vault>(from: /storage/flowTokenVault) 
      ?? panic("Could not borrow a reference to Vault")

    let token0Vault <- flowTokenVault.withdraw(amount: amountIn) as! @FlowToken.Vault
    let token1Vault <- FlowSwapPair.swapToken1ForToken2(from: <- token0Vault)

      if signer.borrow<&TeleportedTetherToken.Vault>(from: TeleportedTetherToken.TokenStoragePath) == nil {
    signer.save(<-TeleportedTetherToken.createEmptyVault(), to: TeleportedTetherToken.TokenStoragePath)
    signer.link<&TeleportedTetherToken.Vault{FungibleToken.Receiver}>(
      TeleportedTetherToken.TokenPublicReceiverPath,
      target: TeleportedTetherToken.TokenStoragePath
    )
    signer.link<&TeleportedTetherToken.Vault{FungibleToken.Balance}>(
      TeleportedTetherToken.TokenPublicBalancePath,
      target: TeleportedTetherToken.TokenStoragePath
    )
  }
    let teleportedTetherTokenVault = signer.borrow<&TeleportedTetherToken.Vault>(from: TeleportedTetherToken.TokenStoragePath) 
      ?? panic("Could not borrow a reference to Vault")

    

    teleportedTetherTokenVault.deposit(from: <- token1Vault)
  }
}