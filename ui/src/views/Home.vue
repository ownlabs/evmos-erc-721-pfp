<template>
  <div class="tabs">
    <b-tabs v-model="activeTab" expanded :animated="false">
      <!-- Notarize Tab -->
      <b-tab-item label="Notarize">
        <h2 class="title is-size-4">Drag file to notarize</h2>
        <b-field>
          <b-upload
            v-on:input="calculateHash('notarizeFile')"
            v-model="notarizeFile"
            drag-drop
          >
            <section class="section">
              <div class="content has-text-centered">
                <p>
                  <b-icon icon="upload" size="is-large"></b-icon>
                </p>
                <p>Drop your file here or click to upload</p>
              </div>
            </section>
          </b-upload> </b-field
        ><br />
        <div v-if="notarizeFile.name !== undefined">
          Do you really want to notarize
          <b>{{ notarizeFile.name }}</b
          >?<br />
          Calculated hash is<br /><span style="font-size: 13px"
            >{{ hash.substr(0, 15) }}..{{ hash.substr(-15) }}</span
          ><br /><br />
          <b-button v-if="!pending" v-on:click="notarize" type="is-primary"
            >Notarize</b-button
          >
          <div v-if="pending">Pending transaction hash is {{ pending }}..</div>
        </div>
      </b-tab-item>
      <!-- Verify Tab -->
      <b-tab-item label="Verify">
        <h2 class="title is-size-4">Drag file to verify</h2>
        <b-field style="text-align:center">
          <b-upload
            v-on:input="calculateHash('verifyFile')"
            v-model="verifyFile"
            drag-drop
          >
            <section class="section">
              <div class="content has-text-centered">
                <p>
                  <b-icon icon="upload" size="is-large"></b-icon>
                </p>
                <p>Drop your file here or click to verify</p>
              </div>
            </section>
          </b-upload><br><br>
          <div v-if="verifying">Verifiying file..</div>
          <div v-if="verified">{{ verified }}</div> </b-field
        ><br />
      </b-tab-item>
    </b-tabs>
  </div>
</template>

<script>
import Web3 from "web3";
const ABI = require("../abi.json");
const configs = require("../configs.json");
const forge = require("node-forge");

export default {
  props: ["account"],
  data() {
    return {
      activeTab: 0,
      web3: new Web3(window.ethereum),
      notarizeFile: {},
      verifyFile: {},
      ABI: ABI,
      forge: forge,
      pending: "",
      hash: "",
      verified: "",
      verifying: false,
    };
  },
  methods: {
    async calculateHash(input) {
      const app = this;
      let file = app[input];
      var reader = new FileReader();
      reader.onload = function (event) {
        var readed = event.target.result;
        let md = app.forge.md.sha512.create();
        md.update(Buffer.from(readed));
        app.hash = md.digest().toHex();
        if (input === "verifyFile") {
          app.verify();
        }
      };
      reader.readAsArrayBuffer(file);
    },
    async notarize() {
      const app = this;
      if (app.hash.length > 0) {
        const contract = new app.web3.eth.Contract(
          app.ABI,
          configs.contract_address
        );
        try {
          const check = await contract.methods.verify(app.hash).call();
          alert(
            "This file was notarized yet at " + new Date(check * 1000) + "!"
          );
        } catch (e) {
          try {
            const result = await contract.methods
              .notarize(app.hash)
              .send({ from: app.account })
              .on("transactionHash", (pending) => {
                app.pending = pending;
              });
            app.hash = "";
            app.notarizeFile = "";
            app.pending = "";
            alert("Transaction confirmed at " + result.transactionHash + "!");
          } catch (e) {
            alert(e.message);
          }
        }
      }
    },
    async verify() {
      const app = this;
      if (app.hash.length > 0) {
        app.verifying = true;
        const contract = new app.web3.eth.Contract(
          app.ABI,
          configs.contract_address
        );
        try {
          const check = await contract.methods.verify(app.hash).call();
          app.verified =
            "This file was notarized yet at " + new Date(check * 1000) + "!";
          app.verifying = false;
        } catch (e) {
          app.verified = "This file was never notarized!";
          app.verifying = false;
        }
      }
    },
  },
};
</script>