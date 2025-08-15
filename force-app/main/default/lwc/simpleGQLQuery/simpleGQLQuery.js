import { LightningElement, wire } from 'lwc';
import { gql, graphql } from 'lightning/uiGraphQLApi';

export default class SimpleGQLQuery extends LightningElement {
    results;
    errors;

    @wire(graphql, {
        query: '$getAccountGQLQuery',
    })
    graphqlQueryResult({ data, errors }) {
        if (data) {
            console.log('graphqlQueryResult: - SimpleGQLQuery', JSON.stringify(data, null, 4));
            this.results = data.uiapi.query.Account.edges.map((edge) => edge.node);
        }
        this.errors = errors;
    }

    get getAccountGQLQuery() {
        return gql`
        query AccountWithName {
            uiapi {
                query {
                    Account(first: 5) {
                        edges {
                            node {
                                Id
                                Name {
                                    value
                                }
                            }
                            cursor
                        }
                        totalCount
                        pageInfo {
                            endCursor
                            hasNextPage
                            startCursor
                            hasPreviousPage
                        }
                    }
                }
            }
        }
        `;
    }
    //trypical GQL response data:
    /*{
    "data": {
        "uiapi": {
        "query": {
            "Account": {
            "edges": [
                {
                "node": {
                    "Id": "0011a00000cR4wuAAC",
                    "Name": {
                    "value": "Edge Communications"
                    }
                }
                },
                {
                "node": {
                    "Id": "0011a00000cQvEwAAK",
                    "Name": {
                    "value": "United Oil"
                    }
                }
                },
                {
                "node": {
                    "Id": "0011a00000cRQ1wAAG",
                    "Name": {
                    "value": "Apple"
                    }
                }
                }, # more data here
            ]
            }
        }
        }
    },
    "errors": []
    }*/

}