import { LightningElement } from 'lwc';
import getNewReleases from '@salesforce/apex/SpotifyClientCredentialsController.getNewReleases';
import getNewReleasesWithNamedCredentials  from '@salesforce/apex/SpotifyClientCredentialsController.getNewReleasesWithNamedCredentials';

export default class SpotifyClientCredentialsFlow extends LightningElement {
    albums;

    /*handleGetNewRelease() {
        getNewReleases()
        .then(result => {
            console.log('SpotifyClientCredentialsFlow - getNewReleases', result);
            this.albums = JSON.parse(result);
        })
        .catch(error => console.error('SpotifyClientCredentialsFlow - getNewReleases', error));
    }*/
    handleGetNewRelease() {
        getNewReleasesWithNamedCredentials()
        .then(result => {
            console.log('SpotifyClientCredentialsFlow - getNewReleases', result);
            this.albums = JSON.parse(result);
        })
        .catch(error => console.error('SpotifyClientCredentialsFlow - getNewReleases', error));
    }
}