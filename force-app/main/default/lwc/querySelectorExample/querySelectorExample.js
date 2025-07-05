import { LightningElement, track} from 'lwc';

export default class QuerySelectorExample extends LightningElement {

    @track employees = [
        {
            id: 101,
            name: "Luffy",
            salary: 20000
        },
        {
            id: 102,
            name: "Zoro",
            salary: 30000
        },
        {
            id: 103,
            name: "Nami",
            salary: 50000
        }
    ]

    connectedCallback() {
        console.log('this.employees', JSON.stringify(this.employees));
    }

    get firstEmployeeInfo() {
        return this.employees[0];
    }

    handleSalaryChange(event) {
        let newSalary = event.target.value;
        let empId = event.target.dataset.empid;

        this.employees.forEach(element => {
            if(element.id == empId) {
                element.salary = newSalary;
            }
        });
    }

    handleSelect(event) {
        let empId = event.target.dataset.empid;
        let empSalary = event.target.dataset.empsalary;
        let empName = event.target.dataset.empname;

        alert(`     Emp Id: ${empId} 
                Emp Name: ${empName} 
                Emp Salary ${empSalary}`);
    }

    handleClear(event) {
        let empId = event.target.dataset.empid;
        this.template.querySelector(`lightning-input[data-empid='${empId}']`).value = 0;
        
        this.employees.forEach(element => {
            if(element.id == empId) {
                element.salary = 0;
            }
        });
    }

    handleClearFirst() {
        this.template.querySelector(`lightning-input[data-empid='101']`).value = 0;
        this.employees[0].salary = 0;
    }

    handleClearAll() {
        let p = this.template.querySelectorAll('lightning-input');
        console.log((p));
        console.log((Array.from(p)));

        p.forEach(e => {
            e.value = 0;
        });

        this.employees.forEach(element => {
            element.salary = 0;
        });
    }
}