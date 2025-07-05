import { LightningElement, track } from 'lwc';

export default class ArrayElement extends LightningElement {

    array = [ 'lwc', 'aura', 'flow'];
    counter = 0;
    arrayTwo = ['1', 2, 3];
    obj = { name : 'eswaran'};
    isShow = false;

    get arrayElement() {
        return this.array[this.counter];
    }

    get arrayReactive() {
        return this.arrayTwo[0];
    }


    handleShowHideClick() {
        this.isShow = !this.isShow;
    }
    
    handleNext() {
        if(this.counter < this.array.length - 1) {
            this.counter += 1;
        } else {
            alert(`array contains only ${this.array.length} elements. Please move backward`);
        } 
        this.arrayTwo[0] = 100;
        this.obj.name = 'rohan';
    }

    handleBack() {
        if(this.counter != 0) {
            this.counter -= 1;
        } else {
            alert('this is the last array element. Please move forward');
        }
    }

    handleChange(e) {
        this.arrayTwo.push(e.target.value);
        this.obj.name = e.target.value;
    }
}