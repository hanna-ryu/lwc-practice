import { LightningElement } from 'lwc';

export default class LifecycleChildComponent extends LightningElement {
    constructor(){
       // super();
        console.log('Call From Child Constructor');
    }
    connectedCallback(){
        console.log("call from child connectedCallback");
    }

    renderedCallback(){
        console.log("call from child renderedCallback");
    }

    disconnectedCallback(){
        console.log("call from child disconnectedCallback");
    }

    
}