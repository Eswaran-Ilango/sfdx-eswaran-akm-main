import { LightningElement, wire, track } from 'lwc';
import fetchAuthURLServiceNow from '@salesforce/apex/ServiceNowIntControllerWithPKCE.fetchAuthURLServiceNow';
import exchangeAuthCodeForToken from '@salesforce/apex/ServiceNowIntControllerWithPKCE.exchangeAuthCodeForToken';
import { CurrentPageReference } from 'lightning/navigation';

export default class ServiceNowAuthInitiate extends LightningElement {
    @track pageRef;

    @wire(CurrentPageReference)
    getPageRefUpdates(pageRef) {
        console.log('CurrentPageReference', pageRef);
        this.pageRef = pageRef;    
    }

    handleAuth() {
        this.fetchAuthUrl();
    }

    handleAccessToken() {
        console.log('CurrentPageReference - code', this.pageRef?.state?.c__code);
        this.getAccessToken(this.pageRef?.state?.c__code);
    }

    fetchAuthUrl() {
        fetchAuthURLServiceNow()
        .then(authUrlPKCE => {
            console.log('Service now auth PKCE URL', authUrlPKCE);
            window.location.href = authUrlPKCE;
        })
        .catch(e => {
            console.error('Failed to fetch the auth URL from ServiceNow Instance', JSON.stringify(e));
        })
    }

    getAccessToken(code) {
        console.log(code);
        exchangeAuthCodeForToken({ authCode: code})
        .then(res => {
            console.log('Access Token', res);
        })
        .catch(e => {
            console.error('Failed to fetch the access token from ServiceNow Instance', JSON.stringify(e));
        })
    }
}