import { LightningElement, api, track } from 'lwc';
import getContacts from '@salesforce/apex/ContactController.getContacts';
import getContacts2 from '@salesforce/apex/ContactController.getContacts2'



export default class FirstComponent extends LightningElement {

    //class level variables
    messsage = 'Hello!!';
    age = 22222;
    isWorking = false;
     newObj = {
        name: 'luffy',
        age: 22,
        isWorking: false,
    }
     friends = ['zoro', 'robin', 22, false, {
        name: 'luffy',
        age: 22,
        isWorking: false,
    }];
    conList;
    message;
    userInput;
    number = 0;
    showMessage = false;
    varOne = '';
    employees = [
        {
            name: 'Naruto',
            age: 20
        },
        {
            name: 'Sasuke',
            age : 21
        },
        {
            name: 'Itachi',
            age: 28
        }
    ];
    contacts;
    @api recordId;

    _fruits = ['apple'];
    a = 0;

    get fruits() {
        return this._fruits;
    }

    set fruits(v) {
        this._fruits = v;
    }

    connectedCallback() {
        console.log('contact recordId', this.recordId); 
        this.fruits.push('orange');
    }
    
    handleContactsChange() {
        getContacts2({'recordId': this.recordId})
        .then(result => {
            console.log('result', result);
            this.contacts = result;
        })
        .catch(error => {
            console.log('error while fetching getContacts2', error);
        })
    }

    addFruits() {
        this.a += 1;
        //this.fruits.push('mango' + this.a);
        this.fruits = [...this.fruits, `mango${this.a}`];
        console.log(this.fruits);
    }


}