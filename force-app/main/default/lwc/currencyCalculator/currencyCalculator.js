import { LightningElement, api, track, wire } from "lwc";
import CURRENCY_ISO_CODE from "@salesforce/schema/Opportunity.CurrencyIsoCode";
import AMOUNT from "@salesforce/schema/Opportunity.Amount";
import { getRecord } from "lightning/uiRecordApi";
import getConversionRates from "@salesforce/apex/GetTodayCurrencyInfo.getConversionRates";

const FIELDS = [CURRENCY_ISO_CODE, AMOUNT];

export default class CurrencyCalculator extends LightningElement {
  @api recordId;
  @track currencyOptions = [];
  @track selectedRate = "";
  @track currencyIsoCode = "";
  @track amount = 0;
  @track lastUpdatedTime = "";
  @track convertedAmount = 0;
  @track currencyDisplay = "";

  @wire(getRecord, { recordId: "$recordId", fields: FIELDS })
  opportunity({ error, data }) {
    if (data) {
      console.log(data.fields.CurrencyIsoCode.value);
      this.currencyIsoCode = data.fields.CurrencyIsoCode.value;
      this.amount = data.fields.Amount.value;
      this.currencyDisplay = `${this.currencyIsoCode} - ${this.amount}`;

      this.loadConversionRates();
    } else if (error) {
      console.error("Error fetching opportunity data:", error);
    }
  }

  async connectedCallback() {
    // No need to call loadConversionRates here, as it will be called once currencyIsoCode is set
  }

  async loadConversionRates() {
    try {
      console.log("currencyIsoCode : " + this.currencyIsoCode);
      const data = await getConversionRates({
        baseCurrency: this.currencyIsoCode
      });
      console.log(data);
      const result = data.conversionRates;
      const lastUpdatedTime = data.lastUpdatedTime;

      const kstDate = new Date(lastUpdatedTime);
      this.lastUpdatedTime = kstDate.toLocaleString("ko-KR", {
        timeZone: "Asia/Seoul"
      });
      console.log(result);

      this.currencyOptions = Object.keys(result).map((key) => {
        return { label: key, value: result[key] };
      });
    } catch (error) {
      console.error("Error fetching conversion rates:", error);
    }
  }

  handleChange(event) {
    this.selectedRate = +event.detail.value;
    this.calculateConvertedAmount();
    console.log("Selected Rate:", this.selectedRate);
  }

  calculateConvertedAmount() {
    if (this.selectedRate && this.amount) {
      this.convertedAmount = this.amount * parseFloat(this.selectedRate);
    } else {
      this.convertedAmount = 0;
    }
  }

  get options() {
    return this.currencyOptions.map((option) => ({
      label: option.label,
      value: option.value
    }));
  }
}
