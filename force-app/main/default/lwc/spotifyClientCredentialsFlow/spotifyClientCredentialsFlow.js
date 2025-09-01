import { LightningElement } from 'lwc';
import getNewReleases from '@salesforce/apex/SpotifyClientCredentialsController.getNewReleases';

export default class SpotifyClientCredentialsFlow extends LightningElement {
    albums;

    handleGetNewRelease() {
        getNewReleases()
        .then(result => {
            console.log('SpotifyClientCredentialsFlow - getNewReleases', result);
            this.albums = JSON.parse(result);
        })
        .catch(error => console.error('SpotifyClientCredentialsFlow - getNewReleases', error));
    }
}