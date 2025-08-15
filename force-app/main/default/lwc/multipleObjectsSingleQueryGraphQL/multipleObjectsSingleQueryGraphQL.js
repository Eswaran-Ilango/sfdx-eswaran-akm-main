import { LightningElement, wire } from 'lwc';
import { gql, graphql } from 'lightning/uiGraphQLApi';
import Id from '@salesforce/user/Id';

export default class MultipleObjectsSingleQueryGraphQL extends LightningElement {
    queryError;
    contacts;

    userName;
    userId = Id;
    recordId;

    handleRecordChange(e) {
        this.recordId = e.detail.recordId;
    }

    @wire(graphql, {
        query: "$contactQuery",
        variables: "$queryData",
    })
    recordsQueryResult({ data, errors }) {
        if (data) {
            this.contacts = data.uiapi.query.Contact.edges.map((edge) => edge.node);
            this.userName = data.uiapi.query.User.edges.map((edge) => edge.node);
            console.log('recordsQueryResult: - "MultipleObjectsSingleQueryGraphQL"', JSON.stringify(data, null, 4));
        }

        if (errors) {
            this.queryError = errors;
            console.error('recordsQueryResult: - "MultipleObjectsSingleQueryGraphQL"', JSON.stringify(errors, null, 4));
        }
    }

    get contactQuery() {
        if(!this.recordId) return undefined;
        return gql`
        query contactsOnAccount($recordId: ID!, $userId: ID!) {
            uiapi {
                query {
                    Contact(where: { AccountId: { eq: $recordId } }) {
                        edges {
                            node {
                                Id
                                Name {
                                    value
                                }
                            }
                        }
                    }
                    User(where: { Id: { eq: $userId } }) {
                        edges {
                            node {
                                Id
                                Name {
                                    value
                                }
                                Email {
                                    value
                                }
                                Profile {
                                    Name {
                                        value
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
        `;
    }

    get queryData() {
        return {
            recordId: this.recordId,
            userId: this.userId,
        };
    }
}