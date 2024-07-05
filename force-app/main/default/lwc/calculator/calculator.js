import { LightningElement } from "lwc";

export default class Calculator extends LightningElement {
  operator;
  previousNum = "";
  recentNum = "";

  handleNumberClick(event) {
    this.recentNum += event.target.innerText;
  }

  handleOperatorClick(event) {
    if (this.operator) {
      return; // 이미 연산자가 설정되어 있으면 연속으로 적용되지 않도록 한다.
    }

    this.operator = event.target.innerText;
    this.previousNum = this.recentNum;
    this.recentNum = "";
  }

  handleClearClick() {
    this.previousNum = "";
    this.recentNum = "";
    this.operator = "";
  }

  handleEqualsClick() {
    let result = 0;
    switch (this.operator) {
      case "+":
        result = Number(this.previousNum) + Number(this.recentNum);
        break;
      case "-":
        result = Number(this.previousNum) - Number(this.recentNum);
        break;
      case "*":
        result = Number(this.previousNum) * Number(this.recentNum);
        break;
      case "/":
        result = Number(this.previousNum) / Number(this.recentNum);
        break;
      default:
        return;
    }
    this.recentNum = result.toString();
    this.previousNum = "";
    this.operator = "";
  }
}
