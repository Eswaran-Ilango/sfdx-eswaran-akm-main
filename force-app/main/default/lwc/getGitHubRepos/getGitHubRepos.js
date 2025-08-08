import { LightningElement, wire , track} from 'lwc';
import getGitRepos from '@salesforce/apex/GitHubReposController.getGitRepos';

const columns = [
    { label: 'Id', fieldName: 'id' },
    { label: 'Name', fieldName: 'name' },
    { label: 'Description', fieldName: 'description' },
    { label: 'Repo Url', fieldName: 'url', type: 'url' },

]

export default class GetGitHubRepos extends LightningElement {
    @track gitReposData = [];
    columns = columns;

    @wire(getGitRepos)
    gitRepos(data, error) {
        if(data && data?.data) {
            try {
                let parsedData = typeof data === 'object' ? JSON.parse(data.data) : data;

                // Store parsed data for use in the component
                this.gitReposData = parsedData;
            } catch (error) {
                console.error(error);
            }           
        }else if(error) {
            console.error(error);
        }
    }

}