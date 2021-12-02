<template>
  <div class="tabs">
    <b-tabs v-model="activeTab" expanded :animated="false">
      <!-- Mint Tab -->
      <b-tab-item label="Mint">
        <h2 class="title is-size-4">Join the Evmos PFP Sale</h2>
        Minted {{ totalSupply }} out of total supply of 10001<br /><br />
        <div v-if="totalSupply <= 10000">
          <b-button v-if="!pending" v-on:click="buy" type="is-primary"
            >Buy NFT for 0.0001 PHO</b-button
          >
          <div v-if="pending">
            Pending transaction hash is<br />{{ pending }}..
          </div>
        </div>
      </b-tab-item>
      <!-- NFTs Tab -->
      <b-tab-item label="NFTs" style="overflow: hidden">
        <h2 class="title is-size-4">My NFTS</h2>
        <div style="overflow-x: scroll; padding-bottom:30px;">
          <div
            v-for="nft in owned"
            v-bind:key="nft"
            style="width: 20%; display: inline-block; margin: 0 2%"
          >
            <div class="card">
              <div class="card-image">
                <div
                  style="padding: 20px; border: 1px solid #ddd"
                  v-html="toSvg(nft, 300)"
                ></div>
              </div>
              <div class="card-content">
                <div class="media">
                  <div class="media-content">
                    <p class="title is-4" style="color: #000 !important">
                      NFT #{{ nft }}
                    </p>
                  </div>
                </div>
              </div>
            </div>
          </div>
        </div>
      </b-tab-item>
    </b-tabs>
  </div>
</template>

<script>
import Web3 from "web3";
const ABI = require("../abi.json");
const configs = require("../configs.json");
import { toSvg } from "jdenticon";

export default {
  props: ["account"],
  data() {
    return {
      activeTab: 0,
      web3: new Web3(window.ethereum),
      ABI: ABI,
      toSvg: toSvg,
      totalSupply: 0,
      pending: "",
      owned: [],
    };
  },
  methods: {
    async buy() {
      const app = this;
      const contract = new app.web3.eth.Contract(
        app.ABI,
        configs.contract_address
      );
      try {
        await contract.methods
          .buyNFT()
          .send({
            from: app.account,
            value: app.web3.utils.toWei("0.0001", "ether"),
          })
          .on("transactionHash", (pending) => {
            app.pending = pending;
          });
        app.totalSupply = await contract.methods.totalSupply().call();
        app.owned = await contract.methods.tokensOfOwner(app.account).call();
        alert("You successfull bought an NFT!");
        app.pending = "";
      } catch (e) {
        alert(e.message);
      }
    },
  },
  async mounted() {
    const app = this;
    const contract = new app.web3.eth.Contract(
      app.ABI,
      configs.contract_address
    );
    app.totalSupply = await contract.methods.totalSupply().call();
    app.owned = await contract.methods.tokensOfOwner(app.account).call();
  },
};
</script>
<style>
svg {
  max-width: 100%;
}
</style>