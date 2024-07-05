import { LightningElement } from "lwc";

export default class LifecycleHooksExample extends LightningElement {
  constructor() {
    super();
    console.log("constructor");
  }

  connectedCallback() {
    console.log("connectedCallback");
  }

  renderedCallback() {
    console.log("renderedCallback");
  }

  errorCallback() {
    console.log("error call from parent errorCallBack");
  }
}
