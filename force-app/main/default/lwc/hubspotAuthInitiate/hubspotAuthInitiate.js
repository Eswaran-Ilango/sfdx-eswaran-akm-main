import { LightningElement } from 'lwc';
import { NavigationMixin } from 'lightning/navigation'; 
import getHubSpotCompanyInfo from '@salesforce/apex/HubSpotController.getHubSpotCompanyInfo';
import getBatchOfCompanies from '@salesforce/apex/HubSpotController.getBatchOfCompanies';
import refreshToken from '@salesforce/apex/HubSpotController.refreshToken';

export default class HubspotAuthInitiate extends NavigationMixin(LightningElement) {
    res;

    connectedCallback() {
        const authCode = this.getHubSpotAuthCode();
        this.getHubSpotCompanyInfoMethod(authCode);
    }
    
    handleAuth() {
        //1. Using window.location.ref to navigate to a new page
        window.location.href = 'https://app-na2.hubspot.com/oauth/authorize?client_id=406eb684-eab3-46a7-8d21-5308b29dfe16&redirect_uri=https://computing-ability-2148-dev-ed--c.scratch.vf.force.com/apex/HubSpotAuthVFPage&scope=oauth%20crm.objects.companies.write%20crm.objects.companies.read';
        
        //2. Using Navigation mixin to navigate to a new page
        /*let pageRef = {
            type: 'standard__webpage',
            attributes: {
                url: 'https://app-na2.hubspot.com/oauth/authorize?client_id=406eb684-eab3-46a7-8d21-5308b29dfe16&redirect_uri=https://computing-ability-2148-dev-ed--c.scratch.vf.force.com/apex/HubSpotAuthVFPage&scope=oauth%20crm.objects.companies.write%20crm.objects.companies.read'
            }
        }; 
        
        this[NavigationMixin.Navigate](pageRef, [true]);*/
    }

    getHubSpotAuthCode() {
        let url = window.location.href;
        const authCode = new URL(url).searchParams.get('c__code');
        console.log('HubSpot Auth Code:'+authCode);
        return authCode;
    }

    getHubSpotCompanyInfoMethod(authCode) {
        if(!authCode || authCode == '') {
            return;
        }
        getHubSpotCompanyInfo({
            'authCode': authCode, 
            'isRefreshToken': false
        })
        .then(res => {
            console.log('HubSpot Company Info:'+res);
        })
        .catch(e=> {
            console.error('apex/HubSpotController.getHubSpotCompanyInfo:'+JSON.stringify(e));
        })
    }

    getBatchOfCompaniesMethod() {
        getBatchOfCompanies()
        .then(res => {
            console.log('HubSpot Company Info:'+res);
            this.res = res;
        })
        .catch(e=> {
            console.error('apex/HubSpotController.getHubSpotCompanyInfo:'+JSON.stringify(e));
        })

    }


    refreshTokenMethod() {
        refreshToken()
        .then(res => {
            console.log('refreshToken:'+res);
        })
        .catch(e=> {
            console.error('apex/HubSpotController.refreshTokenMethod:'+JSON.stringify(e));
        })
    }
}