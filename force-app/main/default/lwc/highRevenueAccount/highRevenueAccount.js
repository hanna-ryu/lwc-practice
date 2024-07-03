import { LightningElement, wire } from 'lwc';

//apex 메소드 import할때는 메소드 이름은 달라도 괜찮다.
import getHighRevenueAccountRecords from '@salesforce/apex/AccountController.getHighRevenueAccountRecords';

/*
1. LWC => getHighRevenueAccountRecords
wire => import lwc
=> Calling getHighRevenueAccountRecords
=> @salesforce/apex

2. Apex => AccountController
=> getHighRevenueAccountRecords

Within LWC class

Syntax1:-Good to use
@wire(methodName)
handler(response){
}

Syntax2:-Good to use
@wire(methodName)
propertyName;

3. Lightning Component Tab
*/

export default class HighRevenueAccount extends LightningElement {
    accountsToDisplay = [];
    countOfRecords = 5;

    connectedCallback(){
        //imperative method
        getHighRevenueAccountRecords({count: this.countOfRecords})
        .then(result => {
            console.log('Result using imperative approach1', result);
            this.accountsToDisplay = result;
        })
        .catch(error => {
            console.log(error);
        })
    }


    setCount(event){
        console.log('Value', event.target.value);
        let inputValue = event.target.value;
        if(inputValue == '') return;
        this.countOfRecords = inputValue;
        getHighRevenueAccountRecords({count: this.countOfRecords}).then(result => {
            console.log('Result using declarative approach', result);
            this.accountsToDisplay = result;
        })
        .catch(error => {
            console.log('Error' , error);
        })
    }

}
