import FungibleToken from 0x9a0766d93b6608b7
import FlowToken from 0x7e60df042a9c0868
import BloctoToken from 0x6e0797ac987005f5
import FlowSwapPair from 0xd9854329b7edf136
import BltUsdtSwapPair from 0xc59604d4e65f14b3

transaction(amountIn: UFix64, minAmountOut: UFix64) {
  prepare(signer: AuthAccount) {
    
    

    let flowTokenVault = signer.borrow<&FlowToken.Vault>(from: /storage/flowTokenVault) 
      ?? panic("Could not borrow a reference to Vault")

    let token0Vault <- flowTokenVault.withdraw(amount: amountIn) as! @FlowToken.Vault
    let token1Vault <- FlowSwapPair.swapToken1ForToken2(from: <- token0Vault)
let token2Vault <- BltUsdtSwapPair.swapToken2ForToken1(from: <- token1Vault)

      if signer.borrow<&BloctoToken.Vault>(from: /storage/bloctoTokenVault) == nil {
    signer.save(<-BloctoToken.createEmptyVault(), to: /storage/bloctoTokenVault)
    signer.link<&BloctoToken.Vault{FungibleToken.Receiver}>(
      /public/bloctoTokenReceiver,
      target: /storage/bloctoTokenVault
    )
    signer.link<&BloctoToken.Vault{FungibleToken.Balance}>(
      /public/bloctoTokenBalance,
      target: /storage/bloctoTokenVault
    )
  }
    let bloctoTokenVault = signer.borrow<&BloctoToken.Vault>(from: /storage/bloctoTokenVault) 
      ?? panic("Could not borrow a reference to Vault")

    assert(token2Vault.balance >= minAmountOut, message: "Output amount too small")

    bloctoTokenVault.deposit(from: <- token2Vault)
  }
}