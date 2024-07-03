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
    
    @wire(getHighRevenueAccountRecords)
    getAccountsHandler(response){
        // {error: ..., data: ...}
        // Case1 : {error: undefined, data: ...}
        // Case2 : {error: undefined, data: undefined}
        const{data, error} = response; //destructing
        // ==>  data = response.data;
        // ==> error = response.error;

        if(error){
            console.error(error);
            return;
        }

        if(data){
            this.accountsToDisplay = data;
        }

    }
}
